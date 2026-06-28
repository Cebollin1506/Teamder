<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";

$input = json_input();
$email = strtolower(trim($input["email"] ?? ""));
$otp = trim((string) ($input["otp"] ?? ""));
if (!filter_var($email, FILTER_VALIDATE_EMAIL) || !preg_match('/^\d{6}$/', $otp)) {
    json_response(["message" => "El codigo no es valido o ya vencio."], 422);
}

$statement = $pdo->prepare("SELECT prt.otp FROM password_reset_tokens prt INNER JOIN users u ON u.id = prt.user_id WHERE u.email = :email AND prt.used = 0 AND prt.expires_at > CURRENT_TIMESTAMP() ORDER BY prt.created_at DESC LIMIT 1");
$statement->execute(["email" => $email]);
$token = $statement->fetch();
if (!$token || !password_verify($otp, $token["otp"])) {
    json_response(["message" => "El codigo no es valido o ya vencio."], 422);
}

json_response(["message" => "Codigo verificado correctamente."]);
