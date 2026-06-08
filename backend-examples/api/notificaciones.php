<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/helpers.php";

$userId = auth_user_id();

if (!$userId) {
    json_response(["message" => "Token invalido o faltante."], 401);
}

if ($_SERVER["REQUEST_METHOD"] === "GET") {
    $statement = $pdo->prepare("
        SELECT id, usuario_id, titulo, mensaje, tipo, leida, fecha_creacion
        FROM notificaciones
        WHERE usuario_id = :usuario_id
        ORDER BY fecha_creacion DESC
    ");
    $statement->execute(["usuario_id" => $userId]);

    json_response(["notifications" => $statement->fetchAll()]);
}

if ($_SERVER["REQUEST_METHOD"] === "PATCH") {
    $input = json_input();
    $markAsRead = (bool) ($input["leida"] ?? true);

    if (!empty($input["all"])) {
        $statement = $pdo->prepare("
            UPDATE notificaciones
            SET leida = :leida
            WHERE usuario_id = :usuario_id
        ");
        $statement->execute([
            "leida" => $markAsRead ? 1 : 0,
            "usuario_id" => $userId,
        ]);

        json_response(["message" => "Notificaciones actualizadas correctamente."]);
    }

    $id = (int) ($input["id"] ?? 0);

    if ($id <= 0) {
        json_response(["message" => "Notificacion invalida."], 422);
    }

    $statement = $pdo->prepare("
        UPDATE notificaciones
        SET leida = :leida
        WHERE id = :id AND usuario_id = :usuario_id
    ");
    $statement->execute([
        "leida" => $markAsRead ? 1 : 0,
        "id" => $id,
        "usuario_id" => $userId,
    ]);

    json_response(["message" => "Notificacion actualizada correctamente."]);
}

json_response(["message" => "Metodo no permitido."], 405);
