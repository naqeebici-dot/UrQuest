import '../models/reward_model.dart';

/// Modo de entrada para el parser
/// `mission` = misiones / hábitos
/// `reward`  = recompensas / corrupción
enum EntryMode { mission, reward }

/// Resultado del análisis de texto UGC
class EvaluationResult {
  final int? suggestedReward;
  final int? suggestedCost;
  final String? detectedAttribute;
  final RewardTier? detectedTier;
  final List<String> matchedKeywords;
  final String? suggestedEmoji;

  const EvaluationResult({
    this.suggestedReward,
    this.suggestedCost,
    this.detectedAttribute,
    this.detectedTier,
    this.matchedKeywords = const [],
    this.suggestedEmoji,
  });

  static const empty = EvaluationResult();
}

class _MissionBucket {
  final List<String> keywords;
  final int baseAura;
  final String attribute;
  final String emoji;
  const _MissionBucket(this.keywords, this.baseAura, this.attribute, this.emoji);
}

class _RewardBucket {
  final List<String> keywords;
  final int baseCost;
  final RewardTier tier;
  final String emoji;
  const _RewardBucket(this.keywords, this.baseCost, this.tier, this.emoji);
}

class _AvoidanceRule {
  final RegExp pattern;
  final String label;
  const _AvoidanceRule(this.pattern, this.label);
}

/// Servicio principal del sistema de parseo.
/// Mantiene compatibilidad con `RegexDictionaryService` más abajo.
class SystemParserService {
  SystemParserService._();

  static const _criticalPartyRewardKeywords = <String>[
    'fiesta', 'discoteca', 'techno', 'rave', 'festival', 'borrachera',
    'resaca', 'drogas', 'mdma', 'casino', 'apostar'
  ];

  static const _excessFoodRewardKeywords = <String>[
    'cheat meal', 'pizza', 'hamburguesa', 'burger', 'mcdonalds',
    'burger king', 'kebab', 'comida basura', 'atracon'
  ];

  static const _excessGamingRewardKeywords = <String>[
    'videojuegos', 'lol', 'valorant', 'play', 'fifa'
  ];

  static const _moderateDrinkRewardKeywords = <String>[
    'cerveza', 'cervezas', 'copa', 'copas'
  ];

  static const _moderateWeedRewardKeywords = <String>[
    'canuto', 'canutos', 'porro', 'porros', 'weed', 'marihuana'
  ];

  static const _moderateSweetRewardKeywords = <String>[
    'dulce', 'azucar', 'helado', 'chocolate', 'cafe'
  ];

  static const _lightTobaccoRewardKeywords = <String>[
    'fumar', 'cigarro', 'cigarros', 'tabaco', 'vapear', 'vape'
  ];

  static const _lightScreenRewardKeywords = <String>[
    'netflix', 'serie', 'pelicula', 'tiktok', 'instagram', 'redes',
    'youtube', 'siesta', 'procrastinar'
  ];

  static final _avoidanceRules = <_AvoidanceRule>[
    _AvoidanceRule(RegExp(r'\bno\s+fumar\b'), 'no fumar'),
    _AvoidanceRule(RegExp(r'\bno\s+beber\b'), 'no beber'),
    _AvoidanceRule(RegExp(r'\bno\s+azucar\b'), 'no azucar'),
    _AvoidanceRule(RegExp(r'\bno\s+comida\s+basura\b'), 'no comida basura'),
    _AvoidanceRule(RegExp(r'\bno\s+trasnochar\b'), 'no trasnochar'),
    _AvoidanceRule(RegExp(r'\bno\s+redes\b'), 'no redes'),
  ];

  // ── Diccionario EXPANDIDO de misiones (Tarea 2) ─────────────────
  static const _missionBuckets = <_MissionBucket>[
    // VIT (+60 AURA) 💪
    _MissionBucket(
      ['correr', 'gym', 'pesas', 'fuerza', 'crossfit', 'flexiones', 'andar',
       'deporte', 'nadar', 'bici', 'entrenar', 'saltar', 'burpees', 'dominadas',
       'sentadillas', 'cardio', 'hiit', 'estirar'],
      60,
      'VIT',
      '💪',
    ),
    // INT (+50 AURA) 📚
    _MissionBucket(
      ['leer', 'estudiar', 'curso', 'idioma', 'ingles', 'libro', 'podcast',
       'documental', 'investigar', 'ensayo', 'resumen',
       'aprender una habilidad', 'habilidad nueva', 'nueva habilidad',
       'aprender skill', 'skill nueva'],
      50,
      'INT',
      '📚',
    ),
    // LOG (+60 AURA) 🧠
    _MissionBucket(
      ['programar', 'codigo', 'leetcode', 'ajedrez', 'matematicas', 'finanzas',
       'invertir', 'puzzle', 'algoritmo', 'sudoku', 'backend', 'frontend'],
      60,
      'LOG',
      '🧠',
    ),
    // ESP (+40 AURA) 🧘
    _MissionBucket(
      ['meditar', 'respirar', 'diario', 'agradecer', 'yoga', 'terapia',
       'journaling', 'naturaleza', 'mindfulness', 'rezar', 'estoicismo'],
      40,
      'ESP',
      '🧘',
    ),
    // LOG / ESP (+40 AURA) 🧹
    _MissionBucket(
      ['limpiar', 'ordenar', 'fregar', 'habitacion', 'casa', 'balcon', 'lavar'],
      40,
      'LOG',
      '🧹',
    ),
    _MissionBucket(
      ['madrugar', 'despertar'],
      40,
      'ESP',
      '🧹',
    ),
    // CREA (+45 AURA) 🎨
    _MissionBucket(
      ['dibujar', 'escribir', 'pintar', 'musica', 'guitarra', 'disenar',
       'diseñar', 'editar', 'video', 'foto', 'arte', 'cantar', 'piano'],
      45,
      'CREA',
      '🎨',
    ),
    // SOC (+30 AURA) 🤝
    _MissionBucket(
      ['amigo', 'amigos', 'llamar', 'familia', 'conocer', 'hablar', 'cita',
       'networking', 'evento', 'salir', 'socializar', 'club'],
      30,
      'SOC',
      '🤝',
    ),
  ];

  // ── Tabla estricta de economía del mercado ──────────────────────
  // Leve = 50 AURA, Moderado = 150 AURA, Exceso = 300 AURA, Crítico = 800 AURA
  static const _rewardBuckets = <_RewardBucket>[
    // Tier crítico / fiesta
    _RewardBucket(
      _criticalPartyRewardKeywords,
      800,
      RewardTier.GOLD,
      '🪩',
    ),
    // Tier exceso / cheat meal
    _RewardBucket(
      [..._excessFoodRewardKeywords, ..._excessGamingRewardKeywords],
      300,
      RewardTier.SILVER,
      '🍔',
    ),
    // Tier moderado
    _RewardBucket(
      [
        ..._moderateDrinkRewardKeywords,
        ..._moderateWeedRewardKeywords,
        ..._moderateSweetRewardKeywords,
      ],
      150,
      RewardTier.BRONZE,
      '🍺',
    ),
    // Tier leve
    _RewardBucket(
      [
        ..._lightScreenRewardKeywords,
        ..._lightTobaccoRewardKeywords,
      ],
      50,
      RewardTier.BRONZE,
      '📱',
    ),
  ];

  // Regex para detectar números en misiones (Tarea 4)
  static final _missionNumberRegex = RegExp(
    r'(\d+)\s*(km|paginas|pagina|min|minutos|horas|reps|flexiones|dominadas|sentadillas|burpees|dias|dia)',
    caseSensitive: false,
  );

  // Regex para detectar números en recompensas (Tarea 4)
  // Nota: El orden importa - plurales antes de singulares para match correcto
  static final _rewardNumberRegex = RegExp(
    r'(\d+)\s*(cervezas|cerveza|copas|copa|cigarros|cigarro|canutos|canuto|porros|porro|vapes|vape|horas|partidas|pizzas|trozos|cafes|cafe)',
    caseSensitive: false,
  );

  static String _stripDiacritics(String input) {
    const map = {
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
      'ü': 'u', 'ñ': 'n', 'Á': 'A', 'É': 'E', 'Í': 'I',
      'Ó': 'O', 'Ú': 'U', 'Ü': 'U', 'Ñ': 'N',
    };
    return input.split('').map((c) => map[c] ?? c).join();
  }

  static bool _containsAny(String normalized, List<String> keywords) {
    for (final keyword in keywords) {
      if (_containsKeyword(normalized, keyword)) return true;
    }
    return false;
  }

  static bool _containsKeyword(String normalized, String keyword) {
    final k = _stripDiacritics(keyword.toLowerCase());
    final rx = RegExp(
      '(^|[^a-z0-9])${RegExp.escape(k)}([^a-z0-9]|\$)',
      caseSensitive: false,
    );
    return rx.hasMatch(normalized);
  }

  static EvaluationResult evaluate(String text, {required EntryMode mode}) {
    if (text.trim().isEmpty) return EvaluationResult.empty;
    final normalized = _stripDiacritics(text.toLowerCase());
    final matchedKeywords = <String>[];

    return switch (mode) {
      EntryMode.mission => _evaluateMission(normalized, matchedKeywords),
      EntryMode.reward  => _evaluateReward(normalized, matchedKeywords),
    };
  }

  static EvaluationResult _evaluateMission(String normalized, List<String> matchedKeywords) {
    int baseAura = 0;
    String? detectedAttribute;
    String? detectedEmoji;

    for (final rule in _avoidanceRules) {
      if (rule.pattern.hasMatch(normalized)) {
        matchedKeywords.add(rule.label);
        if (80 > baseAura) {
          baseAura = 80;
          detectedAttribute = 'ESP';
          detectedEmoji = '🛡️';
        }
      }
    }

    for (final bucket in _missionBuckets) {
      for (final keyword in bucket.keywords) {
        if (_containsKeyword(normalized, keyword)) {
          matchedKeywords.add(keyword);
          if (bucket.baseAura > baseAura) {
            baseAura = bucket.baseAura;
            detectedAttribute = bucket.attribute;
            detectedEmoji = bucket.emoji;
          }
        }
      }
    }

    // Tarea 4: Lógica de multiplicador para misiones
    // AURA Total = Base + (N * 1.5)
    double numericBonus = 0;
    for (final match in _missionNumberRegex.allMatches(normalized)) {
      final number = int.tryParse(match.group(1) ?? '') ?? 0;
      if (number > 0) {
        numericBonus += number * 1.5;
        matchedKeywords.add('${match.group(1)} ${match.group(2)}');
      }
    }

    if (baseAura == 0 && numericBonus == 0) return EvaluationResult.empty;

    // Si solo hay magnitud, damos una base mínima útil.
    if (baseAura == 0 && numericBonus > 0) {
      baseAura = 20;
      detectedAttribute = detectedAttribute ?? 'INT';
    }

    return EvaluationResult(
      suggestedReward: (baseAura + numericBonus).round(),
      detectedAttribute: detectedAttribute,
      matchedKeywords: matchedKeywords.toSet().toList(),
      suggestedEmoji: detectedEmoji,
    );
  }

  static EvaluationResult _evaluateReward(String normalized, List<String> matchedKeywords) {
    _RewardBucket? detected;

    for (final bucket in _rewardBuckets) {
      for (final keyword in bucket.keywords) {
        if (_containsKeyword(normalized, keyword)) {
          matchedKeywords.add(keyword);
          // Prioriza por coste más alto (tier más dañino)
          if (detected == null || bucket.baseCost > detected.baseCost) {
            detected = bucket;
          }
        }
      }
    }

    if (detected == null) return EvaluationResult.empty;

    double totalCost = detected.baseCost.toDouble();

    // Tarea 4: Lógica de multiplicador para vicios
    // AURA Total = Base * (1 + (N * 0.2))
    int maxDetectedNumber = 0;
    for (final match in _rewardNumberRegex.allMatches(normalized)) {
      final number = int.tryParse(match.group(1) ?? '') ?? 0;
      if (number > maxDetectedNumber) maxDetectedNumber = number;
      matchedKeywords.add('${match.group(1)} ${match.group(2)}');
    }
    if (maxDetectedNumber > 0) {
      totalCost = detected.baseCost * (1 + (maxDetectedNumber * 0.2));
    }

    // Mapeo exacto por categoría para evitar coronas o emojis incorrectos.
    String emoji = detected.emoji;

    if (_containsAny(normalized, _criticalPartyRewardKeywords)) {
      emoji = _containsAny(normalized, ['drogas', 'mdma']) ? '☢️' : '🪩';
    } else if (_containsAny(normalized, _excessFoodRewardKeywords)) {
      emoji = '🍔';
    } else if (_containsAny(normalized, _excessGamingRewardKeywords)) {
      emoji = '🎮';
    } else if (_containsAny(normalized, _moderateDrinkRewardKeywords)) {
      emoji = '🍺';
    } else if (_containsAny(normalized, _moderateWeedRewardKeywords)) {
      emoji = '🍺';
    } else if (_containsAny(normalized, _moderateSweetRewardKeywords)) {
      emoji = '🍦';
    } else if (_containsAny(normalized, _lightTobaccoRewardKeywords)) {
      emoji = '🚬';
    } else if (_containsAny(normalized, _lightScreenRewardKeywords)) {
      emoji = '📱';
    }

    return EvaluationResult(
      suggestedCost: totalCost.round(),
      detectedTier: detected.tier,
      matchedKeywords: matchedKeywords.toSet().toList(),
      suggestedEmoji: emoji,
    );
  }
}

/// Compatibilidad con el nombre anterior usado en varios archivos.
class RegexDictionaryService {
  RegexDictionaryService._();

  static EvaluationResult evaluate(String text, {required EntryMode mode}) =>
      SystemParserService.evaluate(text, mode: mode);
}
