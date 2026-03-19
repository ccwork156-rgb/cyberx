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
    && echo 'export TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"' >> /etc/apache2/envvars \
    && echo 'export TELEGRAM_BOT_USERNAME="${TELEGRAM_BOT_USERNAME}"' >> /etc/apache2/envvars \
    && echo 'export TELEGRAM_ADMIN_USERNAME="${TELEGRAM_ADMIN_USERNAME}"' >> /etc/apache2/envvars \
    && echo 'export TELEGRAM_ADMIN_ID="${TELEGRAM_ADMIN_ID}"' >> /etc/apache2/envvars \
    && echo 'export TELEGRAM_ANNOUNCE_CHAT_ID="${TELEGRAM_ANNOUNCE_CHAT_ID}"' >> /etc/apache2/envvars \
    && echo 'export APP_DEBUG="${APP_DEBUG}"' >> /etc/apache2/envvars \
    && echo 'export APP_HOST="${APP_HOST}"' >> /etc/apache2/envvars \
    && echo 'export DB_DSN="${DB_DSN}"' >> /etc/apache2/envvars \
    && echo 'export DB_USER="${DB_USER}"' >> /etc/apache2/envvars \
    && echo 'export DB_PASS="${DB_PASS}"' >> /etc/apache2/envvars

EXPOSE 8080

CMD ["apache2-foreground"]
