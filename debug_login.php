<?php
// TEMPORARY DEBUG LOGIN - REMOVE AFTER TESTING
// This bypasses Telegram verification for testing

session_start();

// Simulate login for user ID 8323636179
$_SESSION['uid'] = 8323636179;
$_SESSION['uname'] = 'Mr_Vempiree';
$_SESSION['last_login'] = time();

echo "<h1>Debug Login Successful!</h1>";
echo "<p>Session created for user: 8323636179</p>";
echo "<p>Username: Mr_Vempiree</p>";
echo "<p>Redirecting to dashboard in 3 seconds...</p>";
echo "<script>setTimeout(() => { window.location.href = '/app/dashboard'; }, 3000);</script>";
echo "<p>If not redirected, <a href='/app/dashboard'>click here</a></p>";
