#!/usr/bin/env bash
# Stateful DMZ firewall for the LAN/DMZ/Internet topology.
# Features: default-drop, DNAT of public services to the DMZ web server, SNAT for egress,
#           geo-restricted SSH (France only) + host whitelist via ipset, SYN-flood protection.
set -euo pipefail

# --- Interfaces / addresses ---
IFEXT="eth0"; IFDMZ="eth1"; IFLAN="eth2"
IPEXT="10.71.105.37"
IPLAN="172.16.1.1"; IPDMZ="192.168.1.1"
IPWEB="192.168.1.8"; IPDNS="192.168.1.8"; IPMAIL="192.168.1.8"; IPSSH="192.168.1.8"

# --- Service ports ---
SMTP=25; HTTP=80; HTTPS=443; SSH=22; DNS=53

# Pause forwarding while we rebuild the ruleset
echo 0 > /proc/sys/net/ipv4/ip_forward

# Default-drop and flush
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
iptables -F
iptables -Z
iptables -t nat -F
iptables -t nat -Z

# Loopback
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# --- NAT: publish DMZ services, masquerade outbound ---
iptables -t nat -A PREROUTING  -p tcp --dport $HTTP -j DNAT --to "$IPWEB"
iptables -t nat -A PREROUTING  -p tcp --dport $SSH  -j DNAT --to "$IPSSH"
iptables -t nat -A POSTROUTING -o "$IFEXT"          -j SNAT --to-source "$IPEXT"

# --- Forwarding policy (stateful) ---
iptables -A FORWARD -d "$IPWEB"  -p tcp -m multiport --dports $HTTP,$HTTPS -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -d "$IPDNS"  -p udp --dport $DNS  -j ACCEPT
iptables -A FORWARD -d "$IPMAIL" -p tcp --dport $SMTP -j ACCEPT
iptables -A FORWARD -s "$IPWEB"  -p tcp -m multiport --sports $HTTP,$HTTPS -m state --state ESTABLISHED -j ACCEPT
iptables -A FORWARD -s "$IPDNS"  -p udp --sport $DNS  -j ACCEPT
iptables -A FORWARD -s "$IPMAIL" -p tcp --sport $SMTP -j ACCEPT

# --- SSH to the web server: France IP ranges only (ipset hash:net) ---
ipset create FRANCE hash:net -exist
wget -qO- http://www.ipdeny.com/ipblocks/data/countries/fr.zone | while read -r ip; do
    ipset add FRANCE "$ip" -exist
done
iptables -A FORWARD -d "$IPWEB" -p tcp --dport $SSH -m set --match-set FRANCE src -j ACCEPT

# --- Plus an explicit admin host whitelist ---
ipset create admin_hosts hash:ip -exist
ipset add admin_hosts 10.71.105.1 -exist
iptables -A FORWARD -d "$IPWEB" -p tcp --dport $SSH -m set --match-set admin_hosts src -j ACCEPT
iptables -A FORWARD -s "$IPWEB" -p tcp --sport $SSH -m state --state ESTABLISHED -j ACCEPT

# --- SYN-flood hardening ---
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_syn_recv=4
sysctl -w net.ipv4.tcp_max_syn_backlog=2048
sysctl -w net.ipv4.tcp_synack_retries=2
sysctl -w net.ipv4.tcp_syncookies=1

iptables -A FORWARD -p tcp -m state --state NEW -m recent --name CONXTCP --set
iptables -A FORWARD -m recent --name CONXTCP --update --hitcount 15 --seconds 1 -j LOG --log-prefix "POSSIBLE SYN FLOOD "
iptables -A FORWARD -m recent --name CONXTCP --update --hitcount 15 --seconds 1 -j DROP

# Re-enable forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
