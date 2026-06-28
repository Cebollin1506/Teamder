<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";

$input = json_input();
$email = strtolower(trim($input["email"] ?? ""));
$otp = trim((string) ($input["otp"] ?? ""));
$password = (string) ($input["password"] ?? "");
if (!filter_var($email, FILTER_VALIDATE_EMAIL) || !preg_match('/^\d{6}$/', $otp)) {
    json_response(["message" => "La solicitud de recuperacion no es valida."], 422);
}
if (!preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/', $password)) {
    json_response(["message" => "La contrasena debe tener 8 caracteres, mayuscula, minuscula y numero."], 422);
}

try {
    $pdo->beginTransaction();
    $statement = $pdo->prepare("SELECT prt.id, prt.otp, prt.user_id FROM password_reset_tokens prt INNER JOIN users u ON u.id = prt.user_id WHERE u.email = :email AND prt.used = 0 AND prt.expires_at > CURRENT_TIMESTAMP() ORDER BY prt.created_at DESC LIMIT 1 FOR UPDATE");
    $statement->execute(["email" => $email]);
    $token = $statement->fetch();
    if (!$token || !password_verify($otp, $token["otp"])) {
        $pdo->rollBack();
        json_response(["message" => "El codigo no es valido o ya vencio."], 422);
    }
    $updateUser = $pdo->prepare("UPDATE users SET password_hash = :password_hash WHERE id = :id");
    $updateUser->execute(["password_hash" => password_hash($password, PASSWORD_DEFAULT), "id" => $token["user_id"]]);
    $useToken = $pdo->prepare("UPDATE password_reset_tokens SET used = 1 WHERE id = :id");
    $useToken->execute(["id" => $token["id"]]);
    $pdo->commit();
} catch (Throwable $error) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    json_response(["message" => "No pudimos actualizar la contrasena."], 500);
}

json_response(["message" => "Contrasena actualizada correctamente."]);
