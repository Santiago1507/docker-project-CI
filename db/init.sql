CREATE TABLE IF NOT EXISTS bitacora_docker (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mensaje VARCHAR(255) NOT NULL,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

INSERT INTO bitacora_docker (mensaje)
VALUES ('Base de datos inicializada correctamente para la entrega de la semana 3');
