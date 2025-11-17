# 🧩 Materiapp Identity

Repositorio de infraestructura para **gestionar la identidad y autenticación de Materiapp** usando [Keycloak](https://www.keycloak.org/).  
Este proyecto define la configuración de Keycloak **como código**, de modo que puede reproducirse, versionarse y desplegarse fácilmente en cualquier entorno.

---

## 📘 Contenido del repositorio

```
materiapp-identity/
├─ realms/
│  └─ materiapp-realm.json        # Realm "materiapp" (roles, clients, etc.)
├─ scripts/
│  ├─ setup-realm.sh              # Inicializa el realm y crea usuario demo
│  └─ export-realm.sh             # Exporta el estado actual del realm
├─ compose.yml                    # Docker Compose con Keycloak + Postgres
├─ .env                           # Variables de entorno locales
└─ README.md                      # Este documento
```

---

## 🚀 Levantar el entorno

### 1️⃣ Requisitos previos
- [Docker](https://docs.docker.com/get-docker/) y [Docker Compose](https://docs.docker.com/compose/install/) instalados.
- Puerto **8080** libre (Keycloak) y **5434** libre (Postgres).

### 2️⃣ Clonar el repositorio
```bash
git clone https://github.com/tuusuario/materiapp-identity.git
cd materiapp-identity
```

### 3️⃣ Configurar variables de entorno
Crea el archivo `.env` (ya está en `.gitignore`):
```bash
KC_DB=postgres
KC_DB_HOST=kcdb
KC_DB_NAME=keycloak
KC_DB_USER=keycloak
KC_DB_PASSWORD=keycloak
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin
KC_HTTP_PORT=8080
KC_DB_PORT=5434
```

### 4️⃣ Levantar Keycloak y la base de datos
```bash
docker compose up -d
```

Esto inicia:
- **Postgres** (`kcdb`)  
- **Keycloak** en modo desarrollo (`start-dev --import-realm`)

Cuando el contenedor se inicia por primera vez, Keycloak importará automáticamente el archivo `realms/materiapp-realm.json`.

### 5️⃣ Acceder al panel de administración
- URL: [http://localhost:8080](http://localhost:8080)  
- Usuario: `admin`  
- Contraseña: `admin`  
- Realm por defecto: `materiapp`

---

## 🧑‍💻 Estructura del realm

El archivo [`realms/materiapp-realm.json`](./realms/materiapp-realm.json) contiene la definición base del realm **materiapp**:

| Elemento | Descripción |
|-----------|-------------|
| **Realm:** | `materiapp` |
| **Clients:** | `materiapp-web` (Angular SPA, PKCE) y `materiapp-api` (NestJS API) |
| **Roles:** | `admin`, `user` |
| **Usuario demo:** | `yorth / 123456` (rol `admin`) |
| **Issuer (OIDC):** | `http://localhost:8080/realms/materiapp` |

---

## 🧩 Scripts disponibles

### ▶️ `setup-realm.sh`
> Inicializa el realm `materiapp`, crea un usuario demo y asigna roles.

```bash
./scripts/setup-realm.sh
```

**Acciones:**
- Autenticación administrativa con `kcadm`.
- Verifica si el realm existe; si no, lo crea desde `materiapp-realm.json`.
- Crea el usuario `yorth` con contraseña `123456`.
- Asigna el rol `admin`.

---

### 💾 `export-realm.sh`
> Exporta el estado actual del realm `materiapp` desde el contenedor a `realms/materiapp-realm.json`.

```bash
./scripts/export-realm.sh
```

**Acciones:**
- Ejecuta `kc.sh export` dentro del contenedor Keycloak.
- Copia el archivo actualizado al host.
- Ideal para **versionar cambios** después de editar el realm en el panel.

---

## 🔐 Endpoints OIDC útiles

| Propósito | URL |
|------------|-----|
| Realm base | `http://localhost:8080/realms/materiapp` |
| Discovery document | `http://localhost:8080/realms/materiapp/.well-known/openid-configuration` |
| JWKS (validación JWT) | `http://localhost:8080/realms/materiapp/protocol/openid-connect/certs` |
| Token endpoint | `http://localhost:8080/realms/materiapp/protocol/openid-connect/token` |

---

## 🧠 Integración con las apps

### 🔹 Angular (materiapp-web)
Configura en `environment.ts`:
```ts
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

---

### 🔹 NestJS (materiapp-api)
Configura tu guard de validación JWT con los valores del realm:

```ts
issuer: 'http://localhost:8080/realms/materiapp',
audience: 'materiapp-web',
jwksUri: 'http://localhost:8080/realms/materiapp/protocol/openid-connect/certs'
```

---

## ⚙️ Mantenimiento

| Acción | Comando |
|--------|----------|
| Levantar servicios | `docker compose up -d` |
| Ver logs | `docker compose logs -f keycloak` |
| Reiniciar Keycloak | `docker compose restart keycloak` |
| Exportar realm | `./scripts/export-realm.sh` |
| Crear usuario demo | `./scripts/setup-realm.sh` |
| Detener servicios | `docker compose down` |

---

## 🧱 Notas para producción

- Usa `start` en lugar de `start-dev`.
- Configura HTTPS con reverse proxy (Nginx, Traefik o ingress de Kubernetes).
- Usa una base de datos gestionada (Postgres externo).
- Versiona siempre los `realms/*.json` y **no subas volúmenes ni .env**.
- Para despliegue en Kubernetes puedes usar el [Keycloak Operator](https://www.keycloak.org/operator/).

---

## 📄 Licencia
Este proyecto se distribuye bajo la licencia **MIT**.  
© 2025 — Equipo de desarrollo de **Materiapp**.
