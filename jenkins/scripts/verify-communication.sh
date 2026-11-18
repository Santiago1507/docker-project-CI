#!/usr/bin/env bash
set -euo pipefail

PORT="${WORDPRESS_PORT:-8081}"
BASE_URL="http://localhost:${PORT}"
ADMIN_PASSWORD="${WP_ADMIN_PASSWORD:-ci_admin_password}"

echo "Verificando aplicación en ${BASE_URL}"
ready=0
for i in $(seq 1 30); do
  if curl -fsS "${BASE_URL}/" > /dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 5
done
if [ "$ready" -ne 1 ]; then
  echo "La aplicación no respondió a tiempo."
  docker compose logs --tail=120
  exit 1
fi

if ! docker compose exec -T -u www-data wordpress wp core is-installed > /dev/null 2>&1; then
  echo "Instalando WordPress para la prueba."
  docker compose exec -T -u www-data wordpress wp core install \
    --url="${BASE_URL}" \
    --title="Entrega Semana 5" \
    --admin_user="admin" \
    --admin_password="${ADMIN_PASSWORD}" \
    --admin_email="ci@example.com" \
    --skip-email
fi

query() {
  docker compose exec -T -e MYSQL_PWD="$MYSQL_PASSWORD" wordpress \
    mysql -N --skip-ssl -h db -u "$MYSQL_USER" "$MYSQL_DATABASE" -e "$1" \
    2>/dev/null | tr -d '\r'
}

page_id=""
for i in $(seq 1 30); do
  page_id=$(query "SELECT ID FROM wp_posts WHERE post_name = 'prueba-comunicacion-docker' AND post_type = 'page' LIMIT 1;")
  if [ -n "$page_id" ]; then
    break
  fi
  sleep 5
done

if [ -z "$page_id" ]; then
  echo "No se encontró la página de prueba de comunicación."
  docker compose logs --tail=120
  exit 1
fi

table="wp_comunicacion_docker"
before=$(query "SELECT COUNT(*) FROM ${table};")

html=$(curl -fsS "${BASE_URL}/?page_id=${page_id}")
if ! printf '%s' "$html" | grep -q "MySQL verificada"; then
  echo "La página no mostró la confirmación de comunicación."
  exit 1
fi

after=$(query "SELECT COUNT(*) FROM ${table};")
if [ "$after" -le "$before" ]; then
  echo "No se insertó un registro nuevo en ${table}."
  exit 1
fi

row=$(query "SELECT CONCAT(id, '|', mensaje) FROM ${table} ORDER BY id DESC LIMIT 1;")
echo "Página de prueba: ${page_id}"
echo "Registros antes: ${before}; después: ${after}"
echo "Último registro: ${row}"
echo "Comunicación verificada: WordPress insertó y leyó un registro en MySQL usando el hostname db."
