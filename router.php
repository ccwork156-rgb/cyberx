<?php
// Router for PHP built-in server
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Static files - let PHP serve them directly
if (file_exists(__DIR__ . $uri) && is_file(__DIR__ . $uri) && 
    preg_match('/\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|mp3|webp)$/i', $uri)) {
    return false;
}

// API routes - handle directly
if (strpos($uri, '/api/') === 0) {
    $file = __DIR__ . $uri;
    if (file_exists($file . '.php')) {
        require $file . '.php';
        exit;
    }
    if (file_exists($file)) {
        require $file;
        exit;
    }
    http_response_code(404);
    echo json_encode(['error' => 'API endpoint not found']);
    exit;
}

// All other routes go through index.php with path parameter
$_GET['path'] = ltrim($uri, '/');
require __DIR__ . '/index.php';
