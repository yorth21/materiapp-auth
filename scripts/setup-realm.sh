#!/usr/bin/env bash
set -euo pipefail

KC_URL="${KC_URL:-http://localhost:8080}"
REALM="materiapp"

docker exec -it $(docker ps --filter "ancestor=quay.io/keycloak/keycloak:26.0" --format "{{.ID}}") \
  /opt/keycloak/bin/kcadm.sh config credentials \
  --server "${KC_URL}" \
  --realm master \
  --user "${KEYCLOAK_ADMIN:-admin}" \
  --password "${KEYCLOAK_ADMIN_PASSWORD:-admin}"

# Import (si no existe)
docker exec -it $(docker ps --filter "ancestor=quay.io/keycloak/keycloak:26.0" --format "{{.ID}}") \
  /opt/keycloak/bin/kcadm.sh get realms/${REALM} >/dev/null 2>&1 || {
    echo "Importando realm ${REALM}..."
    # Con start-dev --import-realm ya lo trae al inicio; esto es por si reinicias sin flag
    docker exec -it $(docker ps --filter "ancestor=quay.io/keycloak/keycloak:26.0" --format "{{.ID}}") \
      /opt/keycloak/bin/kcadm.sh create realms -f /opt/keycloak/data/import/materiapp-realm.json
  }

# Crear usuario demo
USER=json='{"username":"yorth","enabled":true,"emailVerified":true,"email":"yorth@example.com"}'
docker exec -i $(docker ps --filter "ancestor=quay.io/keycloak/keycloak:26.0" --format "{{.ID}}") \
  /opt/keycloak/bin/kcadm.sh create users -r ${REALM} -s username=yorth -s enabled=true || true

# Password
docker exec -it $(docker ps --filter "ancestor=quay.io/keycloak/keycloak:26.0" --format "{{.ID}}") \
  /opt/keycloak/bin/kcadm.sh set-password -r ${REALM} --username yorth --new-password 123456

# Asignar rol admin
docker exec -it $(docker ps --filter "ancestor=quay.io/keycloak/keycloak:26.0" --format "{{.ID}}") \
  /opt/keycloak/bin/kcadm.sh add-roles -r ${REALM} --uusername yorth --rolename admin
echo "Realm listo."
