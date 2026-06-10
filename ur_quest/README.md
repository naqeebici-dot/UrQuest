# UrQuest 🎮⚔️

> **Convierte tu vida en un RPG.** UrQuest es una aplicación de hábitos gamificada donde completas misiones reales (ejercicio, lectura, meditación…) para ganar XP, subir de nivel y desbloquear recompensas. Tu personaje crece con el hexágono de atributos: INT · LOG · CREA · ESP · VIT · SOC.

---

## 📁 Estructura del Repositorio

```
AppHabitos/
├── ur_quest/            # Frontend Flutter  ← estás aquí
└── ur_quest_backend/    # Backend Node.js + Express + Prisma + PostgreSQL
```

---

## 🛠️ Requisitos Previos

| Herramienta | Versión mínima | Notas |
|---|---|---|
| Flutter SDK | 3.x | `flutter --version` |
| Dart SDK | 3.x | Incluido con Flutter |
| Node.js | 18+ | `node --version` |
| PostgreSQL | 14+ | Servidor local o Docker |
| npm | 9+ | `npm --version` |

---

## 🗄️ 1. Base de Datos (PostgreSQL)

### 1.1 Crear la base de datos

Abre `psql` o tu cliente favorito (pgAdmin, DBeaver…) y ejecuta:

```sql
CREATE DATABASE ur_quest;
CREATE USER ur_quest_user WITH PASSWORD 'tu_password';
GRANT ALL PRIVILEGES ON DATABASE ur_quest TO ur_quest_user;
```

### 1.2 Crear el fichero `.env`

Dentro de `ur_quest_backend/`, crea un archivo `.env`:

```env
# Cadena de conexión a PostgreSQL
DATABASE_URL="postgresql://ur_quest_user:tu_password@localhost:5432/ur_quest"

# Puerto del servidor (opcional, por defecto 3000)
PORT=3000
```

### 1.3 Ejecutar las migraciones con Prisma

```powershell
cd ur_quest_backend
npm install
npx prisma migrate dev --name init
```

Esto crea todas las tablas en PostgreSQL según el schema definido en `prisma/schema.prisma`.

### 1.4 (Opcional) Explorador visual de la BD

```powershell
npx prisma studio
# → Abre http://localhost:5555
```

---

## ⚙️ 2. Backend (Node.js + Express)

### 2.1 Instalar dependencias

```powershell
cd ur_quest_backend
npm install
```

### 2.2 Arrancar en modo desarrollo (con hot-reload)

```powershell
npm run dev
```

El servidor quedará escuchando en: **`http://localhost:3000`**

Verificación rápida:

```powershell
curl http://localhost:3000
# → {"status":"ok","message":"[SISTEMA]: UrQuest Backend activo."}
```

### 2.3 Arrancar en modo producción

```powershell
npm start
```

---

## 📡 API Reference

Base URL: `http://localhost:3000/api`

### Usuarios

| Método | Endpoint | Descripción |
|---|---|---|
| `POST` | `/api/users` | Registrar nuevo usuario |
| `GET` | `/api/users/:id` | Obtener perfil del usuario |

**POST `/api/users`** — Body:
```json
{
  "username": "HeroName",
  "email": "hero@urquest.io",
  "password": "secret123"
}
```

### Misiones

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/api/missions/daily/:userId` | Obtener misiones diarias |
| `POST` | `/api/missions/complete` | Marcar misión como completada |

**POST `/api/missions/complete`** — Body:
```json
{
  "userId": "uuid-del-usuario",
  "missionId": "uuid-de-la-mision",
  "elapsedSeconds": 1800
}
```

### Recompensas (legacy)

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/api/rewards` | Listar recompensas (sin precio dinámico) |
| `POST` | `/api/rewards/buy` | Canjear recompensa (legacy) |

### 🛒 Market (economía dinámica)

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/api/market` | Lista de vicios con precio inflacionado en tiempo real |
| `POST` | `/api/market/buy` | Comprar recompensa con $ASH (aplica inflación + corrupción) |

**GET `/api/market`** — Respuesta:
```json
{
  "market": [
    {
      "id": "uuid",
      "name": "Cerveza / Refresco",
      "tier": "BRONZE",
      "baseCost": 50,
      "currentCost": 55,
      "weeklyPurchases": 1,
      "inflationRate": 0.1
    }
  ]
}
```

**POST `/api/market/buy`** — Body:
```json
{ "userId": "uuid", "rewardId": "uuid" }
```
Si el tier es `GOLD` o `CUSTOM`, el `corruptionScore` del usuario sube +10. Si llega a 80+, la respuesta incluye:
```json
{ "warning": "Corrupción crítica", "corruptionWarning": { "level": 80, "locked": false } }
```

---

## 📱 3. Frontend (Flutter)

### 3.1 Instalar dependencias

```powershell
cd ur_quest
flutter pub get
```

### 3.2 Configurar la URL del backend

Edita `lib/services/api_service.dart` y ajusta `_baseUrl` según tu entorno:

```dart
// 🌐 Web / localhost
static const _baseUrl = 'http://127.0.0.1:3000';

// 📱 Emulador Android
// static const _baseUrl = 'http://10.0.2.2:3000';

// 📱 Dispositivo físico (usa tu IP local)
// static const _baseUrl = 'http://192.168.1.XX:3000';
```

Para conocer tu IP local en Windows:
```powershell
ipconfig | Select-String "IPv4"
```

### 3.3 Arrancar en Chrome (desarrollo)

```powershell
flutter run -d chrome
```

### 3.4 Arrancar en emulador Android

```powershell
flutter emulators --launch <nombre_emulador>
flutter run
```

### 3.5 Build de producción web

```powershell
flutter build web
# Salida en: ur_quest/build/web/
```

---

## 🏗️ Arquitectura del Frontend

```
lib/
├── main.dart                  # Punto de entrada + ProviderScope
├── models/
│   ├── user_model.dart        # UserModel con lógica de XP/HP/nivel
│   └── mission_model.dart     # MissionModel + enums Rank/Status
├── providers/
│   └── game_providers.dart    # Estado global con Riverpod (AsyncNotifier)
├── screens/
│   └── dashboard_screen.dart  # Pantalla principal HUD
├── services/
│   ├── api_service.dart       # Cliente HTTP (Dio) → backend
│   └── audio_service.dart     # Efectos de sonido (audioplayers)
├── theme/
│   └── app_theme.dart         # Colores neón, tipografía, constantes
└── widgets/
    ├── hud_bar.dart           # Barra de progreso tipo HUD (HP / XP)
    ├── hex_radar_chart.dart   # Hexágono de atributos con glow neón
    └── mission_card.dart      # Tarjeta de misión con botón DONE
```

---

## 🗃️ Modelo de Datos

```
User ──────────── UserAttribute  (nivel por atributo)
  │
  ├── MissionLog  (historial de misiones realizadas)
  └── Purchase    (historial de recompensas canjeadas)

Mission ────────── Attribute  (INT / LOG / CREA / ESP / VIT / SOC)
Reward ──────────── Purchase
```

### Atributos del Hexágono

| Código | Nombre | Color | Ejemplos de misión |
|---|---|---|---|
| `INT` | Intelecto | Azul | Leer 20 páginas, estudiar idioma |
| `LOG` | Lógica | Verde | Resolver reto de código, ajedrez |
| `CREA` | Creatividad | Rosa | Practicar instrumento, dibujar |
| `ESP` | Espiritualidad | Violeta | Meditar 10m, diario de gratitud |
| `VIT` | Vitalidad | Rojo | Entrenar 30m, correr 5km |
| `SOC` | Social | Cyan | Llamar a un familiar, evento social |

### Clases de Personaje (se desbloquean al Nivel 20)

| Clase | Atributos principales | Bonus |
|---|---|---|
| `ARCHITECT` | LOG + INT | Bonus en misiones de foco y concentración |
| `NOMAD` | VIT + SOC | Bonus en misiones de mundo abierto |
| `MYSTIC` | ESP + CREA | Resetea inflación de recompensas antes |

---

## 💰 Sistema Económico ($ASH / Grit)

- Cada misión completada otorga **$ASH** (moneda del juego) y **XP**.
- **Fórmula de nivel:** `xpToNextLevel = 100 × level^1.5`
- Las recompensas tienen **inflación dinámica**: cada compra sube el precio un 10%, simulando el coste real del ocio.
- Si fallas una misión: pierdes **HP** y **Grit**.
- Si `HP = 0` o `corruptionScore > 80`: se bloquea el progreso hasta recuperar hábitos.

---

## 🔊 Assets de Sonido

Coloca los archivos en `ur_quest/assets/sounds/`:

| Archivo | Evento |
|---|---|
| `success.mp3` | Misión completada ✅ |

Puedes descargar sonidos gratuitos en [freesound.org](https://freesound.org) — busca *"level up chime"* o *"victory short"*.

---

## 🚀 Arranque Completo (Resumen Rápido)

```powershell
# Terminal 1 — Base de datos
pg_ctl start                         # Arranca el servidor PostgreSQL

# Terminal 2 — Backend
cd ur_quest_backend
npm install                          # Solo la primera vez
npx prisma migrate dev --name init   # Solo la primera vez
npm run seed                         # Siembra atributos, misiones y vicios base
npm run dev                          # Arranca en http://localhost:3000

# Terminal 3 — Frontend
cd ur_quest
flutter pub get                      # Solo la primera vez
flutter run -d chrome
```

---

## 🐛 Troubleshooting

### `Building with plugins requires symlink support`
Habilita el **Modo Desarrollador** en Windows → `start ms-settings:developers`.  
Si no tienes permisos de admin, pídele al administrador que lo active o trabaja desde WSL.

### `CORS error` en el frontend web
El backend ya tiene `cors()` habilitado. Verifica que el backend esté corriendo y que `_baseUrl` en `api_service.dart` apunte a `http://127.0.0.1:3000` (no `localhost`).

### `PrismaClientInitializationError`
Verifica que la variable `DATABASE_URL` en `.env` es correcta y que PostgreSQL está activo.

### Flutter `BOTTOM OVERFLOWED`
El `expandedHeight` del `SliverAppBar` está calibrado en 178px. Si cambias fuentes o añades elementos al header, ajusta ese valor en `dashboard_screen.dart`.

### El sonido no suena en Chrome
Los navegadores bloquean audio sin interacción previa del usuario. El sonido se reproduce correctamente en Android/iOS. En web, asegúrate de que el usuario haya interactuado con la página antes de completar la primera misión.

---

## 📜 Licencia

Proyecto privado — todos los derechos reservados © 2026 UrQuest.
