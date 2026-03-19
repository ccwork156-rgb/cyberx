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
COPY nginx.conf /etc/nginx/sites-available/default

# Enable Nginx site
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Create necessary directories
RUN mkdir -p /var/www/html/_sessions \
    && mkdir -p /var/www/html/storage/logs \
    && mkdir -p /run/php \
    && chmod -R 777 /var/www/html/storage \
    && chmod -R 777 /var/www/html/_sessions \
    && chmod -R 777 /var/www/html/vendor

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader || true

# Expose port from Railway environment or default to 80
ENV PORT=80

# Create startup script
RUN echo '#!/bin/bash \n\
service php8.2-fpm start || php-fpm -D \n\
nginx -g "daemon off;"' > /start.sh && chmod +x /start.sh

# Expose port
EXPOSE 80

# Start services
CMD ["/start.sh"]
