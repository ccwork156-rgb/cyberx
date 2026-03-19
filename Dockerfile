FROM php:8.2-apache

# Install extensions
RUN apt-get update && apt-get install -y \
    git curl libcurl4-openssl-dev zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip curl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

# Create directories and install dependencies
RUN mkdir -p _sessions storage/logs \
    && chmod -R 777 _sessions storage vendor \
    && composer install --no-dev --optimize-autoloader || true

# Configure Apache
RUN a2enmod rewrite \
    && echo 'ServerName localhost' >> /etc/apache2/apache2.conf \
    && echo 'PassEnv TELEGRAM_BOT_TOKEN TELEGRAM_BOT_USERNAME TELEGRAM_ADMIN_USERNAME TELEGRAM_ADMIN_ID TELEGRAM_ANNOUNCE_CHAT_ID APP_DEBUG APP_HOST DB_DSN DB_USER DB_PASS MYSQLHOST MYSQLPORT MYSQLUSER MYSQLPASSWORD MYSQLDATABASE' >> /etc/apache2/envvars

EXPOSE 8080

CMD ["apache2-foreground"]
