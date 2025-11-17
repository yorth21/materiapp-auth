#!/usr/bin/env bash
set -euo pipefail

REALM_FILE=./realms/materiapp-realm.json
TEMP_FILE=/tmp/materiapp-realm-import.json
FRONTEND_URL=${FRONTEND_URL:-"http://localhost:4200"}

# Verificar que el archivo del realm existe
if [ ! -f "$REALM_FILE" ]; then
    echo "❌ Error: No se encontró el archivo del realm: $REALM_FILE"
    exit 1
fi

echo "🔄 Preparando realm para importación..."

# Reemplazar variables de entorno en el archivo del realm
sed "s|{{FRONTEND_URL}}|$FRONTEND_URL|g" "$REALM_FILE" > "$TEMP_FILE"

# Buscar contenedor de Keycloak
CID=$(docker ps --filter "ancestor=quay.io/keycloak/keycloak:26.0" --format "{{.ID}}")

if [ -z "$CID" ]; then
    echo "❌ Error: No se encontró un contenedor de Keycloak en ejecución"
    echo "   Inicia Keycloak primero con: docker-compose up -d"
    exit 1
fi

echo "📋 Copiando archivo al contenedor..."
docker cp "$TEMP_FILE" "$CID":/tmp/materiapp-realm-import.json

echo "📥 Importando realm en Keycloak..."
docker exec "$CID" /opt/keycloak/bin/kc.sh import \
    --file /tmp/materiapp-realm-import.json

if [ $? -eq 0 ]; then
    echo "✅ Realm importado exitosamente"
    echo ""
    echo "📝 Pasos adicionales requeridos:"
    echo "   1. Crear usuarios manualmente en la consola de administración"
    echo "   2. Configurar secretos de clientes si es necesario"
    echo "   3. Verificar URLs de redirección según el entorno"
    echo ""
    echo "🌐 Consola de administración: http://localhost:8080/admin"
    echo "   Usuario: admin"
    echo "   Contraseña: admin"
else
    echo "❌ Error al importar el realm"
    exit 1
fi

# Limpiar archivo temporal
rm -f "$TEMP_FILE"