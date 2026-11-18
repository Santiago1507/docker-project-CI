# Jenkins para la entrega de la semana 5

Esta carpeta contiene la configuración para ejecutar Jenkins como gestor de operaciones sobre los dos contenedores de la entrega de la semana 3.

## Archivos

| Archivo | Función |
|---|---|
| `Dockerfile` | Imagen propia basada en `jenkins/jenkins:lts-jdk17`, con CLI de Docker, Compose y los plugins del pipeline. |
| `plugins.txt` | Plugins instalados: Git, GitHub, Pipeline, Docker Pipeline, credenciales y utilidades. |
| `docker-compose.yml` | Contenedor `sem5-jenkins`, puerto `8082`, volumen `jenkins_home` y socket de Docker. |
| `scripts/verify-communication.sh` | Prueba que levanta el compose, instala WordPress si hace falta y verifica escritura/lectura en MySQL por el hostname `db`. |
| `../Jenkinsfile` | Pipeline como código con etapas Checkout, Build, Test y bloque post. |

## Requisitos

- Docker Desktop en ejecución.
- Docker Compose v2.
- Puerto `8082` libre para Jenkins y `8081` libre para la aplicación de prueba.
- Repositorio GitHub accesible.

## Levantar Jenkins

```powershell
cd jenkins
docker compose up -d --build
docker compose ps
```

Obtener la contraseña inicial:

```powershell
docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Abrir <http://localhost:8082>.

## Credenciales en Jenkins

Crear estas credenciales en **Manage Jenkins → Credentials → System → Global credentials**:

| ID | Tipo | Uso |
|---|---|---|
| `github-credentials` | Username with password | Usuario de GitHub + token de acceso personal para el Checkout. |
| `mysql-database` | Secret text | Nombre de la base de datos. |
| `mysql-user` | Secret text | Usuario de MySQL. |
| `mysql-password` | Secret text | Contraseña del usuario de MySQL. |
| `mysql-root-password` | Secret text | Contraseña root para el healthcheck. |
| `wordpress-admin-password` | Secret text | Contraseña del administrador usada solo en la prueba. |

Ningún valor real debe escribirse en el repositorio.

## Job

1. **New Item → Pipeline**, nombre: `entrega-semana3-ci`.
2. En **Pipeline**, seleccionar **Pipeline script from SCM**.
3. SCM: **Git**, URL: `https://github.com/Santiago1507/docker-project-CI.git`, rama `main`.
4. Script path: `Jenkinsfile`.
5. Activar **Poll SCM** con `H/3 * * * *` (alternativa: webhook `http://<host>:8082/github-webhook/`).
6. Guardar y ejecutar **Build Now** la primera vez.

El disparo automático con Poll SCM consulta GitHub cada tres minutos. Con webhook, además hay que instalar el plugin GitHub y configurar el secreto del webhook en el repositorio.

## Prueba

El pipeline construye las dos imágenes con `docker compose build`, levanta los servicios con `docker compose up -d` y ejecuta `jenkins/scripts/verify-communication.sh`. La prueba falla si la aplicación no responde, si no aparece la página de comunicación o si el número de registros no aumenta.

En `post { always }` se eliminan contenedores, red y volúmenes de prueba con `docker compose down -v`.
