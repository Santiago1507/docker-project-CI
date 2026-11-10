# Guía paso a paso - Entrega Semana 3

Esta guía reproduce la solución de dos contenedores Docker comunicados: WordPress como aplicación web y MySQL como base de datos. La aplicación se construye con un Dockerfile propio y se conecta a MySQL usando el nombre de servicio `db`.

## 1. Requisitos

- Docker Desktop en ejecución.
- Docker Compose v2 (`docker compose version`).
- Git y una cuenta de GitHub para el repositorio y GitHub Actions.
- Puerto `8080` libre.
- Navegador web.

## 2. Estructura del proyecto

```text
entrega-semana3/
├── Dockerfile
├── .dockerignore
├── docker-compose.yml
├── .env.example
├── .github/
│   ├── workflows/ci.yml
│   └── scripts/verify-communication.sh
├── db/
│   ├── Dockerfile
│   └── init.sql
├── wordpress/
│   ├── php.ini
│   └── wp-content/mu-plugins/entrega-docker.php
├── capturas/
├── docs/
└── tools/
```

## 3. Variables de entorno

Copie la plantilla y defina sus credenciales locales:

```powershell
Copy-Item .env.example .env
```

El archivo `.env` contiene las variables que usa Docker Compose:

```text
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=defina_una_contrasena_segura
MYSQL_ROOT_PASSWORD=defina_otra_contrasena_segura
WORDPRESS_PORT=8080
```

`.env` está en `.gitignore` y no se publica. En el repositorio solo se incluye `.env.example`.

## 4. Construir las imágenes

La imagen de la aplicación parte de `wordpress:7.1.4-php8.3-apache`, instala el cliente MySQL y WP-CLI, copia `wordpress/php.ini` y el mu-plugin `entrega-docker.php`.

La imagen de la base de datos parte de `mysql:8.0.46` e incorpora `db/init.sql`.

```powershell
docker compose build
```

Las imágenes resultantes son:

- `entrega-semana3-wordpress:1.0`
- `entrega-semana3-db:1.0`

## 5. Levantar los contenedores

```powershell
docker compose up -d
docker compose ps
```

Deben aparecer dos servicios activos. `sem3-mysql` debe estar en estado `healthy` y `sem3-wordpress` debe publicar el puerto `8080`.

También puede verificar las imágenes y los puertos con:

```powershell
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
```

## 6. Instalar WordPress

Abra `http://localhost:8080` y complete el asistente si el volumen está vacío. Cree un usuario administrador del sitio. Esas credenciales son de WordPress y no deben confundirse con las de MySQL del archivo `.env`.

El mu-plugin crea automáticamente la página **Prueba de comunicación Docker**, que contiene el shortcode `[prueba_docker]`.

## 7. Verificar la comunicación

### 7.1 Tablas de la base de datos

```powershell
docker compose exec db mysql -u wp_user -p wordpress -e "SHOW TABLES;"
```

Deben aparecer las tablas `wp_*` y `wp_comunicacion_docker`. El comando solicita la contraseña de forma interactiva.

### 7.2 Registros de la tabla de comunicación

```powershell
docker compose exec db mysql -u wp_user -p wordpress -e "SELECT * FROM wp_comunicacion_docker ORDER BY id;"
```

### 7.3 Página del plugin

Abra:

```text
http://localhost:8080/prueba-comunicacion-docker/
```

Cada carga inserta un registro, lo lee de vuelta y muestra:

- El contenedor de origen (`sem3-wordpress`).
- El host de la base de datos (`db:3306`).
- El ID, el mensaje, la fecha y el total de registros.

### 7.4 Consulta desde el contenedor WordPress

Esta consulta usa el cliente MySQL instalado en la imagen de la aplicación y el host `db`:

```powershell
docker compose exec wordpress sh -c 'MYSQL_PWD="$WORDPRESS_DB_PASSWORD" mysql --skip-ssl -h db -u "$WORDPRESS_DB_USER" "$WORDPRESS_DB_NAME" -e "SELECT id, mensaje, creado_en FROM wp_comunicacion_docker ORDER BY id;"'
```

La opción `--skip-ssl` es necesaria en local porque MySQL usa un certificado autofirmado. En producción se debe configurar TLS con certificados válidos.

## 8. Red interna

```powershell
docker network inspect entrega-semana3_red_interna
```

En la sección `Containers` deben aparecer `sem3-wordpress` y `sem3-mysql`. Docker resuelve el nombre `db` a la IP interna del contenedor de MySQL.

## 9. Persistencia

Los volúmenes son:

- `entrega-semana3_db_data` para `/var/lib/mysql`.
- `entrega-semana3_wp_data` para `/var/www/html`.

```powershell
docker compose down
docker compose up -d
```

El sitio y los registros se conservan. `docker compose down -v` elimina los volúmenes y reinicia los datos.

## 10. Logs y diagnóstico

```powershell
docker compose logs --tail=50 wordpress
docker compose logs --tail=50 db
```

Si aparece `Error establishing a database connection`, revise `WORDPRESS_DB_HOST=db:3306`, las variables de `.env` y el estado `healthy` de MySQL.

## 11. Integración continua

El workflow `.github/workflows/ci.yml` se ejecuta en cada `push` y `pull_request`:

1. Construye las dos imágenes con `docker compose build`.
2. Valida el archivo Compose.
3. Levanta los servicios.
4. Instala WordPress con WP-CLI.
5. Espera a que WordPress responda.
6. Ejecuta `.github/scripts/verify-communication.sh`.
7. Muestra el estado y elimina los contenedores de prueba.

El resultado se consulta en la pestaña **Actions** del repositorio y debe quedar en verde.

## 12. Evidencias

Las capturas de la carpeta `capturas/` se insertan automáticamente en el DOCX:

```powershell
python tools\generar_documentacion.py
```

El documento resultante es `INTEGRACION_Entrega_Semana3.docx`. Para generar el PDF, ábralo en Word o LibreOffice y use **Guardar como > PDF**.
