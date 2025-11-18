#!/usr/bin/env bash
set -euo pipefail

# Configuración
REALM_NAME="materiapp"
REALM_FILE="./realms/${REALM_NAME}-realm.json"
TEMP_FILE="/tmp/${REALM_NAME}-realm-import.json"
KEYCLOAK_IMAGE="quay.io/keycloak/keycloak:26.0"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:4200}"

# Verificar dependencias
command -v docker >/dev/null 2>&1 || { echo "Error: Docker no está instalado" >&2; exit 1; }
command -v sed >/dev/null 2>&1 || { echo "Error: sed no está instalado" >&2; exit 1; }

# Verificar que el archivo del realm existe
[ ! -f "$REALM_FILE" ] && { echo "Error: No se encontró $REALM_FILE" >&2; exit 1; }

# Buscar contenedor de Keycloak
CID=$(docker ps --filter "ancestor=$KEYCLOAK_IMAGE" --format "{{.ID}}" | head -n 1)
[ -z "$CID" ] && { echo "Error: No se encontró contenedor de Keycloak" >&2; exit 1; }

# Reemplazar variables de entorno
sed "s|{{FRONTEND_URL}}|$FRONTEND_URL|g" "$REALM_FILE" > "$TEMP_FILE"

# Copiar e importar
docker cp "$TEMP_FILE" "$CID:/tmp/${REALM_NAME}-realm-import.json" 2>/dev/null || { echo "Error: Falló la copia" >&2; exit 1; }

docker exec "$CID" /opt/keycloak/bin/kc.sh import \
    --file "/tmp/${REALM_NAME}-realm-import.json" >/dev/null 2>&1 || { echo "Error: Falló la importación" >&2; exit 1; }

# Limpiar
rm -f "$TEMP_FILE"
docker exec "$CID" rm -f "/tmp/${REALM_NAME}-realm-import.json" 2>/dev/null || true

echo "✅ Realm importado con usuarios de desarrollo"