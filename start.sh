#!/bin/bash
cd /var/www/html
exec php -S 0.0.0.0:8080 index_router.php
