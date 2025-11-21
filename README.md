# 🧩 Materiapp Identity

Repositorio de infraestructura para **gestionar la identidad y autenticación de Materiapp** usando [Keycloak](https://www.keycloak.org/).  
Este proyecto define la configuración de Keycloak **como código**, incluyendo un **tema personalizado** para las páginas de autenticación, de modo que puede reproducirse, versionarse y desplegarse fácilmente en cualquier entorno.

---

## 📘 Contenido del repositorio

```
materiapp-identity/
├─ themes/
│  └─ materiapp/
│     └─ login/
│        ├─ login.ftl              # Plantilla de inicio de sesión
│        ├─ register.ftl           # Plantilla de registro
│        ├─ theme.properties       # Configuración del tema
│        └─ resources/
│           └─ css/
│              └─ styles.css       # Estilos personalizados del tema
├─ docker-compose.yml              # Docker Compose con Keycloak + Postgres
├─ .env                            # Variables de entorno locales (no incluido)
├─ .env.example                    # Ejemplo de variables de entorno
└─ README.md                       # Este documento
```

---

## 🚀 Levantar el entorno

### 1️⃣ Requisitos previos

- [Docker](https://docs.docker.com/get-docker/) y [Docker Compose](https://docs.docker.com/compose/install/) instalados.
- Puerto **8080** libre (Keycloak) y **5434** libre (Postgres).

### 2️⃣ Clonar el repositorio

```bash
git clone https://github.com/yorth21/materiapp-auth.git
cd materiapp-identity
```

### 3️⃣ Configurar variables de entorno

Crea el archivo `.env` basándote en `.env.example`:

```bash
# Postgres (Keycloak)
KC_DB=postgres
KC_DB_HOST=kcdb
KC_DB_NAME=keycloak
KC_DB_USER=keycloak
KC_DB_PASSWORD=keycloak

# Admin Keycloak
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin

# Puertos host
KC_HTTP_PORT=8080
KC_DB_PORT=5434
```

### 4️⃣ Levantar Keycloak y la base de datos

```bash
docker compose up -d
```

Esto inicia:

- **Postgres** (`kcdb`) - Base de datos para Keycloak
- **Keycloak** en modo desarrollo (`start-dev`) con el tema personalizado `materiapp`

El tema personalizado se monta automáticamente desde `./themes` al directorio `/opt/keycloak/themes` del contenedor.

### 5️⃣ Acceder al panel de administración

- URL: [http://localhost:8080](http://localhost:8080)
- Usuario: `admin`
- Contraseña: `admin`

### 6️⃣ Configurar el tema

1. Accede a la consola de administración
2. Ve a **Realm Settings** → **Themes**
3. Selecciona `materiapp` en el dropdown de **Login Theme**
4. Guarda los cambios

Ahora las páginas de login y registro usarán el tema personalizado.

---

## 🎨 Tema personalizado Materiapp

Este proyecto incluye un tema personalizado para Keycloak con un diseño moderno y minimalista que coincide con la identidad visual de Materiapp.

### Características del tema

- ✨ **Diseño moderno** con esquema de colores neutros y elegantes
- 📱 **Totalmente responsive** para móviles y tablets
- 🎯 **Formularios simplificados** con mejor UX
- 🔐 **Páginas incluidas**: Login y Registro
- 💅 **Estilos personalizados** usando CSS variables para fácil customización

### Estructura del tema

```
themes/materiapp/login/
├── login.ftl              # Página de inicio de sesión
├── register.ftl           # Página de registro
├── theme.properties       # Configuración del tema
└── resources/
    └── css/
        └── styles.css     # Estilos personalizados
```

### Personalizar el tema

Puedes modificar los colores y estilos editando las variables CSS en `themes/materiapp/login/resources/css/styles.css`:

```css
:root {
  --bg: #f3f4f6;              /* fondo general */
  --card-bg: #ffffff;          /* fondo card */
  --border: #e5e7eb;           /* borde card / inputs */
  --text: #111827;             /* texto principal */
  --muted: #6b7280;            /* texto secundario */
  --btn-bg: #111827;           /* botón principal */
  --btn-bg-hover: #020617;
}
```

Los cambios se reflejarán automáticamente al recargar Keycloak (no necesitas reiniciar el contenedor).

---

## 🎯 Próximos pasos

Para tener un sistema completo de autenticación, considera:

1. **Crear un realm** en Keycloak con tu configuración específica
2. **Configurar clients** para tus aplicaciones (web y API)
3. **Definir roles y permisos** según tu modelo de negocio
4. **Agregar más páginas al tema** (reset password, email verification, etc.)
5. **Integrar con tus aplicaciones** usando bibliotecas como `keycloak-angular` o `@nestjs/passport`

---

## 🔧 Comandos útiles

| Acción | Comando |
|--------|----------|
| Levantar servicios | `docker compose up -d` |
| Ver logs de Keycloak | `docker compose logs -f keycloak` |
| Ver logs de Postgres | `docker compose logs -f kcdb` |
| Reiniciar Keycloak | `docker compose restart keycloak` |
| Detener servicios | `docker compose down` |
| Detener y eliminar volúmenes | `docker compose down -v` |

---

## 🔐 Integración con aplicaciones

Una vez que tengas tu realm configurado en Keycloak, puedes integrarlo con tus aplicaciones frontend y backend.

### Endpoints OIDC útiles

| Propósito | URL |
|------------|-----|
| Realm base | `http://localhost:8080/realms/{realm-name}` |
| Discovery document | `http://localhost:8080/realms/{realm-name}/.well-known/openid-configuration` |
| JWKS (validación JWT) | `http://localhost:8080/realms/{realm-name}/protocol/openid-connect/certs` |
| Token endpoint | `http://localhost:8080/realms/{realm-name}/protocol/openid-connect/token` |

### Ejemplo: Angular (Frontend)

Configura en `environment.ts`:

```typescript
export const environment = {
  production: false,
  keycloak: {
    issuer: 'http://localhost:8080/realms/materiapp',
    clientId: 'materiapp-web',
    redirectUri: 'http://localhost:4200/',
  }
};
```

Usa [`keycloak-angular`](https://www.npmjs.com/package/keycloak-angular) o el SDK oficial `keycloak-js` para el flujo PKCE.

### Ejemplo: NestJS (Backend)

Configura tu guard de validación JWT:

```typescript
issuer: 'http://localhost:8080/realms/materiapp',
audience: 'materiapp-web',
jwksUri: 'http://localhost:8080/realms/materiapp/protocol/openid-connect/certs'
```

---

## 🧱 Notas para producción

Al desplegar Keycloak en producción, considera:

- ✅ Usa `start` en lugar de `start-dev` en el comando de Keycloak
- 🔒 Configura **HTTPS** con reverse proxy (Nginx, Traefik o ingress de Kubernetes)
- 🗄️ Usa una **base de datos gestionada** (Postgres externo, no en contenedor)
- 🔐 Usa **contraseñas seguras** y almacénalas en un gestor de secretos
- 📦 Versiona siempre tu tema y configuración, pero **no subas volúmenes ni `.env`**
- ☸️ Para Kubernetes considera usar el [Keycloak Operator](https://www.keycloak.org/operator/)
- 🎨 El tema personalizado funciona igual en producción, solo asegúrate de montarlo correctamente

---

## 📄 Licencia

Este proyecto se distribuye bajo la licencia **MIT**.  
© 2025 — Equipo de desarrollo de **Materiapp**.
