<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    json_response(["message" => "Usa POST para registrar usuarios."], 405);
}

$input = json_input();

$name = trim($input["name"] ?? "");
$email = trim($input["email"] ?? "");
$password = $input["password"] ?? "";
$requestedRole = $input["role"] ?? "student";
$role = in_array($requestedRole, ["student", "tutor"], true) ? $requestedRole : "student";

if ($name === "" || $email === "" || $password === "") {
    json_response(["message" => "Nombre, correo y contrasena son obligatorios."], 422);
}

$statement = $pdo->prepare("
    INSERT INTO users (name, email, password_hash, role)
    VALUES (:name, :email, :password_hash, :role)
");

try {
    $statement->execute([
        "name" => $name,
        "email" => $email,
        "password_hash" => password_hash($password, PASSWORD_DEFAULT),
        "role" => $role,
    ]);
} catch (PDOException $error) {
    if ($error->getCode() === "23000") {
        json_response(["message" => "Ese correo ya esta registrado."], 409);
    }

    throw $error;
}

$userId = (int) $pdo->lastInsertId();

json_response([
    "token" => "teamder-token-" . $userId,
    "user" => [
        "id" => $userId,
        "name" => $name,
        "email" => $email,
        "role" => $role,
    ],
], 201);
