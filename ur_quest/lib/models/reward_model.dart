/// Tiers de recompensa del Mercado UrQuest
enum RewardTier { BRONZE, SILVER, GOLD }

/// Modelo de Recompensa (Vicio/Recompensa del Mercado)
class RewardModel {
  final String id;
  final String title;
  final String description;
  final RewardTier tier;
  final int baseCost;
  final int currentCost;
  final int weeklyPurchases;
  final String emoji;
  final bool isPurchased;

  const RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tier,
    required this.baseCost,
    required this.currentCost,
    required this.weeklyPurchases,
    required this.emoji,
    this.isPurchased = false,
  });

  /// Porcentaje de inflación respecto al precio base
  int get inflationPercent {
    if (baseCost <= 0 || weeklyPurchases == 0) return 0;
    return (((currentCost - baseCost) / baseCost) * 100).round();
  }

  RewardModel copyWith({bool? isPurchased}) => RewardModel(
    id: id, title: title, description: description,
    tier: tier, baseCost: baseCost, currentCost: currentCost,
    weeklyPurchases: weeklyPurchases, emoji: emoji,
    isPurchased: isPurchased ?? this.isPurchased,
  );

  /// Lista mock de 9 recompensas — 3 por tier (descripciones estilo RPG/sci-fi)
  static List<RewardModel> mockRewards() => [
    // ── BRONZE ──────────────────────────────────────────────
    const RewardModel(
      id: 'rew-001',
      title: 'Cerveza Premium',
      description: 'Brebaje sedante de baja graduación. Ralentiza los procesos cognitivos pero restaura la fatiga mental a corto plazo.',
      tier: RewardTier.BRONZE,
      baseCost: 50,
      currentCost: 50,
      weeklyPurchases: 0,
      emoji: '🍺',
    ),
    const RewardModel(
      id: 'rew-002',
      title: 'Cheat Meal',
      description: 'Recarga calórica de alto índice glucémico. Activa circuitos de placer y anula temporalmente el protocolo nutricional.',
      tier: RewardTier.BRONZE,
      baseCost: 60,
      currentCost: 72,
      weeklyPurchases: 2,
      emoji: '🍕',
    ),
    const RewardModel(
      id: 'rew-003',
      title: 'Siesta 30 min',
      description: 'Ciclo de reparación breve. Recompone los condensadores neuronales sin entrar en sueño profundo.',
      tier: RewardTier.BRONZE,
      baseCost: 30,
      currentCost: 30,
      weeklyPurchases: 0,
      emoji: '😴',
    ),
    // ── SILVER ──────────────────────────────────────────────
    const RewardModel(
      id: 'rew-004',
      title: 'Netflix Night',
      description: 'Cápsula audiovisual narrativa. Suspende el flujo temporal y libera dopamina pasiva durante 120 minutos.',
      tier: RewardTier.SILVER,
      baseCost: 100,
      currentCost: 120,
      weeklyPurchases: 1,
      emoji: '🎬',
    ),
    const RewardModel(
      id: 'rew-005',
      title: 'Salida de Fiesta',
      description: 'Inmersión en nodo social caótico. Alto consumo energético. Reservas de SOC restauradas si la misión culmina con éxito.',
      tier: RewardTier.SILVER,
      baseCost: 120,
      currentCost: 120,
      weeklyPurchases: 0,
      emoji: '🎉',
    ),
    const RewardModel(
      id: 'rew-006',
      title: 'Día sin alarma',
      description: 'Suspensión del protocolo de activación matutina. El sistema biológico define su propio ciclo de reinicio.',
      tier: RewardTier.SILVER,
      baseCost: 90,
      currentCost: 108,
      weeklyPurchases: 1,
      emoji: '⏰',
    ),
    // ── GOLD ────────────────────────────────────────────────
    const RewardModel(
      id: 'rew-007',
      title: 'Fin de semana Libre',
      description: 'Desconexión total de la matriz. 48 horas sin misiones activas. Restauración completa de energía vital.',
      tier: RewardTier.GOLD,
      baseCost: 300,
      currentCost: 300,
      weeklyPurchases: 0,
      emoji: '👑',
    ),
    const RewardModel(
      id: 'rew-008',
      title: 'Viaje Espontáneo',
      description: 'Ruptura del patrón geográfico habitual. Exploración de nodos físicos desconocidos. Alto potencial de eventos aleatorios.',
      tier: RewardTier.GOLD,
      baseCost: 500,
      currentCost: 600,
      weeklyPurchases: 1,
      emoji: '✈️',
    ),
    const RewardModel(
      id: 'rew-009',
      title: 'Capricho Extremo',
      description: 'Adquisición material no esencial. Riesgo elevado de corrupción del bucle motivacional. Activar bajo supervisión del Sistema.',
      tier: RewardTier.GOLD,
      baseCost: 400,
      currentCost: 400,
      weeklyPurchases: 0,
      emoji: '💀',
    ),
  ];
}

