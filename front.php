<?php
// Front controller for PHP built-in server
$request_uri = $_SERVER['REQUEST_URI'] ?? '/';
$path = parse_url($request_uri, PHP_URL_PATH);
$query = parse_url($request_uri, PHP_URL_QUERY);

// Static files - let PHP serve them
if (file_exists(__DIR__ . $path) && is_file(__DIR__ . $path)) {
    $ext = pathinfo($path, PATHINFO_EXTENSION);
    if (in_array($ext, ['css', 'js', 'png', 'jpg', 'jpeg', 'gif', 'ico', 'svg', 'woff', 'woff2', 'ttf', 'eot', 'mp3', 'webp'])) {
        return false;
    }
}

// API routes
if (strpos($path, '/api/') === 0) {
    $file = __DIR__ . $path;
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

// Handle /app/* routes
if (strpos($path, '/app/') === 0) {
    $_GET['path'] = ltrim($path, '/');
    require __DIR__ . '/index.php';
    exit;
}

// Root and other routes
if (!isset($_GET['path'])) {
    $_GET['path'] = trim($path, '/');
}
require __DIR__ . '/index.php';
