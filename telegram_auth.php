<?php
declare(strict_types=1);
// Enable error display for debugging
error_reporting(E_ALL);
ini_set('display_errors', '1');

require_once __DIR__ . '/app/Bootstrap.php';
require_once __DIR__ . '/app/Security.php';
require_once __DIR__ . '/app/Db.php';
require_once __DIR__ . '/app/Telegram.php';

use App\Security;
use App\Db;
use App\Telegram;

/* Debug helper */
function tgdbg(string $m): void {
    $debug = filter_var($_ENV['APP_DEBUG'] ?? 'true', FILTER_VALIDATE_BOOLEAN);
    if ($debug) {
        @file_put_contents(__DIR__ . '/tg-auth-debug.log', '[' . date('c') . "] " . $m . "\n", FILE_APPEND);
    }
}

/* ENV */
$botToken = $_ENV['TELEGRAM_BOT_TOKEN'] ?? '';
$requireAllow = filter_var($_ENV['TELEGRAM_REQUIRE_ALLOWLIST'] ?? 'false', FILTER_VALIDATE_BOOLEAN);
$allowIds = Telegram::parseAllowlist($_ENV['TELEGRAM_ALLOWED_IDS'] ?? '');
$announceChat = $_ENV['TELEGRAM_ANNOUNCE_CHAT_ID'] ?? '-1003278376068';

tgdbg("Bot token set: " . ($botToken !== '' ? 'yes' : 'no'));
tgdbg("Announce chat: {$announceChat}");

/* Guards */
if ($botToken === '' || !isset($_GET['hash'])) { 
    tgdbg('400 missing token/hash - token: ' . ($botToken === '' ? 'empty' : 'set')); 
    http_response_code(400); 
    echo json_encode(['error' => 'missing_config', 'token_set' => $botToken !== '', 'hash_set' => isset($_GET['hash'])]);
    exit; 
}

if (!Telegram::verify($_GET, $botToken, 900)) { 
    tgdbg('400 verify fail'); 
    http_response_code(400); 
    echo json_encode(['error' => 'verify_failed']);
    exit; 
}

/* Extract from Telegram Login Widget */
$tgId = (string)($_GET['id'] ?? '');
$tUser = (string)($_GET['username'] ?? '');
$first = (string)($_GET['first_name'] ?? '');
$last = (string)($_GET['last_name'] ?? '');
$photo = (string)($_GET['photo_url'] ?? '');

tgdbg("User: $tgId, username: $tUser");

/* Allowlist (optional) */
if ($requireAllow && !in_array($tgId, $allowIds, true)) {
    tgdbg("403 not in allowlist id={$tgId}");
    Security::safeRedirect('/?error=unauthorized');
}

/* ---------- must be member of announce group ---------- */
function isChatMember(string $botToken, string $chatId, string $userId): bool {
    $url = "https://api.telegram.org/bot{$botToken}/getChatMember?chat_id=" . urlencode($chatId) . "&user_id=" . urlencode($userId);
    tgdbg("Checking chat member: $url");
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CONNECTTIMEOUT => 8,
        CURLOPT_TIMEOUT => 12,
    ]);
    $res = curl_exec($ch);
    if ($res === false) { 
        tgdbg('tg api error: '.curl_error($ch)); 
        curl_close($ch); 
        return false; 
    }
    curl_close($ch);
    $data = json_decode($res, true);
    if (empty($data['ok'])) {
        tgdbg('tg api response: ' . $res);
        return false;
    }
    $status = (string)($data['result']['status'] ?? 'left');
    return in_array($status, ['creator','administrator','member','restricted'], true);
}

if ($announceChat !== '' && !isChatMember($botToken, $announceChat, $tgId)) {
    tgdbg("join required id={$tgId}");
    Security::safeRedirect('/?error=unauthorized&join=1');
}

/* ---------- Profile completeness check ---------- */
$missing = [];
if ($first === '') $missing[] = 'name';
if ($tUser === '') $missing[] = 'username';
if ($photo === '') $missing[] = 'photo';

if ($missing) {
    $need = implode(',', $missing);
    tgdbg("profile missing for {$tgId}, need={$need}");
    Security::safeRedirect('/?error=profile_missing&need=' . urlencode($need));
    exit;
}

/* DB upsert */
$pdo = Db::pdo();
$res = Telegram::saveUser($pdo, $tgId, $tUser, $first, $last, $photo, 100);

if (!($res['ok'] ?? false)) { 
    tgdbg('500 saveUser failed'); 
    http_response_code(500); 
    echo json_encode(['error' => 'saveUser_failed', 'details' => $res]);
    exit; 
}

$uid = (int)($res['id'] ?? 0);
$status = strtolower((string)($res['status'] ?? 'free'));

tgdbg("User saved: uid=$uid, status=$status");

/* Expiry check */
try {
    $st = $pdo->prepare("SELECT status, expiry_date FROM users WHERE id=:id LIMIT 1");
    $st->execute([':id' => $uid]);
    if ($row = $st->fetch(PDO::FETCH_ASSOC)) {
        $exp = $row['expiry_date'] ?? null;
        if ($exp) {
            $expAt = new DateTime((string)$exp);
            $now = new DateTime('now');
            if ($expAt < $now) {
                $pdo->prepare("UPDATE users SET status='free', credits=10, expiry_date=NULL WHERE id=:id")
                    ->execute([':id'=>$uid]);
                $status = 'free';
            }
        }
    }
} catch (Throwable $e) { 
    tgdbg('expiry check error: '.$e->getMessage()); 
}

/* Session */
$_SESSION['uid'] = $uid;
$_SESSION['uname'] = $tUser !== '' ? $tUser : ('tg_' . $tgId);
$_SESSION['last_login'] = time();
session_regenerate_id(true);

tgdbg("Session created for uid=$uid");

/* Announce to Telegram group */
if ($announceChat !== '') {
    $display = trim(($first.' '.$last)) ?: ($tUser !== '' ? '@'.$tUser : ('User '.$tgId));
    $displaySafe = htmlspecialchars($display, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    $roleLabel = Telegram::roleLabel($status);
    $text = "🌟 <b>{$displaySafe}</b> [{$roleLabel}] just signed in to <b>CyborX</b>.\nLet's make some hits today. ➡️ <a href=\"https://databasemanaging.com/\">Open Dashboard</a>\n";
    Telegram::sendMessage($botToken, $announceChat, $text, 'HTML');
}

/* Redirect to dashboard */
$next = '/app/dashboard';
if (!empty($_GET['state']) && is_string($_GET['state']) && preg_match('~^/app(?:/[\w\-]+)?$~', $_GET['state'])) {
    $next = $_GET['state'];
}

tgdbg("Redirecting to: $next");
Security::safeRedirect($next, '/app/dashboard');
