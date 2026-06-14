-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 14-06-2026 a las 23:41:56
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `teamder`
--
CREATE DATABASE IF NOT EXISTS `teamder` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `teamder`;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `calificaciones_estudiante`
--

CREATE TABLE `calificaciones_estudiante` (
  `id` int(10) UNSIGNED NOT NULL,
  `tutoria_id` int(10) UNSIGNED NOT NULL,
  `tutor_id` int(10) UNSIGNED NOT NULL,
  `alumno_id` int(10) UNSIGNED NOT NULL,
  `calificacion` tinyint(3) UNSIGNED NOT NULL,
  `comentario` text DEFAULT NULL,
  `fecha_calificacion` timestamp NOT NULL DEFAULT current_timestamp()
) ;

--
-- Volcado de datos para la tabla `calificaciones_estudiante`
--

INSERT INTO `calificaciones_estudiante` (`id`, `tutoria_id`, `tutor_id`, `alumno_id`, `calificacion`, `comentario`, `fecha_calificacion`) VALUES
(1, 1, 4, 3, 5, 'ya no funciona gordo', '2026-06-14 21:03:20');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `calificaciones_tutoria`
--

CREATE TABLE `calificaciones_tutoria` (
  `id` int(10) UNSIGNED NOT NULL,
  `tutoria_id` int(10) UNSIGNED NOT NULL,
  `alumno_id` int(10) UNSIGNED NOT NULL,
  `calificacion` tinyint(3) UNSIGNED NOT NULL,
  `comentario` text DEFAULT NULL,
  `fecha_calificacion` timestamp NOT NULL DEFAULT current_timestamp()
) ;

--
-- Volcado de datos para la tabla `calificaciones_tutoria`
--

INSERT INTO `calificaciones_tutoria` (`id`, `tutoria_id`, `alumno_id`, `calificacion`, `comentario`, `fecha_calificacion`) VALUES
(1, 1, 3, 5, 'por fin funciona esta madre lol xd', '2026-06-14 20:57:46');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mensajes_tutoria`
--

CREATE TABLE `mensajes_tutoria` (
  `id` int(10) UNSIGNED NOT NULL,
  `tutoria_id` int(10) UNSIGNED NOT NULL,
  `emisor_id` int(10) UNSIGNED NOT NULL,
  `mensaje` text NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `mensajes_tutoria`
--

INSERT INTO `mensajes_tutoria` (`id`, `tutoria_id`, `emisor_id`, `mensaje`, `fecha_creacion`) VALUES
(1, 2, 4, 'ola como estas', '2026-06-14 21:13:16'),
(2, 2, 3, 'bien y tu', '2026-06-14 21:13:34'),
(3, 2, 4, 'bien tambien, lol', '2026-06-14 21:13:42'),
(4, 2, 3, 'jaja q bueno', '2026-06-14 21:13:52');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificaciones`
--

CREATE TABLE `notificaciones` (
  `id` int(10) UNSIGNED NOT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `titulo` varchar(160) NOT NULL,
  `mensaje` text NOT NULL,
  `tipo` varchar(80) NOT NULL,
  `leida` tinyint(1) NOT NULL DEFAULT 0,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `notificaciones`
--

INSERT INTO `notificaciones` (`id`, `usuario_id`, `titulo`, `mensaje`, `tipo`, `leida`, `fecha_creacion`) VALUES
(1, 3, 'Tutoria creada', 'Tu solicitud de tutoria quedo pendiente de confirmacion.', 'tutoria_creada', 0, '2026-06-14 20:48:51'),
(2, 4, 'Nueva tutoria solicitada', 'Tienes una nueva solicitud para example.', 'tutoria_creada', 0, '2026-06-14 20:48:51'),
(3, 3, 'Actualizacion de tutoria', 'La tutoria example ahora esta en estado confirmada.', 'tutoria_estado', 0, '2026-06-14 20:56:38'),
(4, 4, 'Actualizacion de tutoria', 'La tutoria example ahora esta en estado confirmada.', 'tutoria_estado', 0, '2026-06-14 20:56:38'),
(5, 3, 'Actualizacion de tutoria', 'La tutoria example ahora esta en estado finalizada.', 'tutoria_finalizada', 0, '2026-06-14 20:57:19'),
(6, 4, 'Actualizacion de tutoria', 'La tutoria example ahora esta en estado finalizada.', 'tutoria_finalizada', 0, '2026-06-14 20:57:19'),
(7, 4, 'Nueva evaluacion', 'Se registro una nueva evaluacion para la tutoria example.', 'evaluacion_creada', 0, '2026-06-14 20:57:46'),
(8, 3, 'Nueva evaluacion', 'Se registro una nueva evaluacion para la tutoria example.', 'evaluacion_creada', 0, '2026-06-14 21:03:20'),
(9, 3, 'Tutoria creada', 'Tu solicitud de tutoria quedo pendiente de confirmacion.', 'tutoria_creada', 0, '2026-06-14 21:13:01'),
(10, 4, 'Nueva tutoria solicitada', 'Tienes una nueva solicitud para pruebachat.', 'tutoria_creada', 0, '2026-06-14 21:13:01'),
(11, 3, 'Actualizacion de tutoria', 'La tutoria pruebachat ahora esta en estado confirmada.', 'tutoria_estado', 0, '2026-06-14 21:13:10'),
(12, 4, 'Actualizacion de tutoria', 'La tutoria pruebachat ahora esta en estado confirmada.', 'tutoria_estado', 0, '2026-06-14 21:13:10');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tutorias`
--

CREATE TABLE `tutorias` (
  `id` int(10) UNSIGNED NOT NULL,
  `alumno_id` int(10) UNSIGNED NOT NULL,
  `tutor_id` int(10) UNSIGNED NOT NULL,
  `tema` varchar(180) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `estado` enum('pendiente','confirmada','cancelada','finalizada') NOT NULL DEFAULT 'pendiente',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tutorias`
--

INSERT INTO `tutorias` (`id`, `alumno_id`, `tutor_id`, `tema`, `descripcion`, `fecha`, `hora`, `estado`, `created_at`, `updated_at`) VALUES
(1, 3, 4, 'example', 'hola como estas', '2026-11-11', '15:00:00', 'finalizada', '2026-06-14 20:48:51', '2026-06-14 20:57:19'),
(2, 3, 4, 'pruebachat', 'ola k ase', '1111-11-11', '11:11:00', 'confirmada', '2026-06-14 21:13:01', '2026-06-14 21:13:10');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tutoring_requests`
--

CREATE TABLE `tutoring_requests` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `subject` varchar(160) NOT NULL,
  `title` varchar(180) NOT NULL,
  `description` text NOT NULL,
  `modality` enum('online','presencial','mixta') NOT NULL DEFAULT 'online',
  `status` enum('open','closed') NOT NULL DEFAULT 'open',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `email` varchar(160) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('student','tutor') NOT NULL DEFAULT 'student',
  `subject` varchar(160) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `subject`, `bio`, `created_at`, `updated_at`) VALUES
(1, 'Usuario Demo', 'demo@teamder.com', '$2y$10$wH8xqJ6MdpQn8qJwQo4rvudV5Qz3wlv6YwCDfBzG0I3lYp3RFYx2a', 'student', 'Programacion en PHP', 'Cuenta de prueba para iniciar sesion.', '2026-06-14 20:46:08', '2026-06-14 20:46:08'),
(2, 'Ana Torres', 'ana@teamder.com', '$2y$10$wH8xqJ6MdpQn8qJwQo4rvudV5Qz3wlv6YwCDfBzG0I3lYp3RFYx2a', 'tutor', 'Calculo diferencial', 'Tutora de matematicas.', '2026-06-14 20:46:08', '2026-06-14 20:46:08'),
(3, 'cedrikalumno', 'cedrik1@c', '$2y$10$S8UKGaJv.wM3D2HzshfH5.Jd4yLoVI3pLZLQ6Q.BbUowj5h3fLs/y', 'student', NULL, NULL, '2026-06-14 20:48:04', '2026-06-14 20:48:04'),
(4, 'cedriktutor', 'cedrik2@c', '$2y$10$rYHG7eIL1psRaxhgl6zzzuUkWuUZ2hNeGTDN/wqfhmzHOsslptIie', 'tutor', NULL, NULL, '2026-06-14 20:48:25', '2026-06-14 20:48:25');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `calificaciones_estudiante`
--
ALTER TABLE `calificaciones_estudiante`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_calificacion_estudiante_tutoria_tutor` (`tutoria_id`,`tutor_id`),
  ADD KEY `idx_calificaciones_estudiante_alumno` (`alumno_id`),
  ADD KEY `idx_calificaciones_estudiante_tutor` (`tutor_id`);

--
-- Indices de la tabla `calificaciones_tutoria`
--
ALTER TABLE `calificaciones_tutoria`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_calificacion_tutoria_alumno` (`tutoria_id`,`alumno_id`),
  ADD KEY `idx_calificaciones_alumno` (`alumno_id`);

--
-- Indices de la tabla `mensajes_tutoria`
--
ALTER TABLE `mensajes_tutoria`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_mensajes_tutoria_fecha` (`tutoria_id`,`fecha_creacion`),
  ADD KEY `fk_mensajes_tutoria_emisor` (`emisor_id`);

--
-- Indices de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notificaciones_usuario_fecha` (`usuario_id`,`fecha_creacion`);

--
-- Indices de la tabla `tutorias`
--
ALTER TABLE `tutorias`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tutorias_alumno` (`alumno_id`),
  ADD KEY `idx_tutorias_tutor_fecha_hora` (`tutor_id`,`fecha`,`hora`);

--
-- Indices de la tabla `tutoring_requests`
--
ALTER TABLE `tutoring_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_tutoring_requests_user` (`user_id`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `calificaciones_estudiante`
--
ALTER TABLE `calificaciones_estudiante`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `calificaciones_tutoria`
--
ALTER TABLE `calificaciones_tutoria`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `mensajes_tutoria`
--
ALTER TABLE `mensajes_tutoria`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `tutorias`
--
ALTER TABLE `tutorias`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tutoring_requests`
--
ALTER TABLE `tutoring_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `calificaciones_tutoria`
--
ALTER TABLE `calificaciones_tutoria`
  ADD CONSTRAINT `fk_calificaciones_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_calificaciones_tutoria` FOREIGN KEY (`tutoria_id`) REFERENCES `tutorias` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `mensajes_tutoria`
--
ALTER TABLE `mensajes_tutoria`
  ADD CONSTRAINT `fk_mensajes_tutoria_emisor` FOREIGN KEY (`emisor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_mensajes_tutoria_tutoria` FOREIGN KEY (`tutoria_id`) REFERENCES `tutorias` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD CONSTRAINT `fk_notificaciones_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `tutorias`
--
ALTER TABLE `tutorias`
  ADD CONSTRAINT `fk_tutorias_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tutorias_tutor` FOREIGN KEY (`tutor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `tutoring_requests`
--
ALTER TABLE `tutoring_requests`
  ADD CONSTRAINT `fk_tutoring_requests_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
