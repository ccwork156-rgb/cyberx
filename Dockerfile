FROM php:8.2-apache

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

# Disable default Apache site and MPM conflict
RUN a2dismod mpm_event && a2enmod mpm_prefork rewrite ssl headers

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Set permissions
RUN mkdir -p /var/www/html/_sessions \
    && mkdir -p /var/www/html/storage/logs \
    && chmod -R 777 /var/www/html/storage \
    && chmod -R 777 /var/www/html/_sessions \
    && chmod -R 777 /var/www/html/vendor \
    && chown -R www-data:www-data /var/www/html

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader || echo "Composer install skipped"

# Configure Apache
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf && \
    echo '<Directory /var/www/html>' > /etc/apache2/conf-available/cyborx.conf && \
    echo '    Options -Indexes +FollowSymLinks' >> /etc/apache2/conf-available/cyborx.conf && \
    echo '    AllowOverride All' >> /etc/apache2/conf-available/cyborx.conf && \
    echo '    Require all granted' >> /etc/apache2/conf-available/cyborx.conf && \
    echo '</Directory>' >> /etc/apache2/conf-available/cyborx.conf && \
    a2enconf cyborx

# Expose port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
