<?php
// Router for PHP built-in server
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Static files - let PHP serve them directly
if (file_exists(__DIR__ . $uri) && is_file(__DIR__ . $uri) && 
    preg_match('/\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|mp3|webp)$/i', $uri)) {
    return false;
}

// API routes
if (strpos($uri, '/api/') === 0) {
    $file = __DIR__ . $uri . '.php';
    if (file_exists($file)) {
        require $file;
        exit;
    }
    // Try without .php extension
    $uri_parts = explode('/', trim($uri, '/'));
    if (count($uri_parts) >= 2) {
        $file = __DIR__ . '/api/' . $uri_parts[1] . '.php';
        if (file_exists($file)) {
            require $file;
            exit;
        }
    }
}

// App routes - everything goes through index.php
require __DIR__ . '/index.php';
