#!/usr/bin/env bash
# Minimal Composer installer (official method).
set -euo pipefail
EXPECTED="$(curl -fsSL https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
[ "$EXPECTED" = "$ACTUAL" ] || { echo "Invalid installer signature"; exit 1; }
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm -f composer-setup.php
