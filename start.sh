#!/bin/bash

# Railway uses port 8080 by default
PORT="${PORT:-8080}"

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

echo "Starting Apache on port $PORT"

# Start Apache
exec /usr/sbin/apache2ctl -D FOREGROUND
