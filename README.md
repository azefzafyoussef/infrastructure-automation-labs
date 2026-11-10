# Infrastructure Automation & Network Security — Labs

A set of self-contained labs covering **infrastructure as code**, **network security**
and **monitoring** on Linux — the day-to-day toolbox of a DevOps / sysadmin / network
engineer. Each folder is a runnable mini-project with its real configuration and a
focused write-up.

## Labs

| Lab | Stack | What it shows |
|-----|-------|---------------|
| [ansible-webapp-deploy](ansible-webapp-deploy/) | **Ansible**, Nginx, PHP-FPM, MySQL | One-command, idempotent deployment of a PHP web app (IaC) |
| [iptables-dmz-firewall](iptables-dmz-firewall/) | **iptables**, ipset, LXD | Stateful LAN/DMZ/Internet firewall: NAT, geo-filtered SSH, SYN-flood protection |
| [ipsec-site-to-site](ipsec-site-to-site/) | **strongSwan**, IKEv2 | Encrypted site-to-site VPN (AES-256/SHA-256/DH-14) |
| [squid-proxy-filtering](squid-proxy-filtering/) | **Squid**, SquidGuard | Caching proxy with URL filtering, custom logs and auth |
| [nagios-monitoring](nagios-monitoring/) | **Nagios Core**, NRPE | Active monitoring of hosts (CPU, disk, memory, ping) |

## Cross-cutting practices

- **Infrastructure as code** and **idempotency** (Ansible).
- **Defense in depth**: segmentation, least privilege, encryption, rate limiting.
- **Secrets stay out of the repo** — placeholders/Vault, never real credentials.
- Everything runs in disposable **LXD** containers / VMs.

## Toolbox

Ansible · iptables/netfilter · ipset · strongSwan (IPsec) · Squid/SquidGuard · Nagios/NRPE
· LXD · Bash
