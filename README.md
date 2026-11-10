# Entrega Semana 3 - Dos contenedores Docker comunicados

Proyecto de integración continua: **WordPress + MySQL** ejecutándose en dos contenedores Docker que se comunican a través de una red interna.

## Descripción

La aplicación se construye con un **Dockerfile propio** a partir de la imagen oficial `wordpress:7.1.4-php8.3-apache`. La base de datos se construye a partir de `mysql:8.0.46`. Ambas versiones están fijadas para evitar cambios inesperados.

| Contenedor | Imagen construida | Base | Función | Puerto host |
|---|---|---|---|---|
| `sem3-wordpress` | `entrega-semana3-wordpress:1.0` | `wordpress:7.1.4-php8.3-apache` | Aplicación web (WordPress) | `8080` |
| `sem3-mysql` | `entrega-semana3-db:1.0` | `mysql:8.0.46` | Base de datos MySQL 8.0 | No expuesto |

Los contenedores se comunican por la red `entrega-semana3_red_interna`. WordPress se conecta a MySQL usando el **nombre del servicio** `db` como hostname (`db:3306`), sin utilizar `localhost` ni una IP fija.

## Comunicación de ida y vuelta

La imagen de la aplicación incluye el mu-plugin `wordpress/wp-content/mu-plugins/entrega-docker.php`. El plugin:

1. Crea la tabla `wp_comunicacion_docker`.
2. Crea la página **Prueba de comunicación Docker** con el shortcode `[prueba_docker]`.
3. Al abrir la página, inserta un registro en MySQL y lo lee de vuelta.
4. Muestra el contenedor de origen, el host `db:3306`, el ID, el mensaje guardado y el total de registros.

También se puede comprobar desde la terminal, usando el cliente MySQL instalado en la imagen de la aplicación:

```powershell
docker compose exec wordpress sh -c 'MYSQL_PWD="$WORDPRESS_DB_PASSWORD" mysql --skip-ssl -h db -u "$WORDPRESS_DB_USER" "$WORDPRESS_DB_NAME" -e "SELECT * FROM wp_comunicacion_docker ORDER BY id DESC LIMIT 5;"'
```

O desde el contenedor de la base de datos:

```powershell
docker compose exec db sh -c 'MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" "$MYSQL_DATABASE" -e "SELECT * FROM wp_comunicacion_docker ORDER BY id DESC LIMIT 5;"'
```

## Requisitos

- Docker Desktop instalado y en ejecución (Windows, macOS o Linux).
- Docker Compose v2 (`docker compose version`).
- Puerto `8080` libre.
- Navegador web.

## Inicio rápido

```powershell
git clone https://github.com/Santiago1507/docker-project-CI.git
cd docker-project-CI
Copy-Item .env.example .env
```

Edite `.env` con sus credenciales locales. Después construya y levante los contenedores:

```powershell
docker compose build
docker compose up -d
docker compose ps
```

Abra en el navegador:

```text
http://localhost:8080
```

Si el volumen de WordPress está vacío, complete el asistente de instalación. Los datos del asistente son del sitio WordPress y no deben confundirse con las credenciales de MySQL del archivo `.env`.

Para abrir la prueba de comunicación, ingrese a **Páginas > Prueba de comunicación Docker** en el panel de WordPress o use la URL `http://localhost:8080/?page_id=<ID_DE_LA_PAGINA>`.

## Estructura

```text
.
├── Dockerfile
├── .dockerignore
├── docker-compose.yml
├── .env.example
├── README.md
├── wordpress/
│   ├── php.ini
│   └── wp-content/
│       └── mu-plugins/
│           └── entrega-docker.php
├── db/
│   ├── Dockerfile
│   └── init.sql
├── .github/
│   ├── workflows/
│   │   └── ci.yml
│   └── scripts/
│       └── verify-communication.sh
```

## Comandos útiles

```powershell
# Construir las dos imágenes
docker compose build

# Levantar los contenedores
docker compose up -d

# Ver estado y salud de los contenedores
docker compose ps

# Ver los contenedores en ejecución
docker ps

# Ver logs de WordPress
docker compose logs -f wordpress

# Ver logs de MySQL
docker compose logs -f db

# Inspeccionar la red interna
docker network inspect entrega-semana3_red_interna

# Abrir la consola de MySQL (la contraseña se solicita de forma interactiva)
docker compose exec db mysql -u wp_user -p wordpress

# Detener sin borrar datos
docker compose down

# Detener y borrar contenedores, red y volúmenes (pierde los datos)
docker compose down -v
```

## Persistencia

- `entrega-semana3_db_data`: guarda la base de datos MySQL.
- `entrega-semana3_wp_data`: guarda los archivos de WordPress (temas, plugins, uploads).

Al ejecutar `docker compose down` y luego `docker compose up -d`, la información se conserva. Al ejecutar `docker compose down -v`, los volúmenes se eliminan y el sitio vuelve a cero.

## Integración continua

El workflow `.github/workflows/ci.yml` se ejecuta en cada `push` y `pull_request`. Realiza estas tareas:

1. Construye las dos imágenes con `docker compose build`.
2. Valida el archivo Compose.
3. Levanta los servicios.
4. Espera a que WordPress responda.
5. Verifica la comunicación insertando y leyendo un registro en MySQL.
6. Elimina los contenedores y volúmenes de prueba.

El check debe quedar en verde en la pestaña **Actions** del repositorio.

## Seguridad y GitHub

- El archivo `.env` contiene credenciales locales y está incluido en `.gitignore`.
- En el repositorio se publica únicamente `.env.example`.
- `.dockerignore` excluye `.env`, documentación y archivos temporales del contexto de construcción.
- El código no contiene contraseñas reales; las credenciales se leen de variables de entorno.
- MySQL no publica su puerto en el host; solo es accesible desde la red interna de Docker.

## Documentación

- Guía paso a paso: [`docs/guia-paso-a-paso.md`](docs/guia-paso-a-paso.md)
- Diagrama de arquitectura: [`docs/arquitectura.png`](docs/arquitectura.png)
- Repositorio: <https://github.com/Santiago1507/docker-project-CI>
