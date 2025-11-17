#!/usr/bin/env bash
set -euo pipefail

OUT=./realms/materiapp-realm.json
TEMP_FILE=/tmp/materiapp-realm-temp.json
CID=$(docker ps --filter "ancestor=quay.io/keycloak/keycloak:26.0" --format "{{.ID}}")

if [ -z "$CID" ]; then
    echo "Error: No se encontró un contenedor de Keycloak en ejecución"
    exit 1
fi

echo "Exportando realm desde Keycloak..."
docker exec -it "$CID" /opt/keycloak/bin/kc.sh export \
  --realm materiapp \
  --dir /tmp/export \
  --users skip

echo "Copiando archivo exportado..."
docker cp "$CID":/tmp/export/materiapp-realm.json "$TEMP_FILE"

echo "Limpiando datos para versionado..."
# Remover IDs autogenerados y datos sensibles para hacer el realm portable
jq 'del(.id) |
    del(.users[].id) |
    del(.users[].createdTimestamp) |
    del(.users[].credentials) |
    del(.roles.realm[].id) |
    del(.roles.client[][][].id) |
    del(.clients[].id) |
    del(.clients[].secret) |
    del(.clientScopes[].id) |
    del(.defaultRole.id) |
    del(.defaultRole.containerId) |
    del(.authenticationFlows[].id) |
    del(.authenticationFlows[].authenticationExecutions[].id) |
    del(.authenticatorConfig[].id) |
    del(.components.""org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy""[].id) |
    del(.components.""org.keycloak.keys.KeyProvider""[].id) |
    # Limpiar URLs específicas del entorno
    (.clients[] | select(.clientId == "materiapp-web") | .rootUrl) = "{{FRONTEND_URL}}" |
    (.clients[] | select(.clientId == "materiapp-web") | .adminUrl) = "{{FRONTEND_URL}}" |
    (.clients[] | select(.clientId == "materiapp-web") | .redirectUris) = ["{{FRONTEND_URL}}/*"] |
    (.clients[] | select(.clientId == "materiapp-web") | .webOrigins) = ["{{FRONTEND_URL}}"] |
    # Remover usuarios por defecto (deben crearse manualmente en cada instancia)
    .users = []' "$TEMP_FILE" > "$OUT"

# Verificar que el archivo se creó correctamente
if [ -f "$OUT" ]; then
    echo "✅ Realm exportado y limpiado en: $OUT"
    echo "📝 Nota: Se han removido:"
    echo "   - IDs únicos (para evitar conflictos)"
    echo "   - Credenciales de usuarios"
    echo "   - Secretos de clientes"
    echo "   - URLs específicas (reemplazadas con variables)"
    echo "   - Usuarios (deben crearse manualmente)"
else
    echo "❌ Error al crear el archivo limpio"
    exit 1
fi

# Limpiar archivo temporal
rm -f "$TEMP_FILE"
