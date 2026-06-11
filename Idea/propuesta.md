# The Apex Protocol: La Aplicación Definitiva de Hábitos

## 0. Resumen Ejecutivo: Idea Principal y MVP

### Idea Principal
"The Apex Protocol" es una aplicación gamificada diseñada para transformar el desarrollo personal en una experiencia inmersiva y adictiva. Combina mecánicas de videojuegos, psicología conductual y un modelo económico dinámico para motivar a los usuarios a cumplir sus metas diarias mientras gestionan sus "vicios" de manera responsable. La app utiliza un sistema de atributos, misiones y recompensas para crear un ecosistema vivo que evoluciona con el usuario.

### Producto Mínimo Viable (MVP)
Para garantizar un lanzamiento rápido y efectivo, el MVP se centrará en las siguientes características esenciales:

1. **Sistema de Atributos y Misiones Base:**
   - Implementación del hexágono de atributos y misiones diarias.
   - Ganancia de $ASH/Grit y penalizaciones por fallos.

2. **Economía Local:**
   - Tienda básica con "Inflación de Vicios" local (solo para el usuario).

3. **UX/UI:**
   - Interfaz en modo oscuro con diseño minimalista.
   - Uso de símbolos o runas en lugar de avatares complejos para ahorrar tiempo de diseño.

4. **Sistema de Castigo:**
   - Pérdida de puntos por fallar misiones.
   - Validación manual o basada en tiempo para las misiones.

Estas funcionalidades forman el núcleo del sistema y permitirán validar la aceptación del mercado antes de añadir características avanzadas como biometría, avatares evolutivos y sistemas globales.
Resumen visual de los pilares:
| Pilar                    | Significado                  |Importancia                           |
|--------------------------|------------------------------|--------------------------------------|
| Gamificación     (aprendizaje + juego)         | atributos + misiones  con consecuencias       | Los usuarios sienten progreso diario y constante  |
| Economía del esfuerzo    | Grit ganado con trabajo      | Convierte el autocontrol en algo     |  |                          | y gastado en recompensas     | tangible y adictivo                  |  
| Espejo honesto           | Anti-trampa, penalizaciones,medidor de corrupción | Los usuarios confían en el sistema porque no les miente (real y preciso)  |

## 1. El Sistema de Atributos: El "Polifacético"
Cada usuario tendrá un hexágono de stats que representa áreas cerebrales reales. Cada misión sube una rama:
- **INT (Intelecto):** Lectura, cursos, idiomas. (Córtex prefrontal)
- **LOG (Lógica/Estrategia):** Ajedrez, programación, finanzas. (Lóbulo parietal)
- **CREA (Creatividad):** Dibujo, música, cocina experimental. (Hemisferio derecho)
- **ESP (Espiritualidad/Mindfulness):** Meditación, gratitud. (Ínsula/control emocional)
- **VIT (Vitalidad):** Ejercicio, sueño, nutrición. (Sistema motor)
- **SOC (Social):** Networking, familia, amigos. (Inteligencia emocional)

## 2. La Economía: "Work Hard, Play Harder"
El Marketplace de Vicios es el corazón de la app. La moneda ($ASH o Credits) se gana con esfuerzo y se gasta en recompensas reales (vicios).

### Balance de Precios (Lógica de Mercado)
| Acción (Misión)           | Recompensa ($) | Vicio (Recompensa Real) | Coste ($) |
|--------------------------|---------------|-------------------------|-----------|
| Meditar 10 min           | +10           | Un cigarrillo           | 20        |
| Leer 20 páginas          | +20           | Una cerveza             | 70        |
| Entrenar (Gym)           | +50           | Salir de fiesta         | 1,000     |
| Completar proyecto LOG   | +200          | "Capricho mayor"        | 2,500     |

**Inflación de Vicio:** Si compras mucho de un vicio, su precio sube esa semana, obligando a a aumentar la productividad.

## 3. Tipos de Misiones
- **Daily Quests (Obligatorias):** Penalización si no se cumplen (pérdida de monedas o daño a HP).
- **Misiones de Rango (S, A, B, C):**
  - C: Limpiar la casa (+15 $)
  - S: Ayunar 24h o terminar un curso complejo (+500 $)
- **Misiones Ocultas:** Se activan por rachas. Ej: Leer 7 días seguidos desbloquea el título "Bibliotecario" (descuento en tabaco).

## 4. Interfaz y Estética
- **Dark Mode Permanente:** Estética neón, azul eléctrico y negro, inspirada en sistemas de Manhwa.
- **Avatar:** Modelo 3D o pixel-art que cambia según stats y consumo de vicios.

## 5. Factor "Realidad" (Drogas y Control)
- **Log de Consumo:** Tras comprar un vicio, la app pregunta por la productividad al día siguiente.
- **Bloqueo de Emergencia:** Si se gasta mucho en vicios, la tienda se bloquea y obliga a hacer misiones de ESP para "limpiar el sistema".

## 6. Stack Tecnológico Sugerido
- **Frontend:** Flutter o React Native (experiencia tipo juego, animaciones fluidas).
- **Backend:** Firebase (usuarios y misiones en tiempo real).
- **Gamificación:** Librería de motores de juego como Flame (Flutter) para efectos visuales.

## 7. Propuesta de Nombre
- System: Overdrive
- ViceLeveling
- Dopamine Dealer
- MyQuest

El usuario es un "Jugador" cuyo hardware es su cuerpo y su software es su mente.
Slogan -> El esfuerzo tiene precio. La recompensa también.

---

## 8. Misiones Secundarias (Extraídas de la "Sabiduría de Internet")

### Misiones de "Mundo Abierto" (Secundarias)
Se activan aleatoriamente o por ubicación:
- **"La Ducha de Odín" (VIT):** Terminar la ducha con 2 minutos de agua totalmente fría. (+20 Grit).
- **"El Orador Silencioso" (SOC):** Entablar una conversación de al menos 3 minutos con un desconocido (camarero, cajero, alguien en la fila). (+40 Grit).
- **"Minimalismo Digital" (ESP):** 4 horas consecutivas sin tocar el smartphone durante el día. (+50 Grit).
- **"Deep Work Protocol" (LOG):** 90 minutos de trabajo/estudio bloqueado sin una sola interrupción. (+60 Grit).

## 9. Eventos de Fin de Semana: "The Dungeons" (Mazmorras)

El fin de semana es cuando la mayoría de la gente pierde el progreso. Aquí es donde la app se vuelve más exigente.

| Evento              | Objetivo                                                        | Recompensa Especial                          |
|---------------------|----------------------------------------------------------------|---------------------------------------------|
| Monje de 48h       | 0 redes sociales y 0 comida procesada desde el viernes noche al domingo. | Título: "Inquebrantable" (Multiplicador x1.2 de Grit permanente). |
| Raid de Exploración | Caminar 15km o descubrir un lugar físico donde nunca hayas estado. | Desbloquea: "Permiso de Salida VIP" (Cena de lujo). |
| El Purificador      | Limpiar y organizar a fondo toda tu habitación/casa.            | Desbloquea: Buff "Claridad Mental" (+XP en Sapiencia). |

## 10. El Sistema de Recompensas (Compliance con App Store)

Para evitar bloqueos de Apple o Google, usaremos un sistema de "Categorías de Consumo". La app no menciona sustancias, sino "Niveles de Gratificación".

### El Mercado de la "Nueva Vida"
- **Nivel Bronce (Ocio Común):** Comida rápida, un episodio de serie, compra de skin en un juego.
- **Nivel Plata (Experiencias Sociales):** Cena en restaurante, entrada de cine, tarde de copas (etiquetado como "Evento Social").
- **Nivel Oro (Grandes Desembolsos):** Noche de fiesta completa, compra de ropa cara, un viaje de fin de semana.
- **Caja de "Placeres Propios":** Un slot vacío donde el usuario pone el nombre que quiera (aquí es donde él pone sus vicios específicos bajo su responsabilidad).

## 11. Penalizaciones y El "Filtro de Mentiras"

El sistema debe ser un "Game Master" severo.

- **La "Zona de Castigo":** Si el usuario falla la Daily Quest obligatoria, entra en Modo Supervivencia. Durante 12 horas no gana experiencia y el avatar pierde "Brillo".
- **Detección de Fraude (Anti-Cheating):** Si el usuario marca como "Completada" una misión de 1 hora en solo 5 minutos, el sistema lanza un mensaje: "¿Intentas engañar al Sistema o te estás engañando a ti mismo?".
- **La Maldición del Impostor:** Si se detectan mentiras recurrentes, se aplica un debuff que reduce todas las ganancias de Grit un 50% durante 3 días.
- **Penalización por Inactividad:** Si no abres la app en 24h, pierdes una pequeña cantidad de "Grit" (el "impuesto por pereza").

## 12. Blueprint Técnico: ¿Qué necesitas para montarla?

### El Stack Tecnológico (Nivel Pro)
- **Lenguaje de Frontend:** Dart (Framework: Flutter).
  - Por qué: Necesitas que la UI sea visualmente impactante (partículas, barras de vida, transiciones tipo anime). Flutter es el mejor para esto en móvil.
- **Backend:** Node.js con Express o NestJS.
  - Por qué: Necesitas gestionar la lógica de niveles y la base de datos de forma centralizada para que el usuario no pueda "hackear" sus monedas localmente.
- **Base de Datos:** PostgreSQL + Prisma (ORM).
  - Por qué: Para guardar el historial de misiones y la evolución de los 6 atributos.
- **Estado Global:** Riverpod o Bloc.
  - Por qué: Para que cuando ganes Grit, la barra de nivel se actualice en tiempo real con una animación fluida.

### Nivel de Conocimiento Necesario
- **Seniority:** Necesitas un nivel Intermedio-Avanzado.
- **Habilidades Clave:**
  - Manejo de Animaciones complejas en Flutter (CustomPainter o Rive).
  - Diseño de Sistemas de Gamificación (entender curvas de experiencia $XP = Nivel^{1.5}$).
  - Seguridad básica para evitar que el usuario manipule el reloj del teléfono para "ganar tiempo".

## 13. Resumen de Flujo de Usuario (La Experiencia Total)

1. **El Despertar:** El usuario entra, ve una interfaz oscura y minimalista. No hay niveles, solo una misión: "Sobrevivir al día" (beber agua, leer 5 min).
2. **El Registro:** Al cumplir misiones, el hexágono de atributos empieza a dibujarse.
3. **La Tentación:** El usuario quiere salir de fiesta. Abre la tienda y ve que cuesta 800 Grit. Mira su saldo: tiene 450.
4. **El Impulso:** Para conseguir los 350 que le faltan, decide aceptar una "Misión de Rango A": Correr 10km.
5. **La Recompensa:** Al terminar, el sistema suena con un tono metálico: "Felicidades. Has canjeado tu esfuerzo por gratificación. Disfruta con responsabilidad".
### **Pantallas clave** 
1-**Inicio:**
 - HP bar, Grit actual, nivel.
       - Hexágono de atributos (en el centro e interactivo).
       - Daily quests con tiempo/cuenta atrás (ñe, esto puede motivar o estresar).
      
2-**Misiones:**
       - Lista filtrable por atributo y rango.
       - Vista de misiones activas con countdown y botón de "completar misión" .
       - Historial de misiones completadas, filtrables por días, semanas, meses (de primeras una lista y luego mas adelante poder ver las estadísticas como cuando te metes           en la app de los pasos).
       
3-**Tienda de recompensas:**
       - Recompensas con su precio en GRIT.
       - Indicador de inflación: si abusas de una recompensa el precio sube.
       - Botón de canjear, con confirmación (así evitamos canjear una recompensa dándole por error).

4-**Perfil:**
       - Avatar con su estado actual.
       - Hexágono de stats completo con histórico.
       - Logros desbloqueados y rachas activas.

5-**Ajustes de la aplicación:**
       - Accesible desde el perfil.
       - Gestionar cuenta (nombre usuario, email, cambiar contraseña...).
       - Juego (dificultad normal/hard y se podría añadir algo mas pero no me da la cabeza ahora).
       - Notificaciones (activar/desactivar, hora del recordatorio diario, personalizar mensaje recordatorio).
       - Diseño (cambiar colores: azul eléctrico, violeta, cian, verde vibrante...).
       - Privacidad (resetear, política de privacidad).
       - Acerca de (versión de la app, créditos, contactos, valorar en la app store).
   
   IMPORTANTE -> Centrarse en la "fiesta" al completar una misión (sonido, animación, Grit creciendo, avatar cambiando...).
   
## 14. Evolución de Clase (Especialización)

En el anime, no todos son iguales. Al llegar al Nivel 20, el usuario no solo tiene stats, sino que debe elegir una "Senda" (Job Class) que cambia cómo gana Grit:

- **The Architect (LOG/SAP):** Gana un 15% más de Grit en tareas de enfoque profundo, pero las misiones de VIT le cuestan el doble de esfuerzo.
- **The Nomad (VIT/SOC):** Los eventos de "Mundo Abierto" dan recompensas triples.
- **The Mystic (ESP/CREA):** Sus periodos de "inflación de vicio" se resetean más rápido gracias a su control mental.

## 15. El Medidor de "Corrupción" (Feedback Visual)

No basta con perder HP. Necesitamos un indicador de toxicidad.

- **Mecánica:** Cada vez que compras un "vicio" de nivel Oro o usas un "Slot Propio", tu medidor de Corrupción sube.
- **Efecto visual:** El avatar empieza a mostrar grietas de energía oscura o "glitches" en la interfaz.
- **Consecuencia:** Si la Corrupción llega al 80%, entras en un "Estado de Bloqueo". Tus atributos dejan de subir aunque cumplas misiones. Solo se limpia con una misión de "Purificación" (ej: 3 días de ayuno de dopamina o 5 misiones seguidas de ESP).

## 16. Integración Biométrica (La Verdadera "Prueba de Trabajo")

Para evitar que el usuario mienta, la app debe conectarse a los sensores del hardware (HealthKit/Google Fit):

- **Validación de VIT:** Si la app no detecta un aumento en las pulsaciones o pasos a través del smartwatch, la misión de "Gym" no se completa.
- **Validación de Sueño:** Si usas el móvil a las 2:00 AM, el sistema detecta que rompiste la "Higiene de Sueño" y aplica una penalización automática de HP al despertar.
- **Deep Work Detector:** Uso de la API de tiempo en pantalla. Si abres Instagram durante una misión de "LOG", la misión se aborta automáticamente.

## 17. El "Shadow Market" Dinámico (Social)

Para que la economía no sea plana, añadimos un factor social global:

- **Inflación Global:** Si el 60% de los usuarios de la app están gastando en "Comida Chatarra" un viernes, el precio del Grit para esa recompensa sube para todos. Es una "resistencia colectiva".
- **Subastas de Objetos:** Una vez al mes, aparece un objeto único (ej: "La Capa de Invisibilidad": 24h donde los fallos de misiones no quitan HP). Solo se puede comprar con pujas de Grit masivas.

## 18. Sistema de "Logros de Legado"

Para evitar el abandono de la app tras un mes:

- **Reliquias:** Al completar un libro (SAP) o un proyecto (LOG), el usuario puede "crear una reliquia". Es un trofeo visual que se queda en su perfil permanentemente y otorga un micro-bono pasivo (ej: +1% de Grit en esa categoría).
- **El Salón de la Fama:** Un ranking basado no en dinero, sino en el "Índice de Dominio" (la media equilibrada de los 6 atributos).

## 19. Refinamiento del Modelo de Negocio (Sustentabilidad)

Para que puedas desarrollarla y mantenerla, el modelo no debe ser intrusivo:

- **Suscripción "Hunter Plus":** Acceso a misiones de Rango S exclusivas, temas visuales de otros animes y almacenamiento en la nube de tus reliquias.
- **Marketplace de Coaching:** Profesionales reales pueden crear "Packs de Misiones" (ej: un entrenador real crea un pack de 30 días de VIT) y los usuarios los compran con dinero real o cantidades ingentes de Grit.

## 20. Tabla de Fórmulas Finales para Desarrolladores

| Concepto               | Fórmula / Lógica                                                                 |
|------------------------|----------------------------------------------------------------------------------|
| Ganancia de XP         | $XP = Base\_Misión \times (1 + \frac{Racha\_Días}{10})$                          |
| Pérdida de HP por Fallo| $HP\_lost = 10 \times (\text{Nivel\_Misión}) / \text{Temple(VIT)}$               |
| Resistencia al Vicio   | A mayor nivel de ESP, menor es el impacto de la inflación de precios para ese usuario. |

---

## 21. 🛡️ Progresión de Niveles: Del "Civil" al "Vanguardia"

### Nivel 1: El Despertado (The Awakened)
- **Requisito:** Superar la "Prueba de la Puerta" (Día 7).
- **Evolución Visual:** El avatar deja de ser una silueta borrosa. Ahora es un modelo de pixel-art minimalista con ropa básica de entrenamiento negra.
- **Efecto de Interfaz:** El HUD deja de parpadear en rojo y se estabiliza en un azul eléctrico constante.
- **Desbloqueo:** Acceso al Shadow Market (Categoría Bronce).

### Nivel 2: El Iniciado (The Initiate)
- **Requisito:** Alcanzar 500 XP totales.
- **Evolución Visual:** El avatar recibe sus primeros "Aumentos". Si tu stat más alta es VIT, se le ven vendas en las manos; si es SAP, aparece un aura sutil de datos alrededor de la cabeza.
- **Efecto de Interfaz:** Sonidos de menú más limpios y metálicos.
- **Desbloqueo:** Misiones Secundarias de Mundo Abierto (aparecen retos aleatorios por GPS o tiempo).

### Nivel 3: El Aspirante (The Contender)
- **Requisito:** 1,200 XP + Haber completado al menos 3 misiones de Rango B.
- **Evolución Visual:** El avatar equipa una "Coraza de Fibra de Carbono". Los ojos del avatar empiezan a brillar levemente con el color de su atributo dominante (ej. Verde para ESP, Rojo para VIT, Azul para LOG).
- **Efecto de Interfaz:** Desbloqueo del "Modo Enfoque" (un temporizador dentro de la app que, si lo cumples, duplica la XP de esa sesión).
- **Desbloqueo:** Acceso a recompensas de Nivel Plata en la tienda.

### Nivel 4: El Especialista (The Specialist)
- **Requisito:** 2,500 XP + Un atributo por encima del nivel 10.
- **Evolución Visual:** Aparece el primer Objeto de Clase.
  - **INTELECTO:** Un monóculo de datos o un libro flotante.
  - **VITALIDAD:** Un aura de vapor (efecto "Gear Second").
  - **SOCIAL:** Una capa de prestigio que ondea.
- **Desbloqueo:** Misiones de Racha (Streaks). Si mantienes una racha de 5 días, el Grit ganado se multiplica por $1.5$.

### Nivel 5: La Vanguardia (The Vanguard)
- **Requisito:** 5,000 XP + Superar la primera "Mazmorra de Fin de Semana" de Rango A.
- **Evolución Visual:** Transformación Completa. El avatar ya no parece humano común; tiene una armadura ligera de "Cazador del Sistema". Aparece un título flotante sobre su cabeza visible para otros usuarios (si activas el modo social).
- **Desbloqueo:** El Slot de Vicio Maestro. El usuario puede definir una recompensa "Épica" (ej. Un viaje o una compra grande) y el sistema le permite crear un plan de ahorro de Grit a largo plazo.

## 22. 📊 Tabla de Recompensas por Atributo (Visuales)

Para que el usuario sienta que su esfuerzo "se ve", el avatar debe reflejar sus decisiones:

| Atributo Dominante | Nivel 5 (Efecto Visual)                  | Buff Pasivo Desbloqueado                                      |
|--------------------|------------------------------------------|-------------------------------------------------------------|
| Sapiencia (SAP)    | Aura de glifos antiguos flotantes.       | Lectura Veloz (XP x1.1 en misiones SAP).                    |
| Lógica (LOG)       | Circuitos integrados brillando en la piel.| Cálculo de Grit (Descuento del 5% en vicios).               |
| Vitalidad (VIT)    | Rayos eléctricos recorriendo los músculos.| Recuperación (El HP se regenera un 20% más rápido).         |
| Espiritualidad (ESP)| El avatar levita ligeramente en el menú. | Calma Mental (Inmunidad a la Inflación de Vicio una vez al mes). |

## 23. 🛠️ Próximos pasos para el Desarrollo

Si esto fuera un proyecto real que vamos a programar ahora mismo, necesitarías:

- **Diseño de Assets:** Crear los 5 estados del avatar (puedes usar herramientas de IA generativa de sprites o contratar a un artista de pixel-art).
- **Motor de Lógica:** Programar en el Backend la función que calcula el nivel basada en la XP acumulada:
  $$Nivel = \sqrt{\frac{XP}{100}}$$ (o una curva similar más ajustada).
- **Sistema de Notificaciones "Persona":** Configurar las notificaciones para que no digan "Tienes una tarea pendiente", sino "[SISTEMA]: Se ha detectado una anomalía en tu productividad. Actúa de inmediato o perderás HP".
