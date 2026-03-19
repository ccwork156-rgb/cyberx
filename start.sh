#!/bin/bash

# Get port from Railway or default to 80
PORT="${PORT:-80}"

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

# Start Apache
exec /usr/sbin/apache2ctl -D FOREGROUND
