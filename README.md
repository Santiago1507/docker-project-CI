# Entrega Semana 3 - Dos contenedores Docker comunicados

Proyecto de integración continua: **WordPress + MySQL** ejecutándose en dos contenedores Docker que se comunican a través de una red interna.

## Descripción

La solución utiliza dos imágenes oficiales de Docker Hub:

| Contenedor | Imagen | Función | Puerto host |
|---|---|---|---|
| `sem3-wordpress` | `wordpress:latest` | Aplicación web (WordPress) | `8080` |
| `sem3-mysql` | `mysql:8.0` | Base de datos MySQL 8.0 | No expuesto |

Los contenedores se comunican por la red `entrega-semana3_red_interna`. WordPress se conecta a MySQL usando el nombre del servicio `db` como hostname (`db:3306`), sin utilizar `localhost`.

## Requisitos

- Docker Desktop instalado y en ejecución (Windows, macOS o Linux).
- Docker Compose v2 (`docker compose version`).
- Puerto `8080` libre.
- Navegador web.

## Inicio rápido

```powershell
cd entrega-semana3
docker compose up -d
docker compose ps
```

Abrir en el navegador:

```text
http://localhost:8080
```

Completar el asistente de instalación de WordPress con los datos que se deseen. Esos datos son del sitio WordPress y no deben confundirse con las credenciales de MySQL del archivo `.env`.

## Estructura

```text
entrega-semana3/
├── docker-compose.yml
├── .env
├── .env.example
├── .gitignore
├── README.md
├── db/
│   └── init.sql
```

## Comandos útiles

```powershell
# Levantar los contenedores
docker compose up -d

# Ver estado y salud de los contenedores
docker compose ps

# Ver logs de WordPress
docker compose logs -f wordpress

# Ver logs de MySQL
docker compose logs -f db

# Entrar al contenedor de MySQL
docker compose exec db mysql -u wp_user -p'Wp_User_2026*' wordpress

# Ver tablas creadas por WordPress y por el script init.sql
docker compose exec db mysql -u wp_user -p'Wp_User_2026*' wordpress -e "SHOW TABLES;"

# Inspeccionar la red interna
docker network inspect entrega-semana3_red_interna

# Detener sin borrar datos
docker compose down

# Detener y borrar contenedores, red y volúmenes (pierde los datos)
docker compose down -v

# Ver volúmenes
docker volume ls
```

## Persistencia

- `entrega-semana3_db_data`: guarda la base de datos MySQL.
- `entrega-semana3_wp_data`: guarda los archivos de WordPress (temas, plugins, uploads).

Al ejecutar `docker compose down` y luego `docker compose up -d`, la información se conserva. Al ejecutar `docker compose down -v`, los volúmenes se eliminan y el sitio vuelve a cero.

## Seguridad y GitHub

- El archivo `.env` contiene credenciales de ejemplo y está incluido en `.gitignore`.
- Para publicar en GitHub se debe subir `.env.example` y crear el `.env` localmente.
- MySQL no publica su puerto en el host; solo es accesible desde la red interna de Docker.
