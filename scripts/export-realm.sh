#!/usr/bin/env bash
set -euo pipefail

# Configuración
REALM_NAME="materiapp"
OUT_DIR="./realms"
OUT_FILE="$OUT_DIR/materiapp-realm.json"
TEMP_FILE="/tmp/materiapp-realm-temp.json"
KEYCLOAK_IMAGE="quay.io/keycloak/keycloak:26.0"

# Verificar dependencias
command -v docker >/dev/null 2>&1 || { echo "Error: Docker no está instalado" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq no está instalado" >&2; exit 1; }

# Crear directorio de salida
mkdir -p "$OUT_DIR"

# Buscar contenedor de Keycloak
CID=$(docker ps --filter "ancestor=$KEYCLOAK_IMAGE" --format "{{.ID}}" | head -n 1)
[ -z "$CID" ] && { echo "Error: No se encontró contenedor de Keycloak" >&2; exit 1; }

# Exportar realm con usuarios de desarrollo
docker exec "$CID" /opt/keycloak/bin/kc.sh export \
  --realm "$REALM_NAME" \
  --dir /tmp/export \
  --users realm_file >/dev/null 2>&1 || { echo "Error: Falló la exportación" >&2; exit 1; }

# Copiar y limpiar
docker cp "$CID:/tmp/export/$REALM_NAME-realm.json" "$TEMP_FILE" 2>/dev/null || { echo "Error: Falló la copia" >&2; exit 1; }

jq 'del(.id) |
    del(.roles.realm[]?.id) |
    del(.roles.client) |
    del(.clients[]?.id) |
    del(.clients[]?.secret) |
    del(.clientScopes[]?.id) |
    del(.defaultRole?.id) |
    del(.defaultRole?.containerId) |
    del(.authenticationFlows[]?.id) |
    del(.authenticationFlows[]?.authenticationExecutions[]?.id) |
    del(.authenticatorConfig[]?.id) |
    del(.components?"org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy"[]?.id) |
    del(.components?"org.keycloak.keys.KeyProvider"[]?.id) |
    del(.groups[]?.id) |
    # Limpiar IDs de usuarios pero mantener la estructura
    del(.users[]?.id) |
    del(.users[]?.createdTimestamp) |
    # Reemplazar URLs específicas del entorno con placeholders
    (.clients[] | select(.clientId == "materiapp-web")? | .rootUrl) = "{{FRONTEND_URL}}" |
    (.clients[] | select(.clientId == "materiapp-web")? | .adminUrl) = "{{FRONTEND_URL}}" |
    (.clients[] | select(.clientId == "materiapp-web")? | .redirectUris) = ["{{FRONTEND_URL}}/*"] |
    (.clients[] | select(.clientId == "materiapp-web")? | .webOrigins) = ["{{FRONTEND_URL}}"]' "$TEMP_FILE" > "$OUT_FILE"

# Limpiar
rm -f "$TEMP_FILE"
docker exec "$CID" rm -rf /tmp/export 2>/dev/null || true

echo "✅ Realm exportado: $OUT_FILE"