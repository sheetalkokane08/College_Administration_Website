FROM php:8.3-apache

# System packages + PHP extensions Laravel needs (MySQL and PostgreSQL both supported)
RUN apt-get update && apt-get install -y --no-install-recommends \
        git unzip curl openssl libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
        libonig-dev libxml2-dev libpq-dev nodejs npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql pdo_pgsql mbstring zip gd bcmath pcntl exif \
    && a2enmod rewrite headers \
    && rm -rf /var/lib/apt/lists/*

# Serve from /public and tell Laravel the request was HTTPS when behind a proxy
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && printf 'SetEnvIf X-Forwarded-Proto https HTTPS=on\n' > /etc/apache2/conf-enabled/https-proxy.conf

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .

# Dev dependencies are kept on purpose: the database seeder uses Faker.
RUN composer install --optimize-autoloader --no-interaction --no-scripts \
    && (npm ci || npm install) && npm run build && rm -rf node_modules \
    && mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod +x docker/start.sh

EXPOSE 10000
CMD ["docker/start.sh"]
