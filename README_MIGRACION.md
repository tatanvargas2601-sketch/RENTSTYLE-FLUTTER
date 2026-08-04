# RentStyle - App Flutter (migración desde React)

## Cambios de esta revisión

1. **Tema visual** (`lib/core/theme/app_theme.dart`) ahora usa la paleta exacta de
   `src/styles/styles.css` (verde `#1f7d34`, fondo `#eff7ee`, modo oscuro `#102012`, etc.)
   y las mismas tipografías (Inter + Playfair Display, vía el paquete `google_fonts`).
2. **Login rediseñado** (`lib/screens/auth/login_screen.dart`) calcado de tu `Login.jsx`
   / `login.css`: nav superior con logo, botón de tema y pills "Inicio"/"Registrarse",
   panel izquierdo con degradado y bullets, tarjeta blanca redondeada a la derecha
   (o abajo en pantallas angostas, igual que tu breakpoint de 900px).
3. **Bug de navegación tras login corregido**: antes, un admin/empleado que iniciaba
   sesión se quedaba en el catálogo público en vez de ir a su dashboard. Ahora
   `app_router.dart` redirige según el rol, y el propio botón de login también
   navega explícitamente (como hace tu `Login.jsx` con `navigate()`).
4. **Bug de sesión persistente corregido**: al reabrir la app con un token guardado,
   se perdía el rol del usuario (quedaba `null`), lo que podía bloquear a un admin de
   su propio panel. Ahora se usa el payload real de `GET /api/verify-token`
   (`{ idUsuario, correo, rol, exp }`) para restaurar el rol correctamente.
5. Mensajes de error más claros en el login (credenciales incorrectas vs. error de red).


Este scaffold contiene la lógica de negocio y las pantallas principales migradas desde
`RENTSTYLE-FRONT-EDN` (React) para consumir el mismo backend Flask (`RENTSTYLE-BACK-END`).

## 1. Cómo poner esto en marcha

Este zip **no incluye las carpetas nativas** (`android/`, `ios/`, `web/`, etc.) porque
se generan con el SDK de Flutter, que no está disponible en este entorno. Pasos:

```bash
# 1. Descomprime este proyecto en una carpeta, por ejemplo:
unzip rentstyle_flutter.zip -d rentstyle_flutter
cd rentstyle_flutter

# 2. Genera las carpetas nativas que faltan (respeta lib/ y pubspec.yaml existentes)
flutter create . --project-name rentstyle_app

# 3. Instala dependencias
flutter pub get

# 4. Corre la app (con el backend Flask corriendo en localhost:5000)
flutter run
```

## 2. Antes de correrla, ajusta esto

1. **URL del backend** — en `lib/core/api/api_client.dart`:
   ```dart
   const String kApiBaseUrl = 'http://10.0.2.2:5000'; // emulador Android
   ```
   Cambia a `http://localhost:5000` (iOS simulator) o a la IP de tu PC en la red
   (dispositivo físico). Asegúrate de correr `python run.py` en el backend.

2. **CORS en el backend** (solo si usas Flutter Web) — en
   `RENTSTYLE-BACK-END/app/__init__.py`:
   ```python
   CORS(app, origins=["http://localhost:5173", "http://localhost:<puerto-flutter-web>"])
   ```

3. **Rutas exactas del backend** — algunas rutas fueron inferidas por convención
   (`/api/prendas/<id>/imagenes`, filtros por query params en usuarios/reservas/citas).
   Revisa tus blueprints (`prendas_bp.py`, `reservas_bp.py`, `citas_bp.py`) y ajusta
   las URLs en `lib/services/*.dart` si difieren.

4. **`kDefaultUserRoleId`** en `lib/screens/auth/register_screen.dart` — pon el id
   real del rol "user" en tu tabla `Roles` (o haz `GET /api/roles` para resolverlo
   dinámicamente).

5. **`idAdministrador` fijo** en `cart_screen.dart` y `agendar_cita_screen.dart` —
   hoy está hardcodeado a `1` como ejemplo; reemplázalo por tu regla real de negocio
   (¿el backend lo asigna solo? ¿se elige un empleado disponible?).

## 3. Qué falta pulir (a propósito, para no sobre-diseñar sin tus datos reales)

- **Validaciones de formulario** más estrictas (documento único, formato de correo, etc.)
- **Manejo de subida de avatar** en `ProfileScreen` (hoy solo lo muestra, no lo edita)
- **Paginación** en listas de admin si tu catálogo crece mucho
- **Pull-to-refresh** (`RefreshIndicator`) en las listas — es rápido de añadir
- **Splash screen** / ícono de la app con `flutter_native_splash` y `flutter_launcher_icons`
- Tests (unitarios de servicios/providers, widget tests de pantallas clave)

## 4. Mapeo rápido React → Flutter (referencia)

| React | Flutter |
|---|---|
| `services/api.jsx` (axios + interceptor) | `core/api/api_client.dart` (dio + interceptor) |
| `services/*Service.js` | `services/*_service.dart` |
| `context/ThemeContext.jsx` | `providers/theme_provider.dart` |
| `pages/*.jsx` | `screens/**/*.dart` |
| `react-router-dom` (`<Routes>`) | `go_router` (`app_router.dart`) |
| `localStorage.getItem('token')` | `flutter_secure_storage` (`token_storage.dart`) |
| Cloudinary URLs devueltas por el backend | `cached_network_image` |

## 5. Estructura

```
lib/
  core/        -> api client, storage, router, tema
  models/      -> 1 clase por tabla del backend
  services/    -> 1 archivo por blueprint Flask
  providers/   -> estado global con Riverpod
  screens/     -> pantallas, organizadas por rol/feature
  widgets/     -> componentes reutilizables
```
