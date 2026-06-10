/// Tipos de misión
enum MissionRank { C, B, A, S }
enum MissionType { daily, secondary, dungeon }
enum MissionStatus { pending, completed, failed }

/// Modelo de datos de Misión (MVP mock)
class MissionModel {
  final String id;
  final String title;
  final String description;
  final MissionRank rank;
  final MissionType type;
  final bool isDaily;
  final DateTime? dueDate;
  final int gritReward;
  final int xpReward;
  final String attribute; // INT, LOG, CREA, ESP, VIT, SOC
  final int minDurationMin;
  MissionStatus status;

  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rank,
    required this.type,
    this.isDaily = true,
    this.dueDate,
    required this.gritReward,
    required this.xpReward,
    required this.attribute,
    this.minDurationMin = 0,
    this.status = MissionStatus.pending,
  });

  /// Alias de gritReward para usar en la UI con el nuevo nombre "AURA"
  int get auraReward => gritReward;

  MissionModel copyWith({
    String? id,
    String? title,
    String? description,
    MissionRank? rank,
    MissionType? type,
    bool? isDaily,
    Object? dueDate = _noDueDate,
    int? gritReward,
    int? xpReward,
    String? attribute,
    int? minDurationMin,
    MissionStatus? status,
  }) {
    return MissionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rank: rank ?? this.rank,
      type: type ?? this.type,
      isDaily: isDaily ?? this.isDaily,
      dueDate: identical(dueDate, _noDueDate) ? this.dueDate : dueDate as DateTime?,
      gritReward: gritReward ?? this.gritReward,
      xpReward: xpReward ?? this.xpReward,
      attribute: attribute ?? this.attribute,
      minDurationMin: minDurationMin ?? this.minDurationMin,
      status: status ?? this.status,
    );
  }

  /// Lista mock de misiones del tablero: diarias, urgentes y de largo plazo.
  static List<MissionModel> mockDailyQuests() {
    final now = DateTime.now();
    DateTime dayOffset(int offset) => DateTime(now.year, now.month, now.day + offset);

    return [
    // ── VIT: Vitalidad ──────────────────────────────────────
    MissionModel(
      id: 'vit-001',
      title: 'Entrenamiento de fuerza 30m',
      description: 'Activa el sistema motor. Forja el hardware corporal.',
      rank: MissionRank.B,
      type: MissionType.daily,
      gritReward: 50,
      xpReward: 60,
      attribute: 'VIT',
      minDurationMin: 30,
    ),
    MissionModel(
      id: 'vit-002',
      title: 'Correr 5 km',
      description: 'Empuja los límites del sistema cardiovascular.',
      rank: MissionRank.B,
      type: MissionType.daily,
      gritReward: 45,
      xpReward: 55,
      attribute: 'VIT',
      minDurationMin: 25,
    ),
    // ── INT: Intelecto ──────────────────────────────────────
    MissionModel(
      id: 'int-001',
      title: 'Leer 20 páginas',
      description: 'Carga tu cortex prefrontal. El conocimiento es poder.',
      rank: MissionRank.C,
      type: MissionType.daily,
      gritReward: 20,
      xpReward: 25,
      attribute: 'INT',
      minDurationMin: 15,
    ),
    MissionModel(
      id: 'int-002',
      title: 'Estudiar idioma 20m',
      description: 'Expande tu arquitectura lingüística.',
      rank: MissionRank.C,
      type: MissionType.daily,
      gritReward: 20,
      xpReward: 25,
      attribute: 'INT',
      minDurationMin: 20,
    ),
    // ── LOG: Lógica ─────────────────────────────────────────
    MissionModel(
      id: 'log-001',
      title: 'Resolver reto de código',
      description: 'Ejecuta un algoritmo que haga sufrir a tu CPU mental.',
      rank: MissionRank.A,
      type: MissionType.daily,
      gritReward: 60,
      xpReward: 80,
      attribute: 'LOG',
      minDurationMin: 30,
    ),
    MissionModel(
      id: 'log-002',
      title: 'Jugar 1 partida de ajedrez',
      description: 'Planifica 10 movimientos por delante. Vence al sistema.',
      rank: MissionRank.C,
      type: MissionType.daily,
      gritReward: 15,
      xpReward: 20,
      attribute: 'LOG',
      minDurationMin: 20,
    ),
    // ── ESP: Espiritualidad ─────────────────────────────────
    MissionModel(
      id: 'esp-001',
      title: 'Meditar 10 minutos',
      description: 'Cierra los ojos. Vacía el ruido del sistema.',
      rank: MissionRank.C,
      type: MissionType.daily,
      gritReward: 10,
      xpReward: 15,
      attribute: 'ESP',
      minDurationMin: 10,
    ),
    MissionModel(
      id: 'esp-002',
      title: 'Escribir diario de gratitud',
      description: 'Registra 3 victorias del día. Todo log importa.',
      rank: MissionRank.C,
      type: MissionType.daily,
      gritReward: 10,
      xpReward: 15,
      attribute: 'ESP',
      minDurationMin: 5,
    ),
    // ── CREA: Creatividad ───────────────────────────────────
    MissionModel(
      id: 'crea-001',
      title: 'Practicar instrumento 20m',
      description: 'Sincroniza neuronas motoras y creativas.',
      rank: MissionRank.C,
      type: MissionType.daily,
      gritReward: 20,
      xpReward: 25,
      attribute: 'CREA',
      minDurationMin: 20,
    ),
    MissionModel(
      id: 'crea-002',
      title: 'Dibujar un boceto',
      description: 'Traduce la mente en trazos. Arte como protocolo.',
      rank: MissionRank.C,
      type: MissionType.daily,
      gritReward: 15,
      xpReward: 20,
      attribute: 'CREA',
      minDurationMin: 15,
    ),
    // ── SOC: Social ─────────────────────────────────────────
    MissionModel(
      id: 'soc-001',
      title: 'Llamar a un familiar o amigo',
      description: 'Refuerza los vínculos de tu red social real.',
      rank: MissionRank.C,
      type: MissionType.daily,
      gritReward: 15,
      xpReward: 20,
      attribute: 'SOC',
      minDurationMin: 10,
    ),
    MissionModel(
      id: 'soc-002',
      title: 'Asistir a evento social',
      description: 'Sal del modo solo. Amplía el mapa de conexiones.',
      rank: MissionRank.B,
      type: MissionType.daily,
      gritReward: 40,
      xpReward: 50,
      attribute: 'SOC',
      minDurationMin: 60,
    ),
    // ── Urgentes no diarias (se muestran como DAILY por vencimiento) ──
    MissionModel(
      id: 'log-003',
      title: 'Limpiar habitación y escritorio',
      description: 'Restaura el orden del nodo base antes del siguiente ciclo.',
      rank: MissionRank.C,
      type: MissionType.secondary,
      isDaily: false,
      dueDate: dayOffset(1),
      gritReward: 40,
      xpReward: 24,
      attribute: 'LOG',
      minDurationMin: 25,
    ),
    // ── Long-term quests ────────────────────────────────────
    MissionModel(
      id: 'int-003',
      title: 'Completar módulo maestro de Flutter',
      description: 'Desbloquea una nueva capa de arquitectura y precisión técnica.',
      rank: MissionRank.A,
      type: MissionType.secondary,
      isDaily: false,
      dueDate: dayOffset(5),
      gritReward: 95,
      xpReward: 120,
      attribute: 'INT',
      minDurationMin: 90,
    ),
    MissionModel(
      id: 'esp-003',
      title: '7 días sin redes nocturnas',
      description: 'Protege el foco y reduce la corrupción del descanso profundo.',
      rank: MissionRank.B,
      type: MissionType.dungeon,
      isDaily: false,
      dueDate: dayOffset(8),
      gritReward: 80,
      xpReward: 90,
      attribute: 'ESP',
      minDurationMin: 15,
    ),
    MissionModel(
      id: 'crea-003',
      title: 'Montar portfolio visual',
      description: 'Compila tus mejores piezas en una reliquia creativa exportable.',
      rank: MissionRank.A,
      type: MissionType.dungeon,
      isDaily: false,
      dueDate: dayOffset(12),
      gritReward: 110,
      xpReward: 140,
      attribute: 'CREA',
      minDurationMin: 120,
    ),
  ];
  }
}

const Object _noDueDate = Object();

