<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";

if ($_SERVER["REQUEST_METHOD"] === "GET") {
    $statement = $pdo->query("
        SELECT tr.*, u.name AS user_name, u.email AS user_email
        FROM tutoring_requests tr
        INNER JOIN users u ON u.id = tr.user_id
        ORDER BY tr.created_at DESC
    ");

    json_response(["requests" => $statement->fetchAll()]);
}

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    json_response(["message" => "Metodo no permitido."], 405);
}

$userId = auth_user_id();

if (!$userId) {
    json_response(["message" => "Token invalido o faltante."], 401);
}

$input = json_input();
$subject = trim($input["subject"] ?? "");
$title = trim($input["title"] ?? "");
$description = trim($input["description"] ?? "");
$modality = in_array($input["modality"] ?? "online", ["online", "presencial", "mixta"], true)
    ? $input["modality"]
    : "online";

if ($subject === "" || $title === "" || $description === "") {
    json_response(["message" => "Materia, titulo y descripcion son obligatorios."], 422);
}

$statement = $pdo->prepare("
    INSERT INTO tutoring_requests (user_id, subject, title, description, modality)
    VALUES (:user_id, :subject, :title, :description, :modality)
");

$statement->execute([
    "user_id" => $userId,
    "subject" => $subject,
    "title" => $title,
    "description" => $description,
    "modality" => $modality,
]);

json_response([
    "message" => "Solicitud creada correctamente.",
    "id" => (int) $pdo->lastInsertId(),
], 201);
