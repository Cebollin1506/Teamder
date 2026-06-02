# TEAMDER Frontend

Frontend Vue 3 + Vite para TEAMDER, una plataforma academica donde estudiantes pueden registrarse, iniciar sesion, buscar tutores o estudiantes, publicar solicitudes de tutoria y conectar con otros usuarios.

## Stack

- Vue 3 con Composition API
- Vite
- Vue Router
- Pinia
- Axios
- API REST PHP local

## Ejecutar el proyecto

```bash
npm install
npm run dev
```

La app se ejecuta en:

```txt
http://localhost:5173
```

## Configuracion de API

El frontend espera el backend PHP en:

```txt
http://localhost/Teamder_Backend/api/
```

Puedes cambiarlo creando un archivo `.env` a partir de `.env.example`:

```bash
cp .env.example .env
```

```env
VITE_API_BASE_URL=http://localhost/Teamder_Backend/api/
```

Endpoints usados:

- `POST /register.php`
- `POST /login.php`
- `GET /users.php`
- `GET /users.php?me=true`
- `POST /tutoring_requests.php`

## Crear y conectar la base de datos

### 1. Crear la base en MySQL

Si usas XAMPP:

1. Abre XAMPP Control Panel.
2. Inicia `Apache` y `MySQL`.
3. Entra a `http://localhost/phpmyadmin`.
4. Ve a la pestana `SQL`.
5. Ejecuta el archivo [database/teamder.sql](database/teamder.sql).

Tambien puedes importarlo por consola:

```bash
mysql -u root -p < database/teamder.sql
```

El script crea:

- base de datos `teamder`
- tabla `users`
- tabla `tutoring_requests`
- usuarios de ejemplo

### 2. Configurar la conexion PHP

En el backend PHP local crea esta carpeta:

```txt
C:\xampp\htdocs\Teamder_Backend\api\
```

Copia los archivos de ejemplo desde:

```txt
backend-examples/api/
```

hacia:

```txt
C:\xampp\htdocs\Teamder_Backend\api\
```

El archivo importante es `db.php`:

```php
$host = "localhost";
$database = "teamder";
$username = "root";
$password = "";
```

En XAMPP normalmente el usuario es `root` y la contrasena esta vacia. Si tu MySQL tiene otra contrasena, cambiala ahi.

### 3. Probar la API

Con Apache y MySQL encendidos, abre:

```txt
http://localhost/Teamder_Backend/api/users.php
```

Deberias ver una respuesta JSON con usuarios.

### 4. Conectar con el frontend

El frontend ya apunta a:

```txt
http://localhost/Teamder_Backend/api/
```

Si necesitas cambiarlo, crea `.env`:

```env
VITE_API_BASE_URL=http://localhost/Teamder_Backend/api/
```

Luego reinicia Vite:

```bash
npm run dev
```

### 5. Flujo recomendado para probar

1. Entra a `http://localhost:5173`.
2. Ve a registro.
3. Crea un usuario.
4. Entra al dashboard.
5. Revisa usuarios.
6. Publica una solicitud de tutoria.

Nota: los tokens del ejemplo PHP son simples para desarrollo local: `teamder-token-ID`. Para produccion conviene reemplazarlos por JWT o sesiones seguras.

## Estructura de carpetas

```txt
src/
  assets/styles/          Estilos globales responsive
  components/ui/          Componentes reutilizables
  layouts/                Layouts de autenticacion y dashboard
  modules/
    auth/                 Login, registro y servicio auth
    users/                Perfil, listado y servicio users
    tutoring/             Solicitudes de tutoria y servicio tutoring
  router/                 Vue Router y guards
  services/               Axios centralizado
  stores/                 Pinia stores
  views/                  Vistas generales
```

## Autenticacion

El login espera una respuesta JSON similar a:

```json
{
  "token": "jwt-o-token-generado",
  "user": {
    "id": 1,
    "name": "Ana Torres",
    "email": "ana@example.com",
    "role": "student"
  }
}
```

El token se guarda en `localStorage` con la clave `teamder_token`. Axios lo agrega automaticamente en cada request:

```txt
Authorization: Bearer <token>
```

Las rutas del dashboard estan protegidas con navigation guards. Si el usuario no tiene token, se redirige a `/auth/login`.

## Evitar errores CORS en PHP

Si aparece:

```txt
No 'Access-Control-Allow-Origin' header is present
```

agrega estos headers al inicio de cada endpoint PHP o en un archivo comun incluido por todos los endpoints. Si Vite usa `5174` porque `5173` ya estaba ocupado, permite ambos puertos:

```php
<?php
$allowedOrigins = [
    "http://localhost:5173",
    "http://localhost:5174",
    "http://127.0.0.1:5173",
    "http://127.0.0.1:5174",
];

$origin = $_SERVER["HTTP_ORIGIN"] ?? "";

if (in_array($origin, $allowedOrigins, true)) {
    header("Access-Control-Allow-Origin: {$origin}");
}

header("Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(204);
    exit;
}
```

Durante desarrollo tambien puedes usar `*`:

```php
header("Access-Control-Allow-Origin: *");
```

Pero para produccion es mejor usar el dominio exacto del frontend.

## Ejemplo minimo de login.php

```php
<?php
require_once "cors.php";

$input = json_decode(file_get_contents("php://input"), true);

if (($input["email"] ?? "") === "demo@teamder.com" && ($input["password"] ?? "") === "123456") {
    echo json_encode([
        "token" => "demo-token",
        "user" => [
            "id" => 1,
            "name" => "Usuario Demo",
            "email" => "demo@teamder.com",
            "role" => "student"
        ]
    ]);
    exit;
}

http_response_code(401);
echo json_encode(["message" => "Credenciales invalidas"]);
```

## Scripts

```bash
npm run dev      # servidor local
npm run build    # build de produccion
npm run preview  # previsualizar build
```
