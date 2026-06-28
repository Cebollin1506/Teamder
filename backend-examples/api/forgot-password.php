<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";
require_once __DIR__ . "/mailer.php";

const FORGOT_RESPONSE = "Si el correo está registrado, recibirás instrucciones para recuperar tu cuenta.";
$input = json_input();
$email = strtolower(trim($input["email"] ?? ""));

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    json_response(["message" => "Ingresa un correo electronico valido."], 422);
}

$statement = $pdo->prepare("SELECT id, email FROM users WHERE email = :email LIMIT 1");
$statement->execute(["email" => $email]);
$user = $statement->fetch();

if ($user) {
    $otp = (string) random_int(100000, 999999);
    try {
        $pdo->beginTransaction();
        $invalidate = $pdo->prepare("UPDATE password_reset_tokens SET used = 1 WHERE user_id = :user_id AND used = 0");
        $invalidate->execute(["user_id" => $user["id"]]);
        $insert = $pdo->prepare("INSERT INTO password_reset_tokens (user_id, otp, expires_at) VALUES (:user_id, :otp, DATE_ADD(CURRENT_TIMESTAMP(), INTERVAL 10 MINUTE))");
        $insert->execute(["user_id" => $user["id"], "otp" => password_hash($otp, PASSWORD_DEFAULT)]);
        send_password_reset_otp($user["email"], $otp);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        // No se expone si el fallo corresponde a una cuenta registrada.
        error_log("TEAMDER forgot password: " . $error->getMessage());
    }
}

json_response(["message" => FORGOT_RESPONSE]);
