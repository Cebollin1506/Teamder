-- TEAMDER - Base de datos completa
-- Compatible con MySQL 8 / MariaDB e importacion desde phpMyAdmin en InfinityFree.
-- Selecciona primero la base asignada por InfinityFree. Este archivo no crea ni selecciona una base.
-- ADVERTENCIA: elimina las tablas TEAMDER existentes antes de volver a crearlas.

SET NAMES utf8mb4;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `login_blocks`;
DROP TABLE IF EXISTS `login_attempts`;
DROP TABLE IF EXISTS `password_reset_tokens`;
DROP TABLE IF EXISTS `calificaciones_estudiante`;
DROP TABLE IF EXISTS `calificaciones_tutoria`;
DROP TABLE IF EXISTS `mensajes_tutoria`;
DROP TABLE IF EXISTS `notificaciones`;
DROP TABLE IF EXISTS `tutorias`;
DROP TABLE IF EXISTS `tutoring_requests`;
DROP TABLE IF EXISTS `users`;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE `users` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `email` varchar(160) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('student','tutor') NOT NULL DEFAULT 'student',
  `subject` varchar(160) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `tutoring_requests` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int UNSIGNED NOT NULL,
  `subject` varchar(160) NOT NULL,
  `title` varchar(180) NOT NULL,
  `description` text NOT NULL,
  `modality` enum('online','presencial','mixta') NOT NULL DEFAULT 'online',
  `status` enum('open','closed') NOT NULL DEFAULT 'open',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_tutoring_requests_user` (`user_id`),
  CONSTRAINT `fk_tutoring_requests_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `tutorias` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `alumno_id` int UNSIGNED NOT NULL,
  `tutor_id` int UNSIGNED NOT NULL,
  `tema` varchar(180) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `estado` enum('pendiente','confirmada','cancelada','finalizada') NOT NULL DEFAULT 'pendiente',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_tutorias_alumno` (`alumno_id`),
  KEY `idx_tutorias_tutor_fecha_hora` (`tutor_id`,`fecha`,`hora`),
  CONSTRAINT `fk_tutorias_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tutorias_tutor` FOREIGN KEY (`tutor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `mensajes_tutoria` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `tutoria_id` int UNSIGNED NOT NULL,
  `emisor_id` int UNSIGNED NOT NULL,
  `mensaje` text NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_mensajes_tutoria_fecha` (`tutoria_id`,`fecha_creacion`),
  KEY `idx_mensajes_emisor` (`emisor_id`),
  CONSTRAINT `fk_mensajes_tutoria_tutoria` FOREIGN KEY (`tutoria_id`) REFERENCES `tutorias` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mensajes_tutoria_emisor` FOREIGN KEY (`emisor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `calificaciones_tutoria` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `tutoria_id` int UNSIGNED NOT NULL,
  `alumno_id` int UNSIGNED NOT NULL,
  `calificacion` tinyint UNSIGNED NOT NULL,
  `comentario` text DEFAULT NULL,
  `fecha_calificacion` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_calificacion_tutoria_alumno` (`tutoria_id`,`alumno_id`),
  KEY `idx_calificaciones_alumno` (`alumno_id`),
  CONSTRAINT `fk_calificaciones_tutoria` FOREIGN KEY (`tutoria_id`) REFERENCES `tutorias` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_calificaciones_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_calificacion_rango` CHECK (`calificacion` BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `calificaciones_estudiante` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `tutoria_id` int UNSIGNED NOT NULL,
  `tutor_id` int UNSIGNED NOT NULL,
  `alumno_id` int UNSIGNED NOT NULL,
  `calificacion` tinyint UNSIGNED NOT NULL,
  `comentario` text DEFAULT NULL,
  `fecha_calificacion` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_calificacion_estudiante_tutoria_tutor` (`tutoria_id`,`tutor_id`),
  KEY `idx_calificaciones_estudiante_alumno` (`alumno_id`),
  KEY `idx_calificaciones_estudiante_tutor` (`tutor_id`),
  CONSTRAINT `fk_calificaciones_estudiante_tutoria` FOREIGN KEY (`tutoria_id`) REFERENCES `tutorias` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_calificaciones_estudiante_tutor` FOREIGN KEY (`tutor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_calificaciones_estudiante_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_calificacion_estudiante_rango` CHECK (`calificacion` BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `notificaciones` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `usuario_id` int UNSIGNED NOT NULL,
  `titulo` varchar(160) NOT NULL,
  `mensaje` text NOT NULL,
  `tipo` varchar(80) NOT NULL,
  `leida` tinyint(1) NOT NULL DEFAULT 0,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_notificaciones_usuario_fecha` (`usuario_id`,`fecha_creacion`),
  CONSTRAINT `fk_notificaciones_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `password_reset_tokens` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int UNSIGNED NOT NULL,
  `otp` varchar(255) NOT NULL COMMENT 'Hash del OTP; nunca se guarda en texto plano',
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_password_reset_user_status` (`user_id`,`used`,`expires_at`),
  CONSTRAINT `fk_password_reset_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `login_attempts` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` varchar(160) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` varchar(500) NOT NULL,
  `successful` tinyint(1) NOT NULL DEFAULT 0,
  `attempted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_login_attempt_limit` (`email`,`ip_address`,`successful`,`attempted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `login_blocks` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` varchar(160) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `blocked_until` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_login_block_identity` (`email`,`ip_address`),
  KEY `idx_login_blocks_expiration` (`blocked_until`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Las cuentas se crean desde el formulario de registro para que sus contrasenas
-- siempre se almacenen con password_hash(). No se incluyen usuarios de prueba.
