FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    zip \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip curl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create necessary directories
RUN mkdir -p /var/www/html/_sessions \
    && mkdir -p /var/www/html/storage/logs \
    && mkdir -p /run/php \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/cache/nginx \
    && chmod -R 777 /var/www/html/storage \
    && chmod -R 777 /var/www/html/_sessions \
    && chmod -R 777 /var/www/html/vendor \
    && chmod -R 777 /var/log/nginx \
    && chmod -R 777 /var/cache/nginx

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader || echo "Composer install skipped"

# Expose port
EXPOSE 80

# Start script
CMD service php8.2-fpm start && nginx -g "daemon off;"
