FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
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

# Copy everything
COPY . .

# Set permissions
RUN mkdir -p /var/www/html/_sessions \
    && mkdir -p /var/www/html/storage/logs \
    && chmod -R 777 /var/www/html/storage \
    && chmod -R 777 /var/www/html/_sessions \
    && chmod -R 777 /var/www/html/vendor

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction || echo "Composer skipped"

# Create startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'PORT="${PORT:-8080}"' >> /start.sh && \
    echo 'echo "Starting PHP server on port $PORT"' >> /start.sh && \
    echo 'php -S 0.0.0.0:$PORT -t /var/www/html' >> /start.sh && \
    chmod +x /start.sh

# Expose port
EXPOSE 8080

# Start PHP built-in server
CMD ["/start.sh"]
