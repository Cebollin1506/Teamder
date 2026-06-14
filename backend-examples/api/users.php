<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";

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

    ensure_student_ratings_table($pdo);

    if ($user["role"] === "tutor") {
        $ratingStatement = $pdo->prepare("
            SELECT ROUND(AVG(ct.calificacion), 2) AS promedio, COUNT(*) AS total
            FROM calificaciones_tutoria ct
            INNER JOIN tutorias t ON t.id = ct.tutoria_id
            WHERE t.tutor_id = :user_id
        ");
    } else {
        $ratingStatement = $pdo->prepare("
            SELECT ROUND(AVG(ce.calificacion), 2) AS promedio, COUNT(*) AS total
            FROM calificaciones_estudiante ce
            WHERE ce.alumno_id = :user_id
        ");
    }

    $ratingStatement->execute(["user_id" => $userId]);
    $rating = $ratingStatement->fetch() ?: ["promedio" => null, "total" => 0];
    $user["rating_average"] = $rating["promedio"] !== null ? (float) $rating["promedio"] : null;
    $user["rating_total"] = (int) $rating["total"];

    json_response($user);
}

$statement = $pdo->query("
    SELECT id, name, email, role, subject, bio, created_at
    FROM users
    ORDER BY created_at DESC
");

json_response(["users" => $statement->fetchAll()]);
