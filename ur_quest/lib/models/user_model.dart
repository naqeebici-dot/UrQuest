/// Modelo de datos del Usuario (MVP mock)
class UserModel {
  final String id;
  final String username;
  final int level;
  final int hp;
  final int maxHp;
  final int gritBalance;
  final int xpTotal;
  final int corruptionScore;
  final int currentStreak;
  final Map<String, int> attributes; // INT, LOG, CREA, ESP, VIT, SOC → 0-100

  const UserModel({
    required this.id,
    required this.username,
    required this.level,
    required this.hp,
    required this.maxHp,
    required this.gritBalance,
    required this.xpTotal,
    required this.corruptionScore,
    required this.currentStreak,
    required this.attributes,
  });

  double get hpPercent => maxHp > 0 ? hp / maxHp : 0.0;
  int get xpToNextLevel {
    final next = (level + 1) * (level + 1) * 100;
    return next - xpTotal;
  }

  /// Usuario mock para desarrollo
  static UserModel mock() => const UserModel(
    id:             'mock-001',
    username:       'TestHunter',
    level:          7,
    hp:             80,
    maxHp:          100,
    gritBalance:    450,
    xpTotal:        4900,
    corruptionScore:15,
    currentStreak:  3,
    attributes: {
      'INT':  72,
      'LOG':  55,
      'CREA': 40,
      'ESP':  30,
      'VIT':  65,
      'SOC':  48,
    },
  );
}

