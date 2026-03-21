<?php
// TEST LOGIN PAGE - Bypasses Telegram verification for testing
session_start();

// Simulate successful login
$_SESSION['uid'] = 8323636179;
$_SESSION['uname'] = 'Mr_Vempiree';
$_SESSION['last_login'] = time();

// Redirect to dashboard
header('Location: /app/dashboard');
exit;
