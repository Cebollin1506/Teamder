<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";

if (isset($_GET["me"])) {
    $userId = auth_user_id();

    if (!$userId) {
        json_response(["message" => "Token invalido o faltante."], 401);
    }

    $statement = $pdo->prepare("
        SELECT id, name, email, role, subject, bio, created_at
        FROM users
        WHERE id = :id
        LIMIT 1
    ");
    $statement->execute(["id" => $userId]);
    $user = $statement->fetch();

    if (!$user) {
        json_response(["message" => "Usuario no encontrado."], 404);
    }

    json_response($user);
}

$statement = $pdo->query("
    SELECT id, name, email, role, subject, bio, created_at
    FROM users
    ORDER BY created_at DESC
");

json_response(["users" => $statement->fetchAll()]);
