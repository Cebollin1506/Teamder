<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";

$input = json_input();
$email = trim($input["email"] ?? "");
$password = $input["password"] ?? "";

if ($email === "" || $password === "") {
    json_response(["message" => "Correo y contrasena son obligatorios."], 422);
}

$statement = $pdo->prepare("SELECT * FROM users WHERE email = :email LIMIT 1");
$statement->execute(["email" => $email]);
$user = $statement->fetch();

if (!$user || !password_verify($password, $user["password_hash"])) {
    json_response(["message" => "Credenciales invalidas."], 401);
}

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
