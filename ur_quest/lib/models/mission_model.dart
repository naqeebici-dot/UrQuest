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
    required this.gritReward,
    required this.xpReward,
    required this.attribute,
    this.minDurationMin = 0,
    this.status = MissionStatus.pending,
  });

  /// Lista mock de Daily Quests
  static List<MissionModel> mockDailyQuests() => [
    MissionModel(
      id: 'm-001',
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
      id: 'm-002',
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
      id: 'm-003',
      title: 'Entrenar en el gym',
      description: 'Activa el sistema motor. Forja el hardware.',
      rank: MissionRank.B,
      type: MissionType.daily,
      gritReward: 50,
      xpReward: 60,
      attribute: 'VIT',
      minDurationMin: 45,
    ),
    MissionModel(
      id: 'm-004',
      title: 'Deep Work 90 min',
      description: 'Bloquea el mundo exterior. Maximiza el output cognitivo.',
      rank: MissionRank.A,
      type: MissionType.daily,
      gritReward: 60,
      xpReward: 80,
      attribute: 'LOG',
      minDurationMin: 90,
    ),
  ];
}

