#!/usr/bin/env bash
# Create proxy users for Basic (NCSA) auth with bcrypt-hashed passwords.
set -euo pipefail
htpasswd -B -c /etc/squid/users alice      # prompts for a password
htpasswd -B    /etc/squid/users bob
# Restrict the credential file to the proxy service account
chown proxy:proxy /etc/squid/users
chmod 640         /etc/squid/users
