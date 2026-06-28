<?php
use PHPMailer\PHPMailer\PHPMailer;

function send_password_reset_otp(string $recipient, string $otp): void
{
    $autoload = __DIR__ . "/../vendor/autoload.php";
    $configFile = __DIR__ . "/mail-config.php";
    if (!is_file($autoload) || !is_file($configFile)) {
        throw new RuntimeException("El servicio de correo no esta configurado.");
    }

    require_once $autoload;
    $config = require $configFile;
    $mail = new PHPMailer(true);
    $mail->isSMTP();
    $mail->Host = $config["host"];
    $mail->SMTPAuth = true;
    $mail->Username = $config["username"];
    $mail->Password = $config["password"];
    $mail->SMTPSecure = $config["encryption"];
    $mail->Port = $config["port"];
    $mail->CharSet = "UTF-8";
    $mail->setFrom($config["from_email"], $config["from_name"]);
    $mail->addAddress($recipient);
    $mail->isHTML(true);
    $mail->Subject = "Codigo de recuperacion de TEAMDER";
    $safeOtp = htmlspecialchars($otp, ENT_QUOTES, "UTF-8");
    $mail->Body = "<p>Tu codigo de recuperacion es:</p><h1>{$safeOtp}</h1><p>Vence en 10 minutos. Si no solicitaste este cambio, ignora este mensaje.</p>";
    $mail->AltBody = "Tu codigo de recuperacion TEAMDER es {$otp}. Vence en 10 minutos.";
    $mail->send();
}
