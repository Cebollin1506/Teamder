CREATE TABLE IF NOT EXISTS mensajes_tutoria (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tutoria_id INT UNSIGNED NOT NULL,
  emisor_id INT UNSIGNED NOT NULL,
  mensaje TEXT NOT NULL,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_mensajes_tutoria_fecha (tutoria_id, fecha_creacion),
  CONSTRAINT fk_mensajes_tutoria_tutoria
    FOREIGN KEY (tutoria_id) REFERENCES tutorias(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_mensajes_tutoria_emisor
    FOREIGN KEY (emisor_id) REFERENCES users(id)
    ON DELETE CASCADE
);
