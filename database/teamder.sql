CREATE DATABASE IF NOT EXISTS teamder
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE teamder;

CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('student', 'tutor') NOT NULL DEFAULT 'student',
  subject VARCHAR(160) NULL,
  bio TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tutoring_requests (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  subject VARCHAR(160) NOT NULL,
  title VARCHAR(180) NOT NULL,
  description TEXT NOT NULL,
  modality ENUM('online', 'presencial', 'mixta') NOT NULL DEFAULT 'online',
  status ENUM('open', 'closed') NOT NULL DEFAULT 'open',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tutoring_requests_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
);

INSERT INTO users (name, email, password_hash, role, subject, bio)
VALUES
  (
    'Usuario Demo',
    'demo@teamder.com',
    '$2y$10$wH8xqJ6MdpQn8qJwQo4rvudV5Qz3wlv6YwCDfBzG0I3lYp3RFYx2a',
    'student',
    'Programacion en PHP',
    'Cuenta de prueba para iniciar sesion.'
  ),
  (
    'Ana Torres',
    'ana@teamder.com',
    '$2y$10$wH8xqJ6MdpQn8qJwQo4rvudV5Qz3wlv6YwCDfBzG0I3lYp3RFYx2a',
    'tutor',
    'Calculo diferencial',
    'Tutora de matematicas.'
  )
ON DUPLICATE KEY UPDATE email = VALUES(email);
