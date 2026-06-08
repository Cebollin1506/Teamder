<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";

function notify_rating(PDO $pdo, int $usuarioId, string $tema): void
{
    $statement = $pdo->prepare("
        INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo)
        VALUES (:usuario_id, 'Nueva evaluacion', :mensaje, 'evaluacion_creada')
    ");
    $statement->execute([
        "usuario_id" => $usuarioId,
        "mensaje" => "Se registro una nueva evaluacion para la tutoria {$tema}.",
    ]);
}

$userId = auth_user_id();

if (!$userId) {
    json_response(["message" => "Token invalido o faltante."], 401);
}

if ($_SERVER["REQUEST_METHOD"] === "GET") {
    $ratingsStatement = $pdo->prepare("
        SELECT
            ct.*,
            t.tema AS tutoria_tema,
            alumno.name AS alumno_name,
            tutor.id AS tutor_id,
            tutor.name AS tutor_name
        FROM calificaciones_tutoria ct
        INNER JOIN tutorias t ON t.id = ct.tutoria_id
        INNER JOIN users alumno ON alumno.id = ct.alumno_id
        INNER JOIN users tutor ON tutor.id = t.tutor_id
        WHERE ct.alumno_id = :user_id OR t.tutor_id = :user_id
        ORDER BY ct.fecha_calificacion DESC
    ");
    $ratingsStatement->execute(["user_id" => $userId]);

    $averagesStatement = $pdo->query("
        SELECT
            tutor.id AS tutor_id,
            tutor.name AS tutor_name,
            ROUND(AVG(ct.calificacion), 2) AS promedio,
            COUNT(*) AS total
        FROM calificaciones_tutoria ct
        INNER JOIN tutorias t ON t.id = ct.tutoria_id
        INNER JOIN users tutor ON tutor.id = t.tutor_id
        GROUP BY tutor.id, tutor.name
        ORDER BY promedio DESC, total DESC
    ");

    json_response([
        "calificaciones" => $ratingsStatement->fetchAll(),
        "promedios" => $averagesStatement->fetchAll(),
    ]);
}

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    json_response(["message" => "Metodo no permitido."], 405);
}

$input = json_input();
$tutoriaId = (int) ($input["tutoria_id"] ?? 0);
$calificacion = (int) ($input["calificacion"] ?? 0);
$comentario = trim($input["comentario"] ?? "");

if ($tutoriaId <= 0 || $calificacion < 1 || $calificacion > 5) {
    json_response(["message" => "Tutoria y calificacion de 1 a 5 son obligatorias."], 422);
}

$tutoriaStatement = $pdo->prepare("SELECT * FROM tutorias WHERE id = :id LIMIT 1");
$tutoriaStatement->execute(["id" => $tutoriaId]);
$tutoria = $tutoriaStatement->fetch();

if (!$tutoria) {
    json_response(["message" => "Tutoria no encontrada."], 404);
}

if ((int) $tutoria["alumno_id"] !== $userId) {
    json_response(["message" => "Solo el alumno de la tutoria puede evaluarla."], 403);
}

if ($tutoria["estado"] !== "finalizada") {
    json_response(["message" => "Solo puedes evaluar tutorias finalizadas."], 422);
}

$existingStatement = $pdo->prepare("
    SELECT id
    FROM calificaciones_tutoria
    WHERE tutoria_id = :tutoria_id AND alumno_id = :alumno_id
    LIMIT 1
");
$existingStatement->execute([
    "tutoria_id" => $tutoriaId,
    "alumno_id" => $userId,
]);

if ($existingStatement->fetch()) {
    json_response(["message" => "Esta tutoria ya fue evaluada."], 409);
}

$pdo->beginTransaction();

$statement = $pdo->prepare("
    INSERT INTO calificaciones_tutoria (tutoria_id, alumno_id, calificacion, comentario)
    VALUES (:tutoria_id, :alumno_id, :calificacion, :comentario)
");
$statement->execute([
    "tutoria_id" => $tutoriaId,
    "alumno_id" => $userId,
    "calificacion" => $calificacion,
    "comentario" => $comentario,
]);

notify_rating($pdo, (int) $tutoria["tutor_id"], $tutoria["tema"]);

$pdo->commit();

json_response([
    "message" => "Calificacion registrada correctamente.",
    "id" => (int) $pdo->lastInsertId(),
], 201);
