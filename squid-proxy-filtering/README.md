# Squid — caching proxy with URL filtering & auth

A Squid forward proxy hardened with **SquidGuard** category filtering, **custom logging**
and **Basic (NCSA) authentication**.

## Files

| File | Role |
|------|------|
| [`squid.conf`](squid.conf) | Proxy on :8080, ACLs, custom log format, auth, URL rewriter |
| [`squidGuard.conf`](squidGuard.conf) | Category blacklists + redirect policy |
| [`blocked.htm`](blocked.htm) | Page shown when a request is blocked |
| [`create-users.sh`](create-users.sh) | Create proxy users (bcrypt via `htpasswd -B`) |

## Highlights

- Listens on **8080**; ACL/`http_access` control who can use the proxy.
- **Custom `logformat`** adds the `User-Agent` to `access.log`.
- **SquidGuard** (`url_rewrite_program`) blocks categories (adult/malware lists compiled
  with `squidGuard -C all`) and redirects to `blocked.htm` (HTTP 301 for cleartext).
- **NCSA Basic auth**: bcrypt-hashed credentials in a proxy-only readable file.

```bash
sudo apt install squid squidguard apache2-utils
sudo ./create-users.sh
sudo systemctl restart squid
```

## Skills

HTTP proxying/caching, ACL design, content filtering, log engineering, proxy
authentication, HTTP vs HTTPS proxy behaviour.
