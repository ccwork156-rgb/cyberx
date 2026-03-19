FROM php:8.2-cli

# Install Apache and system dependencies
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-php8.2 \
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

# Configure Apache properly
RUN rm -f /etc/apache2/sites-enabled/000-default.conf && \
    echo '<VirtualHost *:80>' > /etc/apache2/sites-enabled/cyborx.conf && \
    echo '    DocumentRoot /var/www/html' >> /etc/apache2/sites-enabled/cyborx.conf && \
    echo '    <Directory /var/www/html>' >> /etc/apache2/sites-enabled/cyborx.conf && \
    echo '        Options -Indexes +FollowSymLinks' >> /etc/apache2/sites-enabled/cyborx.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-enabled/cyborx.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-enabled/cyborx.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-enabled/cyborx.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-enabled/cyborx.conf && \
    a2enmod rewrite ssl headers && \
    echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Set permissions
RUN mkdir -p /var/www/html/_sessions \
    && mkdir -p /var/www/html/storage/logs \
    && chmod -R 777 /var/www/html/storage \
    && chmod -R 777 /var/www/html/_sessions \
    && chmod -R 777 /var/www/html/vendor \
    && chown -R www-data:www-data /var/www/html

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader || echo "Composer install skipped"

# Expose port
EXPOSE 80

# Start Apache in foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]
