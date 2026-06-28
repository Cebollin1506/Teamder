<?php
// Copia este archivo como mail-config.php y completa las variables con tu proveedor SMTP.
return [
    "host" => getenv("TEAMDER_SMTP_HOST") ?: "smtp.example.com",
    "port" => (int) (getenv("TEAMDER_SMTP_PORT") ?: 587),
    "username" => getenv("TEAMDER_SMTP_USERNAME") ?: "",
    "password" => getenv("TEAMDER_SMTP_PASSWORD") ?: "",
    "encryption" => getenv("TEAMDER_SMTP_ENCRYPTION") ?: "tls",
    "from_email" => getenv("TEAMDER_SMTP_FROM_EMAIL") ?: "no-reply@teamder.local",
    "from_name" => "TEAMDER",
];
