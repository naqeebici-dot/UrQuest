# Plan ejecutable — Rebranding Aura + UI Mercado + RegexDictionaryService UGC

Plan dividido en dos fases. Frontend Flutter en `ur_quest/`, backend Node/Express/Prisma en `ur_quest_backend/`. La BD mantiene el campo `gritBalance` (no se migra); la UI y los JSON de respuesta hablan en términos de **Aura**.

---

## FASE 1 — Rebranding moneda + UI Mercado

### Paso 1 · Centralizar el literal de la moneda (Flutter)
**Archivos a crear:**
- `ur_quest/lib/theme/app_strings.dart`

**Contenido clave:**
- `class AppStrings { static const currency = 'AURA'; static const currencySymbol = 'Φ'; /* o reutilizar Icons.hexagon */ }`

**Por qué:** un único punto de cambio para futuros rebrandings; el resto de widgets importan esta constante en lugar de hardcodear `$ASH`/`Grit`.

### Paso 2 · Reemplazar literales `$ASH` / `Grit` en toda la UI Flutter
**Archivos a modificar (búsqueda exhaustiva de `\$ASH`, `ASH`, `Grit`, `gritReward`-textos, `gritBalance`-textos):**
- `ur_quest/lib/screens/dashboard_screen.dart`
  - Línea ~138: badge HUD `'${user.gritBalance} \$ASH'` → `'${user.gritBalance} ${AppStrings.currency}'`.
  - Línea ~624 (SnackBar): `'+${m.gritReward} \$ASH / +${m.xpReward} XP'` → `'+${m.gritReward} AURA / +${m.xpReward} XP'`.
  - Comentario línea ~173 “Saldo de Grit” → “Saldo de Aura”.
- `ur_quest/lib/screens/market_screen.dart`
  - Subtítulo línea ~138 `[ MERCADO DE RECOMPENSAS — $ASH EXCHANGE ]` → `[ MERCADO DE RECOMPENSAS — AURA EXCHANGE ]`.
  - Badge saldo línea ~173 (`r' $ASH'`) → ` AURA`.
  - Tarjeta `RewardCard` línea ~638 (` $ASH`) → ` AURA`.
  - `_DetailContent` líneas 857, 886, 943 (`\$ASH`) → `AURA`.
  - `_BigCtaButton` línea ~1053 `'EJECUTAR CANJE — ${reward.currentCost} \$ASH'` → texto del Paso 4 (botón gigante).
  - `_confirmPurchase` líneas 1130, 1141, 1374, 1385 (`\$ASH`) → `AURA`.
  - SnackBar líneas 1236, 1476 mensaje sistema: dejar como “Intercambio completado”.
  - `_CtaButton` línea 1304 (`\$ASH`) → `AURA`.
- `ur_quest/lib/widgets/mission_card.dart`
  - Línea 122: `'+${mission.gritReward} \$ASH'` → `'+${mission.gritReward} AURA'`.
- `ur_quest/lib/widgets/hud_bar.dart`: revisar, sin literales monetarios (no requiere cambio).
- `ur_quest/lib/main.dart`: revisar comentarios; no hay literales.
- `ur_quest/lib/models/*`: **no renombrar el campo `gritBalance`** del `UserModel` ni `gritReward` del `MissionModel` (compatibilidad con backend); sólo se renombra el texto mostrado. Añadir getter alias `int get auraBalance => gritBalance;` en `UserModel` y `int get auraReward => gritReward;` en `MissionModel` para usar en widgets nuevos.
- `ur_quest/lib/providers/game_providers.dart`
  - Renombrar método público `addGrit(int amount)` → `addAura(int amount)` manteniendo el `_copyWith(... gritBalance: ...)` por dentro. Actualizar llamadas en `dashboard_screen.dart` (líneas 596, 112) y en `RewardsNotifier.buyReward` (línea 112).
  - Comentario línea 100 `Descuenta $ASH` → `Descuenta AURA`.

**Riesgo:** romper imports/símbolos si se renombra el campo del modelo. Mitigación: **mantener `gritBalance` y `gritReward` como campos**, sólo cambiar el texto visible y exponer alias de lectura.

### Paso 3 · Backend: exponer `auraBalance` en respuestas JSON manteniendo BD intacta
**Archivos a modificar:**
- `ur_quest_backend/src/controllers/userController.ts`
  - En el `select` del `prisma.user.create` (línea ~20) seguir leyendo `gritBalance`; en la respuesta serializar como `{ ...user, auraBalance: user.gritBalance }` (duplicar campo, no sustituir, por compatibilidad).
- `ur_quest_backend/src/controllers/missionController.ts`
  - Mensaje línea 81: `+${mission.gritReward} Grit` → `+${mission.gritReward} Aura`.
  - En respuesta JSON añadir `aura: { reward: mission.gritReward, balance: updatedUser.gritBalance }` junto a `user`.
- `ur_quest_backend/src/controllers/rewardController.ts` y `marketController.ts`
  - Mensajes con `$ASH`/`Grit` (líneas 32, 64, 78) → `AURA`.
  - En el JSON de respuesta añadir `auraSpent: currentCost` junto a `gritSpent` y `auraBalance: updatedUser.gritBalance` junto a `user`.
- `ur_quest_backend/prisma/schema.prisma`: **NO TOCAR** (mantener `gritBalance`, `gritReward`, `gritPenalty`, `gritSpent`, `gritApplied`).

**Riesgo conocido (declarado por el usuario):** cualquier futura migración limpia deberá renombrar columnas Prisma + migración SQL. El alias `auraBalance` en JSON es el puente para esa transición sin breaking changes para la app móvil.

### Paso 4 · Rediseñar panel de detalles de reward (sin desglose matemático)
**Archivo a modificar:** `ur_quest/lib/screens/market_screen.dart`, clase `_DetailContent` (líneas 724-967).

**Cambios precisos:**
1. **Eliminar bloque líneas 849-894** (las 3 filas COSTE BASE / INFLACIÓN / COSTE ACTUAL).
2. **Añadir Chip “INFLACIÓN ACTIVA”** junto al título (después del `Text(reward.title.toUpperCase())` en línea ~787). Sólo si `reward.weeklyPurchases > 0`:
   - `Container` con `border: Border.all(color: AppColors.neonRed, width: 1.2)`, fondo `neonRed.withValues(alpha:0.08)`, `borderRadius: 20`, `boxShadow` rojo neón (`blurRadius: 14`).
   - Texto `'[ INFLACIÓN ACTIVA ]'` en `GoogleFonts.shareTechMono`, color `neonRed`, `fontSize 11`, `letterSpacing 2`, con `Shadow` neón.
   - Layout: `Wrap` o `Column` para que quede debajo del título grande, encima del badge tier.
3. **Botón gigante CANJEAR** (reemplazo del `_BigCtaButton` actual):
   - Texto: `'CANJEAR · ${reward.currentCost} AURA'` (cuando `canAfford && !isPurchased`).
   - Mantener variantes: `'[ FONDOS INSUFICIENTES ]'`, `'INTERCAMBIO COMPLETADO'`.
   - Altura 70-80px, ancho `double.infinity`, glow del color del tier (ya existe), iconos `Icons.bolt`/`Icons.lock_outline`/`Icons.check_circle`.
4. **Eliminar `_CtaButton`** (líneas 1253-1488, duplicado obsoleto) y todas sus referencias.
5. Limpiar las funciones `_confirmPurchase` (dejar una sola en `_BigCtaButton`) para que el SnackBar y el diálogo usen `AURA`.

**Resultado UX:** panel limpio = emoji holograma + título + chip “INFLACIÓN ACTIVA” (rojo neón opcional) + badge tier + caja de lore + (si GOLD) warning + botón gigante. Cero matemáticas a la vista.

### Paso 5 · Descripciones RPG épicas
**Archivos a modificar:**
- `ur_quest_backend/prisma/seed.ts` — array `REWARDS` (líneas 42-47). Reescribir cada `description` en clave RPG/sci-fi clínica:
  - Cerveza: `"Brebaje sedante de baja graduación. Ralentiza los procesos cognitivos pero restaura la fatiga mental a corto plazo."`
  - Netflix 1 hora: `"Cápsula audiovisual narrativa. Suspende el flujo temporal y libera dopamina pasiva durante 60 minutos."`
  - Salir de fiesta: `"Inmersión en un nodo social caótico. Alto consumo energético, reservas de SOC restauradas si la misión culmina con éxito."`
  - Capricho Caro: `"Adquisición material no esencial. Riesgo elevado de corrupción del bucle motivacional. Activar bajo supervisión del Sistema."`
- `ur_quest/lib/models/reward_model.dart` — método `mockRewards()` (líneas 42-136): aplicar el mismo estilo en las 9 entradas (Cerveza Premium, Cheat Meal, Siesta 30 min, Netflix Night, Salida de Fiesta, Día sin alarma, Fin de semana Libre, Viaje Espontáneo, Capricho Extremo). Ej. Siesta: `"Ciclo de reparación breve. Recompone los condensadores neuronales sin entrar en sueño profundo."`.
- `ur_quest/lib/models/mission_model.dart` — opcional pero coherente: mantener el tono actual (ya es épico-sistema), no requiere reescritura.

---

## FASE 2 — RegexDictionaryService + UGC

### Paso 6 · Crear `RegexDictionaryService`
**Archivo a crear:** `ur_quest/lib/services/regex_dictionary_service.dart`

**Diseño:**
- Clase `RegexDictionaryService` con método `EvaluationResult evaluate(String text, {required EntryMode mode})`.
- `enum EntryMode { mission, reward }`.
- `class EvaluationResult { int? suggestedReward; int? suggestedCost; String? detectedAttribute; RewardTier? detectedTier; List<String> matchedKeywords; }`.
- Estructura interna **modular**:
  ```dart
  class _MissionBucket { final List<String> keywords; final int baseAura; final String attribute; }
  static const _missionBuckets = <_MissionBucket>[
    _MissionBucket(['correr','gym','fuerza','entrenar','pesas','flexiones'], 50, 'VIT'),
    _MissionBucket(['leer','estudiar','programar','curso','idioma'],         40, 'INT'),
    _MissionBucket(['meditar','respirar','mindfulness','gratitud'],          30, 'ESP'),
    _MissionBucket(['dibujar','pintar','componer','escribir','cocinar'],     35, 'CREA'),
    _MissionBucket(['ajedrez','planificar','presupuesto','ahorrar'],         45, 'LOG'),
    _MissionBucket(['llamar','familia','amigos','networking','quedar'],      25, 'SOC'),
  ];
  ```
- Igual con `_ViceBucket { keywords, costRange (min,max), tier }`:
  - `['alcohol','fiesta','juego','casino','apuesta']` → `(500,1500)` GOLD
  - `['netflix','dulce','redes','tiktok','youtube']` → `(50,200)` SILVER
  - `['cafe','snack','refresco']` → `(15,40)` BRONZE
- **Multiplicador numérico**: regex `RegExp(r'(\d+)\s*(km|paginas|minutos|min|horas|reps|series)', caseSensitive: false)`. Si match → `multiplier = numero * 2`, se suma al `baseAura` (no se multiplica, según enunciado: “multiplicar por 2 sobre la base” se interpreta como `base + numero*2`; confirmar con usuario en Further Considerations).
- Normalización: pasar el texto a minúsculas + quitar tildes (`_stripDiacritics`).
- Coste de vicio: punto medio del rango o aleatorio sembrado por hash del título para estabilidad entre renders.

### Paso 7 · Crear `CreateEntryDialog` modal
**Archivo a crear:** `ur_quest/lib/widgets/create_entry_dialog.dart`

**Diseño:**
- `class CreateEntryDialog extends ConsumerStatefulWidget { final EntryMode mode; }`.
- `Dialog` con `backgroundColor: AppColors.surface`, borde neón cyan (mode mission) o gold (mode reward), `borderRadius: 14`, `boxShadow` glow.
- Estructura:
  - Header tipo terminal `'> NEW ${mode == mission ? "MISSION" : "REWARD"}_'` con caret parpadeante.
  - `TextField` controlado (`_titleCtrl`) con `decoration` neón (border `OutlineInputBorder` + glow), `hintText` mode-dependiente.
  - `Timer? _debounce`; `onChanged` → `_debounce?.cancel(); _debounce = Timer(Duration(milliseconds:300), () => setState(() => _eval = service.evaluate(text, mode: mode)));`.
  - Preview live (debajo del input):
    - `'AURA SUGERIDA: ${_eval.suggestedReward ?? "—"}'` con shimmer cyan.
    - Si mission: `'ATRIBUTO: ${_eval.detectedAttribute ?? "—"}'` con color del atributo.
    - Si reward: `'TIER: ${_eval.detectedTier?.name ?? "—"}'` y `'COSTE: ${_eval.suggestedCost ?? "—"}'`.
    - `Wrap` de `Chip`s neón con `_eval.matchedKeywords`.
  - Botones: `[ ABORTAR ]` y `[ CREAR ]` (cyan glow).
- Acción `[ CREAR ]`:
  - Mission → `ref.read(customMissionsProvider.notifier).add(MissionModel(...generado..., gritReward: _eval.suggestedReward ?? 10, attribute: _eval.detectedAttribute ?? 'INT'))`.
  - Reward → `ref.read(customRewardsProvider.notifier).add(RewardModel(...generado..., baseCost: _eval.suggestedCost ?? 50, currentCost: _eval.suggestedCost ?? 50, tier: _eval.detectedTier ?? RewardTier.BRONZE))`.
  - `// TODO: POST al backend cuando exista endpoint /missions y /rewards (UGC)`.
  - `Navigator.pop(context)`.

### Paso 8 · Providers UGC locales
**Archivo a modificar:** `ur_quest/lib/providers/game_providers.dart`

**Añadir al final:**
```dart
final customMissionsProvider =
    NotifierProvider<CustomMissionsNotifier, List<MissionModel>>(CustomMissionsNotifier.new);

class CustomMissionsNotifier extends Notifier<List<MissionModel>> {
  @override List<MissionModel> build() => [];
  void add(MissionModel m) => state = [...state, m];
}

final customRewardsProvider =
    NotifierProvider<CustomRewardsNotifier, List<RewardModel>>(CustomRewardsNotifier.new);

class CustomRewardsNotifier extends Notifier<List<RewardModel>> {
  @override List<RewardModel> build() => [];
  void add(RewardModel r) => state = [...state, r];
}
```

**Y combinar con los providers existentes:**
- Modificar `dailyMissionsProvider` no, sino crear `final allMissionsProvider = Provider<List<MissionModel>>((ref) => [...ref.watch(dailyMissionsProvider).valueOrNull ?? [], ...ref.watch(customMissionsProvider)]);`.
- Igual `allRewardsProvider` que combina `rewardsProvider` + `customRewardsProvider`.
- En `dashboard_screen.dart` y `market_screen.dart`, leer `allMissionsProvider` / `allRewardsProvider` en lugar de los originales para que las creaciones aparezcan en grid/PageView.

### Paso 9 · Añadir FABs con glow neón
**Archivos a modificar:**
- `ur_quest/lib/screens/dashboard_screen.dart`
  - Añadir `floatingActionButton:` al `Scaffold` de `_HudBody` (línea 112):
    ```dart
    floatingActionButton: FloatingActionButton(
      backgroundColor: AppColors.neonCyan,
      foregroundColor: Colors.black,
      elevation: 12,
      onPressed: () => showDialog(context: context,
          builder: (_) => const CreateEntryDialog(mode: EntryMode.mission)),
      child: const Icon(Icons.add, size: 28),
    ),
    ```
  - Envolver en `Container` con `BoxShadow` cyan para reforzar glow.
- `ur_quest/lib/screens/market_screen.dart`
  - Añadir `floatingActionButton:` al `Scaffold` de `MarketScreen` (línea 59) con `mode: EntryMode.reward`, color `AppColors.neonGold`.

### Paso 10 · Limpiezas y consistencia final
- Búsqueda global en `ur_quest/lib/**/*.dart` de `\$ASH`, `'ASH'`, `Grit ` (con espacio): confirmar que sólo quedan referencias en comentarios o nombres de campo de modelo.
- Búsqueda global en `ur_quest_backend/src/**/*.ts` de `Grit`/`$ASH` en strings de respuesta: sustituir por `Aura`/`AURA`.
- Re-ejecutar `npm run seed` para refrescar descripciones del Mercado.
- Smoke test manual: HUD muestra `AURA`, Market detail no muestra desglose, FAB Mission/Reward abre dialog, escribir “correr 5km” muestra `AURA SUGERIDA: 60` y `ATRIBUTO: VIT`.

---

## Riesgos conocidos
1. **`gritBalance` en BD permanece** — la UI ya no menciona “Grit/$ASH”, pero los DTOs internos y migraciones Prisma siguen usando el nombre. Cada respuesta JSON añade el alias `auraBalance`/`auraSpent` (duplicado, no sustituto) para una futura migración limpia sin breaking changes.
2. **Refactor del provider `addGrit → addAura`** puede dejar referencias muertas. Buscar `addGrit(` en todo `lib/` antes de mergear.
3. **Multiplicador numérico ambiguo** (“×2 sobre la base”): se asume `total = base + numero*2`. Si el usuario prefiere `total = base * 2` cuando hay número, es un ajuste de una sola línea en `RegexDictionaryService`.
4. **UGC sin persistencia**: las misiones/rewards custom se pierden al cerrar la app (in-memory). Marcado con `// TODO` para futura iteración con endpoints REST.
5. **Mock `RewardModel.mockRewards()`** debe mantenerse en sync con el seed del backend para evitar disonancia offline/online.

