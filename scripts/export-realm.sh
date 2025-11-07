#!/usr/bin/env bash
set -euo pipefail
OUT=./realms/materiapp-realm.json
CID=$(docker ps --filter "ancestor=quay.io/keycloak/keycloak:26.0" --format "{{.ID}}")

docker exec -it "$CID" /opt/keycloak/bin/kc.sh export \
  --realm materiapp \
  --dir /tmp/export \
  --users realm_file

docker cp "$CID":/tmp/export/materiapp-realm.json "$OUT"
echo "Exportado a $OUT"
