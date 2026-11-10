# Netfilter/iptables — DMZ firewall

A stateful three-zone firewall (**LAN / DMZ / Internet**) built on `iptables` + `ipset`,
with the full lab topology scripted on LXD containers.

```
LAN 172.16.1.0/24 ──┐
                    FW ── DMZ 192.168.1.0/24 (web/dns/mail = .8)
Internet (eth0) ────┘
```

## Files

| File | Role |
|------|------|
| [`setup-lab.sh`](setup-lab.sh) | Build the 3-zone topology (LXD containers, bridges, addressing, routes) |
| [`firewall.sh`](firewall.sh) | The firewall ruleset itself |

## Ruleset highlights

- **Default-drop** on INPUT/OUTPUT/FORWARD, clean flush, loopback allowed.
- **DNAT** publishes the DMZ web/SSH services; **SNAT** masquerades outbound traffic.
- **Stateful** forwarding (`-m state NEW,ESTABLISHED`) per service (HTTP/HTTPS/DNS/SMTP).
- **Geo-filtered SSH**: an `ipset hash:net` named `FRANCE` is filled from IPdeny's French
  ranges, so SSH to the web server is allowed only from French IPs — plus an explicit
  admin-host whitelist.
- **SYN-flood hardening**: SYN cookies, tuned backlog/timeouts, and a `recent`-based rate
  limit that logs and drops bursts.

## Run

```bash
sudo ./setup-lab.sh         # once, to create the lab
sudo ./firewall.sh          # apply the ruleset on FW
```

Tested with `hping3 --flood` (SYN flood) and `nc` port probes from allowed vs. blocked
source IPs.

## Skills

Netfilter chains/tables, NAT (DNAT/SNAT), stateful filtering, `ipset`, kernel network
hardening (`sysctl`), network segmentation, LXD networking.
