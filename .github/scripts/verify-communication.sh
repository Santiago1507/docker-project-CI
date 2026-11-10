#!/usr/bin/env bash
set -euo pipefail

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

PAGE_ID=""
for i in $(seq 1 30); do
  PAGE_ID=$(docker compose exec -T -e MYSQL_PWD="$MYSQL_PASSWORD" wordpress \
    mysql -N --skip-ssl -h db -u "$MYSQL_USER" "$MYSQL_DATABASE" \
    -e "SELECT ID FROM wp_posts WHERE post_name = 'prueba-comunicacion-docker' AND post_type = 'page' LIMIT 1;" \
    2>/dev/null | tr -d '\r' || true)
  if [ -n "$PAGE_ID" ]; then
    break
  fi
  sleep 5
done

if [ -z "$PAGE_ID" ]; then
  echo "No se encontro la pagina de prueba de comunicacion."
  docker compose logs --tail=100 wordpress
  exit 1
fi

echo "Pagina de prueba: $PAGE_ID"
curl -fsS "http://localhost:8080/?page_id=$PAGE_ID" | grep -q "MySQL verificada"
echo "Comunicación verificada: WordPress escribió y leyó un registro en MySQL usando el hostname db."
