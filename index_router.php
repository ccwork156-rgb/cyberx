<?php
// Simple redirect for /app/* URLs to work with PHP built-in server
$request_uri = $_SERVER['REQUEST_URI'] ?? '/';
$path = parse_url($request_uri, PHP_URL_PATH);

// If it's an /app/* URL, redirect to index.php with path parameter
if (strpos($path, '/app/') === 0) {
    $query = http_build_query(['path' => ltrim($path, '/')]);
    header("Location: /?$query", true, 302);
    exit;
}

// Otherwise use the router
require __DIR__ . '/router.php';
