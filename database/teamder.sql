-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 14-06-2026 a las 22:46:52
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
(2, 'Ana Torres', 'ana@teamder.com', '$2y$10$wH8xqJ6MdpQn8qJwQo4rvudV5Qz3wlv6YwCDfBzG0I3lYp3RFYx2a', 'tutor', 'Calculo diferencial', 'Tutora de matematicas.', '2026-06-14 20:46:08', '2026-06-14 20:46:08');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `calificaciones_tutoria`
--
ALTER TABLE `calificaciones_tutoria`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_calificacion_tutoria_alumno` (`tutoria_id`,`alumno_id`),
  ADD KEY `idx_calificaciones_alumno` (`alumno_id`);

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
-- AUTO_INCREMENT de la tabla `calificaciones_tutoria`
--
ALTER TABLE `calificaciones_tutoria`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tutorias`
--
ALTER TABLE `tutorias`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tutoring_requests`
--
ALTER TABLE `tutoring_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

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
