FROM nginx:alpine

# Install PHP
RUN apk add --no-cache \
    php82 \
    php82-fpm \
    php82-pdo \
    php82_pdo_mysql \
    php82-phar \
    php82_opcache \
    php82_mbstring \
    php82_curl \
    php82_gd \
    php82_zip \
    php82_bcmath \
    php82_exif \
    php82_pcntl \
    php82_session \
    php82_intl \
    php82_xml \
    curl

# Configure Nginx
COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /var/www/html

COPY . .

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create directories
RUN mkdir -p _sessions storage/logs \
    && chmod -R 777 _sessions storage logs vendor \
    && composer install --no-dev --optimize-autoloader || true

EXPOSE 80

CMD ["sh", "-c", "php-fpm82 && nginx -g 'daemon off;'"]
