# Nagios — infrastructure monitoring (NRPE)

Monitoring a local infrastructure with **Nagios Core** using **active checks over NRPE**:
the server polls agents on each host for ping, CPU load, disk and memory.

## Files

| File | Role |
|------|------|
| [`nrpe.cfg`](nrpe.cfg) | NRPE agent config on each monitored host (allowed server + commands) |
| [`host-C2.cfg`](host-C2.cfg) | Nagios server host + service definitions for one machine |

## How it works

- **Active check / NRPE**: the Nagios server initiates each query; the agent runs the
  matching plugin (`check_load`, `check_disk`, `check_mem`, …) and returns the result.
- `allowed_hosts` restricts which server may query each agent.
- Each monitored host gets a `define host` plus one `define service` per metric, with
  check/retry intervals, notification options and parent (topology) relationships.

```bash
# on each host
sudo apt install nagios-nrpe-server nagios-plugins
# on the server
sudo apt install nagios4 nagios-nrpe-plugin
# -> web UI at http://<server>/nagios4/
```

## Skills

Monitoring design (active vs passive, NRPE/NSCA), host/service modelling, thresholds and
notifications, plugin-based metric collection.
