<?php
declare(strict_types=1);

namespace App;

final class Db
{
    public static function pdo(): ?\PDO
    {
        // Railway environment variables
        $host = $_ENV['MYSQLHOST'] ?? $_ENV['DB_HOST'] ?? '127.0.0.1';
        $port = $_ENV['MYSQLPORT'] ?? '3306';
        $dbname = $_ENV['MYSQLDATABASE'] ?? $_ENV['DB_NAME'] ?? 'railway';
        $user = $_ENV['MYSQLUSER'] ?? $_ENV['DB_USER'] ?? 'root';
        $pass = $_ENV['MYSQLPASSWORD'] ?? $_ENV['DB_PASS'] ?? '';
        
        // Build DSN
        $dsn = "mysql:host={$host};port={$port};dbname={$dbname};charset=utf8mb4";

        // Check PDO available
        if (!class_exists(\PDO::class)) {
            error_log('PDO not available');
            return null;
        }

        try {
            $pdo = new \PDO($dsn, $user, $pass, [
                \PDO::ATTR_ERRMODE            => \PDO::ERRMODE_EXCEPTION,
                \PDO::ATTR_DEFAULT_FETCH_MODE => \PDO::FETCH_ASSOC,
                \PDO::ATTR_EMULATE_PREPARES   => false,
                \PDO::ATTR_TIMEOUT            => 5,
                \PDO::ATTR_CONNECTION_STATUS => true,
            ]);

            return $pdo;
        } catch (\PDOException $e) {
            error_log('DB connect error: ' . $e->getMessage());
            return null;
        }
    }
}
