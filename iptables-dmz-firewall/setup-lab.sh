#!/usr/bin/env bash
# Build the 3-zone lab topology with LXD:
#   LAN (172.16.1.0/24) ── FW ── DMZ (192.168.1.0/24) ── Internet (eth0)
# FW routes/filters between the zones; the web server lives in the DMZ.
set -euo pipefail

for host in FW DMZ LAN; do
    sudo lxc launch ubuntu:20.04 "$host"
    lxc exec "$host" -- apt update
done

# Two internal bridges (no managed addressing; the FW assigns IPs)
lxc network create br0 ipv4.address=none ipv6.address=none   # FW <-> DMZ
lxc network create br1 ipv4.address=none ipv6.address=none   # FW <-> LAN

lxc network attach br0 FW eth1
lxc network attach br1 FW eth2
lxc network attach br0 DMZ eth0
lxc network attach br1 LAN eth0

lxc exec DMZ -- ip addr add 192.168.1.8/24 dev eth0
lxc exec LAN -- ip addr add 172.16.1.3/24 dev eth0
lxc exec FW  -- ip addr add 192.168.1.1/24 dev eth1
lxc exec FW  -- ip addr add 172.16.1.1/24 dev eth2

lxc exec LAN -- ip route add 0.0.0.0/0 via 172.16.1.1
lxc exec DMZ -- ip route add 0.0.0.0/0 via 192.168.1.1
