<?php
function json_input(): array
{
    $input = json_decode(file_get_contents("php://input"), true);
    return is_array($input) ? $input : [];
}

function json_response(array $data, int $status = 200): void
{
    http_response_code($status);
    echo json_encode($data);
    exit;
}

function auth_user_id(): ?int
{
    $headers = getallheaders();
    $authorization = $headers["Authorization"] ?? $headers["authorization"] ?? "";

    if (!str_starts_with($authorization, "Bearer ")) {
        return null;
    }

    $token = trim(substr($authorization, 7));

    if (!str_starts_with($token, "teamder-token-")) {
        return null;
    }

    return (int) str_replace("teamder-token-", "", $token);
}
