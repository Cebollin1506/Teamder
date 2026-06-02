<?php
require_once __DIR__ . "/cors.php";

$host = "localhost";
$database = "teamder";
$username = "root";
$password = "";

try {
    $pdo = new PDO(
        "mysql:host={$host};dbname={$database};charset=utf8mb4",
        $username,
        $password,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]
    );
} catch (PDOException $error) {
    http_response_code(500);
    echo json_encode([
        "message" => "No se pudo conectar a la base de datos.",
        "error" => $error->getMessage(),
    ]);
    exit;
}
