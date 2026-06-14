<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";

function ensure_tutoring_chat_table(PDO $pdo): void
{
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS mensajes_tutoria (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            tutoria_id INT UNSIGNED NOT NULL,
            emisor_id INT UNSIGNED NOT NULL,
            mensaje TEXT NOT NULL,
            fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_mensajes_tutoria_fecha (tutoria_id, fecha_creacion),
            CONSTRAINT fk_mensajes_tutoria_tutoria
                FOREIGN KEY (tutoria_id) REFERENCES tutorias(id)
                ON DELETE CASCADE,
            CONSTRAINT fk_mensajes_tutoria_emisor
                FOREIGN KEY (emisor_id) REFERENCES users(id)
                ON DELETE CASCADE
        )
    ");
}

function tutoring_for_user(PDO $pdo, int $tutoriaId, int $userId): array
{
    $statement = $pdo->prepare("
        SELECT *
        FROM tutorias
        WHERE id = :id
          AND (alumno_id = :alumno_user_id OR tutor_id = :tutor_user_id)
        LIMIT 1
    ");
    $statement->execute([
        "id" => $tutoriaId,
        "alumno_user_id" => $userId,
        "tutor_user_id" => $userId,
    ]);

    $tutoria = $statement->fetch();

    if (!$tutoria) {
        json_response(["message" => "Tutoria no encontrada o sin permiso."], 404);
    }

    return $tutoria;
}

$userId = auth_user_id();

if (!$userId) {
    json_response(["message" => "Token invalido o faltante."], 401);
}

ensure_tutoring_chat_table($pdo);

if ($_SERVER["REQUEST_METHOD"] === "GET") {
    $tutoriaId = (int) ($_GET["tutoria_id"] ?? 0);

    if ($tutoriaId <= 0) {
        json_response(["message" => "Tutoria invalida."], 422);
    }

    $tutoria = tutoring_for_user($pdo, $tutoriaId, $userId);

    $messagesStatement = $pdo->prepare("
        SELECT
            m.id,
            m.tutoria_id,
            m.emisor_id,
            m.mensaje,
            m.fecha_creacion,
            users.name AS emisor_name,
            users.role AS emisor_role
        FROM mensajes_tutoria m
        INNER JOIN users ON users.id = m.emisor_id
        WHERE m.tutoria_id = :tutoria_id
        ORDER BY m.fecha_creacion ASC, m.id ASC
    ");
    $messagesStatement->execute(["tutoria_id" => $tutoriaId]);

    json_response([
        "abierto" => $tutoria["estado"] === "confirmada",
        "mensajes" => $messagesStatement->fetchAll(),
    ]);
}

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $input = json_input();
    $tutoriaId = (int) ($input["tutoria_id"] ?? 0);
    $mensaje = trim($input["mensaje"] ?? "");

    if ($tutoriaId <= 0 || $mensaje === "") {
        json_response(["message" => "Tutoria y mensaje son obligatorios."], 422);
    }

    if (mb_strlen($mensaje) > 1000) {
        json_response(["message" => "El mensaje no puede superar 1000 caracteres."], 422);
    }

    $tutoria = tutoring_for_user($pdo, $tutoriaId, $userId);

    if ($tutoria["estado"] !== "confirmada") {
        json_response(["message" => "El chat solo esta abierto mientras la tutoria esta confirmada."], 403);
    }

    $statement = $pdo->prepare("
        INSERT INTO mensajes_tutoria (tutoria_id, emisor_id, mensaje)
        VALUES (:tutoria_id, :emisor_id, :mensaje)
    ");
    $statement->execute([
        "tutoria_id" => $tutoriaId,
        "emisor_id" => $userId,
        "mensaje" => $mensaje,
    ]);

    json_response([
        "message" => "Mensaje enviado correctamente.",
        "id" => (int) $pdo->lastInsertId(),
    ], 201);
}

json_response(["message" => "Metodo no permitido."], 405);
