# Ansible — PHP web application deployment

Idempotent, role-style Ansible automation that provisions a container and deploys a PHP
web application end to end: **Nginx reverse proxy + PHP 8.3-FPM + MySQL**, environment
wired up, Composer installed and database migrations applied — in a single command.

## What it does

| Playbook | Role |
|----------|------|
| `provision-container.yml` | Create/start the target **LXD** container |
| `deploy.yml` | Install & configure Nginx, MySQL, PHP 8.3, deploy the app, run `php artisan migrate` |

Nginx is templated ([`templates/nginx.conf.j2`](templates/nginx.conf.j2)), the DB
user/schema are created, the app `.env` is patched with a loop, writable directories get
the right ownership, and a handler restarts Nginx only when its config changes.

## Run

```bash
ansible-galaxy collection install community.general community.mysql
ansible-playbook provision-container.yml
ansible-playbook deploy.yml -e "db_pass=$(openssl rand -base64 18)"
```

## Notes

- **Secrets** are never hard-coded: `db_pass` is overridden at runtime (shown above) or
  stored with **Ansible Vault**. The committed default is a placeholder.
- Everything is **idempotent** — re-running converges instead of duplicating state.
- Swap the `lxd` connection/inventory for `ssh` to target real hosts.

## Skills

Ansible playbooks/handlers/templates/loops, idempotency, LXD provisioning, LEMP stack
configuration, secret handling with Vault.
