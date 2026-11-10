CREATE TABLE IF NOT EXISTS wp_comunicacion_docker (
    id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    mensaje VARCHAR(255) NOT NULL,
    creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

INSERT INTO wp_comunicacion_docker (mensaje)
VALUES ('Registro inicial creado por db/init.sql para la entrega de la semana 3');
