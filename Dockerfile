FROM php:8.2-cli

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

EXPOSE 8080

# Start PHP built-in server with router
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html", "/var/www/html/router.php"]
