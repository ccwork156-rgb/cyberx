<?php
// Simple test file to check if PHP is working
error_reporting(E_ALL);
ini_set('display_errors', '1');

echo "<h1>CyborX PHP Test</h1>";
echo "<p>PHP Version: " . phpversion() . "</p>";
echo "<p>Server: " . $_SERVER['SERVER_SOFTWARE'] . "</p>";

// Test environment variables
echo "<h2>Environment Variables:</h2>";
echo "<ul>";
echo "<li>TELEGRAM_BOT_TOKEN: " . (isset($_ENV['TELEGRAM_BOT_TOKEN']) ? 'SET (length: ' . strlen($_ENV['TELEGRAM_BOT_TOKEN']) . ')' : 'NOT SET') . "</li>";
echo "<li>TELEGRAM_BOT_USERNAME: " . ($_ENV['TELEGRAM_BOT_USERNAME'] ?? 'NOT SET') . "</li>";
echo "<li>TELEGRAM_ANNOUNCE_CHAT_ID: " . ($_ENV['TELEGRAM_ANNOUNCE_CHAT_ID'] ?? 'NOT SET') . "</li>";
echo "<li>APP_DEBUG: " . ($_ENV['APP_DEBUG'] ?? 'NOT SET') . "</li>";
echo "</ul>";

// Test Bootstrap
echo "<h2>Testing Bootstrap:</h2>";
try {
    require_once __DIR__ . '/app/Bootstrap.php';
    echo "<p style='color: green;'>✓ Bootstrap.php loaded successfully</p>";
} catch (Throwable $e) {
    echo "<p style='color: red;'>✗ Bootstrap.php failed: " . $e->getMessage() . "</p>";
}

// Test Database
echo "<h2>Testing Database:</h2>";
try {
    require_once __DIR__ . '/app/Db.php';
    $pdo = \App\Db::pdo();
    echo "<p style='color: green;'>✓ Database connection successful</p>";
} catch (Throwable $e) {
    echo "<p style='color: red;'>✗ Database failed: " . $e->getMessage() . "</p>";
}

echo "<p>Test completed at: " . date('Y-m-d H:i:s') . "</p>";
