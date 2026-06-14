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

function ensure_student_ratings_table(PDO $pdo): void
{
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS calificaciones_estudiante (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            tutoria_id INT UNSIGNED NOT NULL,
            tutor_id INT UNSIGNED NOT NULL,
            alumno_id INT UNSIGNED NOT NULL,
            calificacion TINYINT UNSIGNED NOT NULL,
            comentario TEXT NULL,
            fecha_calificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_calificacion_estudiante_tutoria_tutor (tutoria_id, tutor_id),
            INDEX idx_calificaciones_estudiante_alumno (alumno_id),
            INDEX idx_calificaciones_estudiante_tutor (tutor_id),
            CONSTRAINT chk_calificacion_estudiante_rango
                CHECK (calificacion BETWEEN 1 AND 5)
        )
    ");
}

$userId = auth_user_id();

if (!$userId) {
    json_response(["message" => "Token invalido o faltante."], 401);
}

ensure_student_ratings_table($pdo);

$userStatement = $pdo->prepare("SELECT id, role FROM users WHERE id = :id LIMIT 1");
$userStatement->execute(["id" => $userId]);
$authUser = $userStatement->fetch();

if (!$authUser) {
    json_response(["message" => "Tu sesion ya no coincide con un usuario registrado. Cierra sesion e inicia de nuevo."], 401);
}

if ($_SERVER["REQUEST_METHOD"] === "GET") {
    $ratingsStatement = $pdo->prepare("
        SELECT
            ct.*,
            COALESCE(t.tema, 'Tutoria no encontrada') AS tutoria_tema,
            COALESCE(alumno.name, 'Alumno no encontrado') AS alumno_name,
            tutor.id AS tutor_id,
            COALESCE(tutor.name, 'Tutor no encontrado') AS tutor_name
        FROM calificaciones_tutoria ct
        LEFT JOIN tutorias t ON t.id = ct.tutoria_id
        LEFT JOIN users alumno ON alumno.id = ct.alumno_id
        LEFT JOIN users tutor ON tutor.id = t.tutor_id
        WHERE ct.alumno_id = :alumno_user_id OR t.tutor_id = :tutor_user_id
        ORDER BY ct.fecha_calificacion DESC
    ");
    $ratingsStatement->execute([
        "alumno_user_id" => $userId,
        "tutor_user_id" => $userId,
    ]);

    $averagesStatement = $pdo->query("
        SELECT
            tutor.id AS tutor_id,
            COALESCE(tutor.name, 'Tutor no encontrado') AS tutor_name,
            ROUND(AVG(ct.calificacion), 2) AS promedio,
            COUNT(*) AS total
        FROM calificaciones_tutoria ct
        LEFT JOIN tutorias t ON t.id = ct.tutoria_id
        LEFT JOIN users tutor ON tutor.id = t.tutor_id
        WHERE t.id IS NOT NULL
        GROUP BY tutor.id, tutor.name
        ORDER BY promedio DESC, total DESC
    ");

    $studentRatingsStatement = $pdo->prepare("
        SELECT
            ce.*,
            COALESCE(t.tema, 'Tutoria no encontrada') AS tutoria_tema,
            COALESCE(alumno.name, 'Alumno no encontrado') AS alumno_name,
            COALESCE(tutor.name, 'Tutor no encontrado') AS tutor_name
        FROM calificaciones_estudiante ce
        LEFT JOIN tutorias t ON t.id = ce.tutoria_id
        LEFT JOIN users alumno ON alumno.id = ce.alumno_id
        LEFT JOIN users tutor ON tutor.id = ce.tutor_id
        WHERE ce.alumno_id = :student_user_id OR ce.tutor_id = :teacher_user_id
        ORDER BY ce.fecha_calificacion DESC
    ");
    $studentRatingsStatement->execute([
        "student_user_id" => $userId,
        "teacher_user_id" => $userId,
    ]);

    $studentAveragesStatement = $pdo->query("
        SELECT
            alumno.id AS alumno_id,
            alumno.name AS alumno_name,
            ROUND(AVG(ce.calificacion), 2) AS promedio,
            COUNT(*) AS total
        FROM calificaciones_estudiante ce
        INNER JOIN users alumno ON alumno.id = ce.alumno_id
        GROUP BY alumno.id, alumno.name
        ORDER BY promedio DESC, total DESC
    ");

    json_response([
        "calificaciones" => $ratingsStatement->fetchAll(),
        "calificaciones_estudiante" => $studentRatingsStatement->fetchAll(),
        "promedios" => $averagesStatement->fetchAll(),
        "promedios_estudiantes" => $studentAveragesStatement->fetchAll(),
        "user" => [
            "id" => (int) $authUser["id"],
            "role" => $authUser["role"],
        ],
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

if (!in_array($tutoria["estado"], ["finalizada", "finalizado", ""], true)) {
    json_response(["message" => "Solo puedes evaluar tutorias finalizadas."], 422);
}

if ($authUser["role"] === "tutor") {
    if ((int) $tutoria["tutor_id"] !== $userId) {
        json_response(["message" => "Solo el tutor asignado puede evaluar al estudiante."], 403);
    }

    $existingStudentRatingStatement = $pdo->prepare("
        SELECT id
        FROM calificaciones_estudiante
        WHERE tutoria_id = :tutoria_id AND tutor_id = :tutor_id
        LIMIT 1
    ");
    $existingStudentRatingStatement->execute([
        "tutoria_id" => $tutoriaId,
        "tutor_id" => $userId,
    ]);

    if ($existingStudentRatingStatement->fetch()) {
        json_response(["message" => "Este estudiante ya fue evaluado para esta tutoria."], 409);
    }

    $pdo->beginTransaction();

    $studentRatingStatement = $pdo->prepare("
        INSERT INTO calificaciones_estudiante (tutoria_id, tutor_id, alumno_id, calificacion, comentario)
        VALUES (:tutoria_id, :tutor_id, :alumno_id, :calificacion, :comentario)
    ");
    $studentRatingStatement->execute([
        "tutoria_id" => $tutoriaId,
        "tutor_id" => $userId,
        "alumno_id" => $tutoria["alumno_id"],
        "calificacion" => $calificacion,
        "comentario" => $comentario,
    ]);

    notify_rating($pdo, (int) $tutoria["alumno_id"], $tutoria["tema"]);

    $pdo->commit();

    json_response([
        "message" => "Calificacion del estudiante registrada correctamente.",
        "id" => (int) $pdo->lastInsertId(),
    ], 201);
}

if ((int) $tutoria["alumno_id"] !== $userId) {
    json_response(["message" => "Solo el alumno de la tutoria puede evaluarla."], 403);
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
