<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";

function create_notification(PDO $pdo, int $usuarioId, string $titulo, string $mensaje, string $tipo): void
{
    $statement = $pdo->prepare("
        INSERT INTO notificaciones (usuario_id, titulo, mensaje, tipo)
        VALUES (:usuario_id, :titulo, :mensaje, :tipo)
    ");

    $statement->execute([
        "usuario_id" => $usuarioId,
        "titulo" => $titulo,
        "mensaje" => $mensaje,
        "tipo" => $tipo,
    ]);
}

$userId = auth_user_id();

if (!$userId) {
    json_response(["message" => "Token invalido o faltante."], 401);
}

if ($_SERVER["REQUEST_METHOD"] === "GET") {
    $statement = $pdo->prepare("
        SELECT
            t.*,
            alumno.name AS alumno_name,
            tutor.name AS tutor_name,
            tutor.subject AS tutor_subject
        FROM tutorias t
        INNER JOIN users alumno ON alumno.id = t.alumno_id
        INNER JOIN users tutor ON tutor.id = t.tutor_id
        WHERE t.alumno_id = :user_id OR t.tutor_id = :user_id
        ORDER BY t.fecha DESC, t.hora DESC
    ");
    $statement->execute(["user_id" => $userId]);

    json_response(["tutorias" => $statement->fetchAll()]);
}

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $input = json_input();
    $tutorId = (int) ($input["tutor_id"] ?? 0);
    $tema = trim($input["tema"] ?? "");
    $descripcion = trim($input["descripcion"] ?? "");
    $fecha = trim($input["fecha"] ?? "");
    $hora = trim($input["hora"] ?? "");

    if ($tutorId <= 0 || $tema === "" || $fecha === "" || $hora === "") {
        json_response(["message" => "Tutor, tema, fecha y hora son obligatorios."], 422);
    }

    if (!preg_match("/^\d{4}-\d{2}-\d{2}$/", $fecha) || !preg_match("/^\d{2}:\d{2}$/", $hora)) {
        json_response(["message" => "Fecha u hora con formato invalido."], 422);
    }

    $tutorStatement = $pdo->prepare("SELECT id, name FROM users WHERE id = :id AND role = 'tutor' LIMIT 1");
    $tutorStatement->execute(["id" => $tutorId]);
    $tutor = $tutorStatement->fetch();

    if (!$tutor) {
        json_response(["message" => "El tutor seleccionado no existe."], 404);
    }

    if ($tutorId === $userId) {
        json_response(["message" => "No puedes agendar una tutoria contigo mismo."], 422);
    }

    $conflictStatement = $pdo->prepare("
        SELECT id
        FROM tutorias
        WHERE fecha = :fecha
          AND hora = :hora
          AND estado IN ('pendiente', 'confirmada')
          AND (tutor_id = :tutor_id OR alumno_id = :alumno_id)
        LIMIT 1
    ");
    $conflictStatement->execute([
        "fecha" => $fecha,
        "hora" => $hora,
        "tutor_id" => $tutorId,
        "alumno_id" => $userId,
    ]);

    if ($conflictStatement->fetch()) {
        json_response(["message" => "Ya existe una tutoria activa en ese horario."], 409);
    }

    $pdo->beginTransaction();

    $statement = $pdo->prepare("
        INSERT INTO tutorias (alumno_id, tutor_id, tema, descripcion, fecha, hora, estado)
        VALUES (:alumno_id, :tutor_id, :tema, :descripcion, :fecha, :hora, 'pendiente')
    ");
    $statement->execute([
        "alumno_id" => $userId,
        "tutor_id" => $tutorId,
        "tema" => $tema,
        "descripcion" => $descripcion,
        "fecha" => $fecha,
        "hora" => $hora,
    ]);

    $tutoriaId = (int) $pdo->lastInsertId();
    create_notification($pdo, $userId, "Tutoria creada", "Tu solicitud de tutoria quedo pendiente de confirmacion.", "tutoria_creada");
    create_notification($pdo, $tutorId, "Nueva tutoria solicitada", "Tienes una nueva solicitud para {$tema}.", "tutoria_creada");

    $pdo->commit();

    json_response([
        "message" => "Tutoria creada correctamente.",
        "id" => $tutoriaId,
    ], 201);
}

if ($_SERVER["REQUEST_METHOD"] === "PATCH") {
    $input = json_input();
    $id = (int) ($input["id"] ?? 0);
    $estado = $input["estado"] ?? null;
    $fecha = isset($input["fecha"]) ? trim($input["fecha"]) : null;
    $hora = isset($input["hora"]) ? trim($input["hora"]) : null;
    $allowedStatuses = ["pendiente", "confirmada", "cancelada", "finalizada"];

    if ($id <= 0) {
        json_response(["message" => "Tutoria invalida."], 422);
    }

    $currentStatement = $pdo->prepare("SELECT * FROM tutorias WHERE id = :id LIMIT 1");
    $currentStatement->execute(["id" => $id]);
    $current = $currentStatement->fetch();

    if (!$current) {
        json_response(["message" => "Tutoria no encontrada."], 404);
    }

    if ((int) $current["alumno_id"] !== $userId && (int) $current["tutor_id"] !== $userId) {
        json_response(["message" => "No tienes permiso para actualizar esta tutoria."], 403);
    }

    $nextEstado = $estado !== null && in_array($estado, $allowedStatuses, true) ? $estado : $current["estado"];
    $nextFecha = $fecha !== null && $fecha !== "" ? $fecha : $current["fecha"];
    $nextHora = $hora !== null && $hora !== "" ? $hora : substr($current["hora"], 0, 5);

    if (!preg_match("/^\d{4}-\d{2}-\d{2}$/", $nextFecha) || !preg_match("/^\d{2}:\d{2}$/", $nextHora)) {
        json_response(["message" => "Fecha u hora con formato invalido."], 422);
    }

    if (in_array($nextEstado, ["pendiente", "confirmada"], true)) {
        $conflictStatement = $pdo->prepare("
            SELECT id
            FROM tutorias
            WHERE id <> :id
              AND fecha = :fecha
              AND hora = :hora
              AND estado IN ('pendiente', 'confirmada')
              AND (tutor_id = :tutor_id OR alumno_id = :alumno_id)
            LIMIT 1
        ");
        $conflictStatement->execute([
            "id" => $id,
            "fecha" => $nextFecha,
            "hora" => $nextHora,
            "tutor_id" => $current["tutor_id"],
            "alumno_id" => $current["alumno_id"],
        ]);

        if ($conflictStatement->fetch()) {
            json_response(["message" => "Ya existe una tutoria activa en ese horario."], 409);
        }
    }

    $pdo->beginTransaction();

    $statement = $pdo->prepare("
        UPDATE tutorias
        SET estado = :estado, fecha = :fecha, hora = :hora
        WHERE id = :id
    ");
    $statement->execute([
        "estado" => $nextEstado,
        "fecha" => $nextFecha,
        "hora" => $nextHora,
        "id" => $id,
    ]);

    $message = "La tutoria " . $current["tema"] . " ahora esta en estado " . $nextEstado . ".";
    $type = $nextEstado === "finalizada" ? "tutoria_finalizada" : "tutoria_estado";

    if ($nextFecha !== $current["fecha"] || $nextHora !== substr($current["hora"], 0, 5)) {
        $message = "La tutoria " . $current["tema"] . " cambio a " . $nextFecha . " " . $nextHora . ".";
        $type = "tutoria_horario";
    }

    create_notification($pdo, (int) $current["alumno_id"], "Actualizacion de tutoria", $message, $type);
    create_notification($pdo, (int) $current["tutor_id"], "Actualizacion de tutoria", $message, $type);

    $pdo->commit();

    json_response(["message" => "Tutoria actualizada correctamente."]);
}

json_response(["message" => "Metodo no permitido."], 405);
