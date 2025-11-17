# Keycloak Realm Configuration

Este directorio contiene la configuración del realm `materiapp` para Keycloak, optimizada para ser versionada y portable entre diferentes entornos.

## Archivos

- `realms/materiapp-realm.json` - Configuración del realm limpia y portable
- `scripts/export-realm.sh` - Script para exportar y limpiar el realm
- `scripts/import-realm.sh` - Script para importar el realm en una nueva instancia
- `scripts/setup-realm.sh` - Script de configuración inicial (existente)

## Exportación del Realm

Para exportar la configuración actual del realm desde Keycloak:

```bash
./scripts/export-realm.sh
```

Este script:

- Exporta el realm desde el contenedor de Keycloak
- Remueve IDs únicos para evitar conflictos
- Elimina credenciales y secretos sensibles
- Reemplaza URLs específicas con variables
- Remueve usuarios (deben crearse manualmente)

## Importación del Realm

Para importar la configuración en una nueva instancia:

```bash
# Usando URL por defecto (localhost:4200)
./scripts/import-realm.sh

# O especificando una URL personalizada
FRONTEND_URL=https://mi-app.com ./scripts/import-realm.sh
```

## Pasos Posteriores a la Importación

Después de importar el realm, es necesario:

1. **Crear usuarios manualmente** en la consola de administración
2. **Configurar secretos** para clientes que los requieran
3. **Verificar URLs** de redirección según el entorno
4. **Configurar temas personalizados** si aplica

## Clientes Configurados

- `materiapp-web` - Cliente público para la aplicación frontend
- `materiapp-api` - Cliente para la API backend
- Clientes del sistema (account, admin-cli, etc.)

## Variables de Entorno

- `FRONTEND_URL` - URL base de la aplicación frontend (default: <http://localhost:4200>)

## Consola de Administración

- URL: <http://localhost:8080/admin>
- Usuario: admin
- Contraseña: admin

## Notas de Seguridad

- Los secretos de clientes se regeneran automáticamente
- Las contraseñas de usuarios deben establecerse manualmente
- Las URLs de redirección se configuran según el entorno
