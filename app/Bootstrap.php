<?php
/**
 * Bootstrap: env loader (no putenv) + hardened session
 * PHP 8.1+
 * 
 * Supports:
 * - Local .env file
 * - Railway environment variables (via ${{VARIABLE_NAME}} syntax)
 * - Railway MySQL auto-injected variables
 */
declare(strict_types=1);

// ---------- timezone ----------
@date_default_timezone_set('UTC');

// ---------- Railway/Platform environment variable resolver ----------
// Railway uses ${{VARIABLE_NAME}} syntax for dynamic variables
function resolveEnvValue(string $value): string {
    // Handle Railway's ${{VAR}} syntax
    if (preg_match('/\$\{\{([^}]+)\}\}/', $value, $matches)) {
        $varName = $matches[1];
        $envValue = $_ENV[$varName] ?? $_SERVER[$varName] ?? getenv($varName);
        if ($envValue !== false && $envValue !== null) {
            return str_replace($matches[0], (string)$envValue, $value);
        }
    }
    return $value;
}

// ---------- tiny .env loader (NO putenv) ----------
$envFile = __DIR__ . '/../.env';

// Railway variables already in $_ENV from Docker, don't override them
$railwayVars = ['TELEGRAM_BOT_TOKEN', 'TELEGRAM_BOT_USERNAME', 'DB_DSN', 'DB_USER', 'DB_PASS', 'MYSQLHOST', 'MYSQLPORT', 'MYSQLUSER', 'MYSQLPASSWORD', 'MYSQLDATABASE'];

if (is_file($envFile)) {
    $lines = @file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
    foreach ($lines as $raw) {
        $t = trim($raw);
        if ($t === '' || $t[0] === '#') continue;
        if (!str_contains($t, '=')) continue;

        [$k, $v] = explode('=', $t, 2);
        $k = trim($k);
        
        // Skip if already set by Railway (environment variables take precedence)
        if (in_array($k, $railwayVars, true) && !empty($_ENV[$k])) continue;
        
        // strip wrapping quotes & whitespace
        $v = trim($v);
        if ($v !== '' && ($v[0] === '"' || $v[0] === "'")) {
            $q = $v[0];
            if (str_ends_with($v, $q)) $v = substr($v, 1, -1);
        }
        // Resolve Railway variables
        $v = resolveEnvValue($v);
        // Prefer $_ENV/$_SERVER to share within app without OS env
        $_ENV[$k]    = $v;
        $_SERVER[$k] = $v;
        // DO NOT call putenv(): it may be disabled on this host
    }
}

// ---------- Railway Database Auto-Detection ----------
// If Railway MySQL variables exist and DB_DSN is not set, build it
if (empty($_ENV['DB_DSN']) && !empty($_ENV['MYSQLHOST'])) {
    $dbHost = $_ENV['MYSQLHOST'] ?? '127.0.0.1';
    $dbPort = $_ENV['MYSQLPORT'] ?? '3306';
    $dbName = $_ENV['MYSQLDATABASE'] ?? 'railway';
    $_ENV['DB_DSN'] = "mysql:host={$dbHost};port={$dbPort};dbname={$dbName};charset=utf8mb4";
    $_SERVER['DB_DSN'] = $_ENV['DB_DSN'];
}

// Railway auto-injected DB credentials
if (!empty($_ENV['MYSQLUSER'])) {
    $_ENV['DB_USER'] = $_ENV['MYSQLUSER'];
    $_SERVER['DB_USER'] = $_ENV['DB_USER'];
}
if (!empty($_ENV['MYSQLPASSWORD'])) {
    $_ENV['DB_PASS'] = $_ENV['MYSQLPASSWORD'];
    $_SERVER['DB_PASS'] = $_ENV['DB_PASS'];
}

// ---------- derive host / https ----------
$host = $_SERVER['HTTP_HOST'] ?? ($_ENV['APP_HOST'] ?? 'databasemanaging.com');
$root = preg_replace('/^www\./i', '', $host);
$isHttps = (
    (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
    || (($_SERVER['SERVER_PORT'] ?? '') === '443')
    || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https')
    || (!empty($_ENV['RAILWAY']) && $_ENV['RAILWAY'] === 'true') // Railway forces HTTPS
);

// ---------- session knobs (env overrides) ----------
$SESSION_NAME     = $_ENV['SESSION_NAME']            ?? 'CYBORXSESSID';
// Railway: Use RAILWAY_PUBLIC_DOMAIN if available, otherwise use configured domain
$railwayDomain = $_ENV['RAILWAY_PUBLIC_DOMAIN'] ?? null;
if ($railwayDomain) {
    $COOKIE_DOMAIN = '.' . $railwayDomain;
} else {
    $COOKIE_DOMAIN = $_ENV['SESSION_COOKIE_DOMAIN'] ?? ('.' . $root);
}
$COOKIE_LIFETIME  = (int)($_ENV['SESSION_COOKIE_LIFETIME'] ?? 7200);
$GC_MAXLIFETIME   = (int)($_ENV['SESSION_GC_MAXLIFETIME']  ?? 7200);
$SAMESITE         = $_ENV['SESSION_SAMESITE']        ?? 'Lax';   // OAuth redirect → Lax OK
$IDLE_MAX         = (int)($_ENV['SESSION_IDLE_MAX']  ?? 7200);

// ---------- dedicated session path ----------
$customSessPath = __DIR__ . '/../_sessions';
if (!is_dir($customSessPath)) {
    @mkdir($customSessPath, 0700, true);
}

// ---------- INI + cookie params ----------
ini_set('session.save_path', $customSessPath);
ini_set('session.gc_maxlifetime', (string)$GC_MAXLIFETIME);
ini_set('session.cookie_lifetime', (string)$COOKIE_LIFETIME);
ini_set('session.use_strict_mode', '1');
ini_set('session.use_only_cookies', '1');
ini_set('session.sid_length', '48');
ini_set('session.sid_bits_per_character', '6');

session_name($SESSION_NAME);
session_set_cookie_params([
    'lifetime' => $COOKIE_LIFETIME,
    'path'     => '/',
    'domain'   => $COOKIE_DOMAIN,   // .cyborx.net
    'secure'   => $isHttps,
    'httponly' => true,
    'samesite' => $SAMESITE,        // Lax | Strict | None(HTTPS)
]);

// ---------- start session ----------
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}


