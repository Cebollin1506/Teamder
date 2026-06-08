USE teamder;

CREATE TABLE IF NOT EXISTS tutorias (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  alumno_id INT UNSIGNED NOT NULL,
  tutor_id INT UNSIGNED NOT NULL,
  tema VARCHAR(180) NOT NULL,
  descripcion TEXT NULL,
  fecha DATE NOT NULL,
  hora TIME NOT NULL,
  estado ENUM('pendiente', 'confirmada', 'cancelada', 'finalizada') NOT NULL DEFAULT 'pendiente',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_tutorias_alumno (alumno_id),
  INDEX idx_tutorias_tutor_fecha_hora (tutor_id, fecha, hora),
  CONSTRAINT fk_tutorias_alumno
    FOREIGN KEY (alumno_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_tutorias_tutor
    FOREIGN KEY (tutor_id) REFERENCES users(id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS calificaciones_tutoria (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tutoria_id INT UNSIGNED NOT NULL,
  alumno_id INT UNSIGNED NOT NULL,
  calificacion TINYINT UNSIGNED NOT NULL,
  comentario TEXT NULL,
  fecha_calificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_calificacion_tutoria_alumno (tutoria_id, alumno_id),
  INDEX idx_calificaciones_alumno (alumno_id),
  CONSTRAINT fk_calificaciones_tutoria
    FOREIGN KEY (tutoria_id) REFERENCES tutorias(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_calificaciones_alumno
    FOREIGN KEY (alumno_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT chk_calificacion_rango
    CHECK (calificacion BETWEEN 1 AND 5)
);

CREATE TABLE IF NOT EXISTS notificaciones (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT UNSIGNED NOT NULL,
  titulo VARCHAR(160) NOT NULL,
  mensaje TEXT NOT NULL,
  tipo VARCHAR(80) NOT NULL,
  leida TINYINT(1) NOT NULL DEFAULT 0,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_notificaciones_usuario_fecha (usuario_id, fecha_creacion),
  CONSTRAINT fk_notificaciones_usuario
    FOREIGN KEY (usuario_id) REFERENCES users(id)
    ON DELETE CASCADE
);
