#!/bin/bash

# Railway uses port 8080 by default
PORT="${PORT:-8080}"

# Export all environment variables for Apache
export TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
export TELEGRAM_BOT_USERNAME="${TELEGRAM_BOT_USERNAME}"
export TELEGRAM_ADMIN_USERNAME="${TELEGRAM_ADMIN_USERNAME}"
export TELEGRAM_ADMIN_ID="${TELEGRAM_ADMIN_ID}"
export TELEGRAM_ANNOUNCE_CHAT_ID="${TELEGRAM_ANNOUNCE_CHAT_ID}"
export TELEGRAM_GROUP_LINK="${TELEGRAM_GROUP_LINK}"
export TELEGRAM_REQUIRE_ALLOWLIST="${TELEGRAM_REQUIRE_ALLOWLIST}"
export APP_DEBUG="${APP_DEBUG}"
export APP_HOST="${APP_HOST}"
export SESSION_COOKIE_DOMAIN="${SESSION_COOKIE_DOMAIN}"
export SESSION_COOKIE_LIFETIME="${SESSION_COOKIE_LIFETIME}"
export SESSION_GC_MAXLIFETIME="${SESSION_GC_MAXLIFETIME}"
export SESSION_IDLE_MAX="${SESSION_IDLE_MAX}"
export SESSION_NAME="${SESSION_NAME}"
export SESSION_SAMESITE="${SESSION_SAMESITE}"
export DB_DSN="${DB_DSN}"
export DB_USER="${DB_USER}"
export DB_PASS="${DB_PASS}"
export MYSQLHOST="${MYSQLHOST}"
export MYSQLPORT="${MYSQLPORT}"
export MYSQLUSER="${MYSQLUSER}"
export MYSQLPASSWORD="${MYSQLPASSWORD}"
export MYSQLDATABASE="${MYSQLDATABASE}"

echo "Starting Apache on port $PORT"
echo "TELEGRAM_BOT_USERNAME is set: $TELEGRAM_BOT_USERNAME"

# Update Apache ports.conf
echo "Listen $PORT" > /etc/apache2/ports.conf

# Update VirtualHost
cat > /etc/apache2/sites-enabled/000-default.conf << EOF
<VirtualHost *:$PORT>
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Set environment variables in Apache config
cat >> /etc/apache2/envvars << EOF
export TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
export TELEGRAM_BOT_USERNAME="$TELEGRAM_BOT_USERNAME"
export TELEGRAM_ADMIN_USERNAME="$TELEGRAM_ADMIN_USERNAME"
export TELEGRAM_ADMIN_ID="$TELEGRAM_ADMIN_ID"
export TELEGRAM_ANNOUNCE_CHAT_ID="$TELEGRAM_ANNOUNCE_CHAT_ID"
export APP_DEBUG="$APP_DEBUG"
export APP_HOST="$APP_HOST"
export DB_DSN="$DB_DSN"
export DB_USER="$DB_USER"
export DB_PASS="$DB_PASS"
EOF

# Start Apache
exec /usr/sbin/apache2ctl -D FOREGROUND
