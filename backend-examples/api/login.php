<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";

$input = json_input();
$email = strtolower(trim($input["email"] ?? ""));
$password = (string) ($input["password"] ?? "");
$ip = substr($_SERVER["REMOTE_ADDR"] ?? "unknown", 0, 45);
$userAgent = substr($_SERVER["HTTP_USER_AGENT"] ?? "unknown", 0, 500);

if (!filter_var($email, FILTER_VALIDATE_EMAIL) || $password === "") {
    json_response(["message" => "Correo y contrasena son obligatorios."], 422);
}

// El limite se aplica por correo e IP para no bloquear a otros usuarios de una red compartida.
$activeBlock = $pdo->prepare("SELECT id FROM login_blocks WHERE email = :email AND ip_address = :ip AND blocked_until > CURRENT_TIMESTAMP() LIMIT 1");
$activeBlock->execute(["email" => $email, "ip" => $ip]);

$failedCount = $pdo->prepare("SELECT COUNT(*) FROM login_attempts WHERE email = :email AND ip_address = :ip AND successful = 0 AND attempted_at >= DATE_SUB(CURRENT_TIMESTAMP(), INTERVAL 15 MINUTE)");
$failedCount->execute(["email" => $email, "ip" => $ip]);
$tooManyAttempts = (int) $failedCount->fetchColumn() >= 5;

if ($activeBlock->fetch() || $tooManyAttempts) {
    $block = $pdo->prepare("INSERT INTO login_blocks (email, ip_address, blocked_until) VALUES (:email, :ip, DATE_ADD(CURRENT_TIMESTAMP(), INTERVAL 15 MINUTE)) ON DUPLICATE KEY UPDATE blocked_until = GREATEST(blocked_until, VALUES(blocked_until))");
    $block->execute(["email" => $email, "ip" => $ip]);
    $attempt = $pdo->prepare("INSERT INTO login_attempts (email, ip_address, user_agent, successful) VALUES (:email, :ip, :user_agent, 0)");
    $attempt->execute(["email" => $email, "ip" => $ip, "user_agent" => $userAgent]);
    json_response(["message" => "Demasiados intentos. Intenta nuevamente más tarde."], 429);
}

$statement = $pdo->prepare("SELECT * FROM users WHERE email = :email LIMIT 1");
$statement->execute(["email" => $email]);
$user = $statement->fetch();
$successful = $user && password_verify($password, $user["password_hash"]);

$attempt = $pdo->prepare("INSERT INTO login_attempts (email, ip_address, user_agent, successful) VALUES (:email, :ip, :user_agent, :successful)");
$attempt->execute(["email" => $email, "ip" => $ip, "user_agent" => $userAgent, "successful" => $successful ? 1 : 0]);

if (!$successful) {
    json_response(["message" => "Correo o contrasena incorrectos."], 401);
}

// Un acceso correcto limpia el historial fallido y cualquier bloqueo de esta identidad.
$clearAttempts = $pdo->prepare("DELETE FROM login_attempts WHERE email = :email AND ip_address = :ip AND successful = 0");
$clearAttempts->execute(["email" => $email, "ip" => $ip]);
$clearBlocks = $pdo->prepare("DELETE FROM login_blocks WHERE email = :email AND ip_address = :ip");
$clearBlocks->execute(["email" => $email, "ip" => $ip]);

json_response([
    "token" => "teamder-token-" . $user["id"],
    "user" => [
        "id" => (int) $user["id"],
        "name" => $user["name"],
        "email" => $user["email"],
        "role" => $user["role"],
        "subject" => $user["subject"],
        "bio" => $user["bio"],
    ],
]);
