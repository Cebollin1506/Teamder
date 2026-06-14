CREATE TABLE IF NOT EXISTS calificaciones_estudiante (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tutoria_id INT UNSIGNED NOT NULL,
  tutor_id INT UNSIGNED NOT NULL,
  alumno_id INT UNSIGNED NOT NULL,
  calificacion TINYINT UNSIGNED NOT NULL,
  comentario TEXT NULL,
  fecha_calificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_calificacion_estudiante_tutoria_tutor (tutoria_id, tutor_id),
  INDEX idx_calificaciones_estudiante_alumno (alumno_id),
  INDEX idx_calificaciones_estudiante_tutor (tutor_id),
  CONSTRAINT fk_calificaciones_estudiante_tutoria
    FOREIGN KEY (tutoria_id) REFERENCES tutorias(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_calificaciones_estudiante_tutor
    FOREIGN KEY (tutor_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_calificaciones_estudiante_alumno
    FOREIGN KEY (alumno_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT chk_calificacion_estudiante_rango
    CHECK (calificacion BETWEEN 1 AND 5)
);
