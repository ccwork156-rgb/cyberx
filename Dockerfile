FROM debian:bookworm-slim

# Install PHP 8.2 Apache with all dependencies
# Note: pcntl, exif, bcmath are included in base php8.2 packages
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-php8.2 \
    php8.2 \
    php8.2-cli \
    php8.2-common \
    php8.2-mysql \
    php8.2-xml \
    php8.2-zip \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-curl \
    php8.2-bcmath \
    git \
    curl \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# CRITICAL: Remove ALL MPM modules first, then enable only prefork
RUN a2dismod mpm_event mpm_worker mpm_prefork 2>/dev/null || true \
    && a2enmod mpm_prefork rewrite ssl headers \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy everything
COPY . .

# Clean Apache config - will be updated by start.sh at runtime
RUN rm -rf /etc/apache2/sites-enabled/* \
    && echo 'Listen 8080' > /etc/apache2/ports.conf \
    && echo '<VirtualHost *:8080>' > /etc/apache2/sites-enabled/000-default.conf \
    && echo '    DocumentRoot /var/www/html' >> /etc/apache2/sites-enabled/000-default.conf \
    && echo '    <Directory /var/www/html>' >> /etc/apache2/sites-enabled/000-default.conf \
    && echo '        Options -Indexes +FollowSymLinks' >> /etc/apache2/sites-enabled/000-default.conf \
    && echo '        AllowOverride All' >> /etc/apache2/sites-enabled/000-default.conf \
    && echo '        Require all granted' >> /etc/apache2/sites-enabled/000-default.conf \
    && echo '    </Directory>' >> /etc/apache2/sites-enabled/000-default.conf \
    && echo '</VirtualHost>' >> /etc/apache2/sites-enabled/000-default.conf

# Set permissions
RUN mkdir -p /var/www/html/_sessions \
    && mkdir -p /var/www/html/storage/logs \
    && chmod -R 777 /var/www/html/storage \
    && chmod -R 777 /var/www/html/_sessions \
    && chmod -R 777 /var/www/html/vendor \
    && chown -R www-data:www-data /var/www/html \
    && chown -R www-data:www-data /var/www/html/.htaccess

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction || echo "Composer skipped"

# Copy and make start script executable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose port from Railway or default to 80
ENV PORT=80
EXPOSE 80

# Start Apache with Railway PORT support
CMD ["/start.sh"]
