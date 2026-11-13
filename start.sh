#!/bin/sh
set -e
cd /var/www/html

# Render/Railway give the port in $PORT
PORT="${PORT:-10000}"
sed -ri "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -ri "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Generate an APP_KEY if none was supplied
if [ -z "$APP_KEY" ]; then
  export APP_KEY="base64:$(openssl rand -base64 32)"
fi

# Make sure .env exists so artisan commands do not complain
[ -f .env ] || touch .env

php artisan package:discover --ansi || true
php artisan storage:link || true
php artisan migrate --force

# Seed demo data only when SEED_DB=true (set it back to false after the first deploy)
if [ "$SEED_DB" = "true" ]; then
  php artisan db:seed --force || true
fi

php artisan config:cache
php artisan route:cache || true
php artisan view:cache || true

exec apache2-foreground
