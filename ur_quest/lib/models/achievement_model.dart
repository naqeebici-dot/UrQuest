import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AchievementRarity { bronze, silver, gold }
enum HunterTitleState { unlocked, equipped, locked, lapsed }
enum CorruptionSeverity { warning, severe, critical }

class AchievementBadgeModel {
  final String id;
  final String name;
  final IconData icon;
  final AchievementRarity rarity;
  final bool unlocked;
  final DateTime? unlockedAt;
  final String lore;

  const AchievementBadgeModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.rarity,
    required this.unlocked,
    required this.lore,
    this.unlockedAt,
  });
}

class HunterTitleModel {
  final String id;
  final String title;
  final String requirement;
  final String lore;
  final Color accent;
  final HunterTitleState state;

  const HunterTitleModel({
    required this.id,
    required this.title,
    required this.requirement,
    required this.lore,
    required this.accent,
    required this.state,
  });
}

class CorruptionMarkModel {
  final String id;
  final String name;
  final String trigger;
  final String effect;
  final CorruptionSeverity severity;
  final bool unlocked;

  const CorruptionMarkModel({
    required this.id,
    required this.name,
    required this.trigger,
    required this.effect,
    required this.severity,
    required this.unlocked,
  });
}

class HunterCodexMock {
  HunterCodexMock._();

  static List<AchievementBadgeModel> get achievements => [
        AchievementBadgeModel(
          id: 'ach-001',
          name: 'Pulmones de Acero',
          icon: Icons.air,
          rarity: AchievementRarity.silver,
          unlocked: true,
          unlockedAt: DateTime(2026, 5, 12),
          lore:
              'Resististe la llamada de la nicotina durante ciclos consecutivos. El sistema registró una mejora anómala en la pureza del aire interno.',
        ),
        AchievementBadgeModel(
          id: 'ach-002',
          name: 'Forjador del Alba',
          icon: Icons.wb_sunny_outlined,
          rarity: AchievementRarity.gold,
          unlocked: true,
          unlockedAt: DateTime(2026, 5, 20),
          lore:
              'Despertaste antes del caos y reclamaste las primeras horas del día como territorio del cazador.',
        ),
        AchievementBadgeModel(
          id: 'ach-003',
          name: 'Archivista Mental',
          icon: Icons.auto_stories_outlined,
          rarity: AchievementRarity.bronze,
          unlocked: true,
          unlockedAt: DateTime(2026, 4, 30),
          lore:
              'Cada lectura dejó una marca. Tus bancos de memoria ya no se sienten improvisados.',
        ),
        AchievementBadgeModel(
          id: 'ach-004',
          name: 'Nodo Impecable',
          icon: Icons.cleaning_services_outlined,
          rarity: AchievementRarity.silver,
          unlocked: false,
          lore:
              'Mantén tu base de operaciones en orden absoluto durante siete ciclos para revelar este sello.',
        ),
        AchievementBadgeModel(
          id: 'ach-005',
          name: 'Corazón de Party',
          icon: Icons.groups_2_outlined,
          rarity: AchievementRarity.bronze,
          unlocked: false,
          lore:
              'Solo quienes dominan la diplomacia social sin perder el foco reciben esta distinción.',
        ),
        AchievementBadgeModel(
          id: 'ach-006',
          name: 'Runner del Vacío',
          icon: Icons.directions_run,
          rarity: AchievementRarity.gold,
          unlocked: false,
          lore:
              'Cruza el umbral del esfuerzo físico sostenido y deja atrás la versión lenta del sistema.',
        ),
      ];

  static List<HunterTitleModel> get titles => const [
        HunterTitleModel(
          id: 'title-001',
          title: 'Cazador del Amanecer',
          requirement: 'Completa 10 misiones antes de las 08:00',
          lore:
              'Lo equipan quienes conquistan el día antes de que el mundo active su ruido.',
          accent: AppColors.neonGold,
          state: HunterTitleState.equipped,
        ),
        HunterTitleModel(
          id: 'title-002',
          title: 'Monje del Firewall',
          requirement: '7 días seguidos sin redes nocturnas',
          lore:
              'La mente permanece sellada. La corrupción rebota en el perímetro.',
          accent: AppColors.attrEsp,
          state: HunterTitleState.unlocked,
        ),
        HunterTitleModel(
          id: 'title-003',
          title: 'Herrero del Código',
          requirement: 'Resolver 25 retos de lógica',
          lore:
              'Cada algoritmo resuelto añade una capa de acero al juicio táctico.',
          accent: AppColors.attrLog,
          state: HunterTitleState.locked,
        ),
        HunterTitleModel(
          id: 'title-004',
          title: 'Embajador del Nexo',
          requirement: 'Mantener 3 interacciones sociales valiosas por semana',
          lore:
              'Título vivo y frágil: si el lazo social se enfría, el nombre se apaga.',
          accent: AppColors.attrSoc,
          state: HunterTitleState.lapsed,
        ),
      ];

  static List<CorruptionMarkModel> get marks => const [
        CorruptionMarkModel(
          id: 'mark-001',
          name: 'Marca del Exceso',
          trigger: '3 compras peligrosas en una sola semana',
          effect: '-10% regeneración de foco durante 48 horas',
          severity: CorruptionSeverity.warning,
          unlocked: true,
        ),
        CorruptionMarkModel(
          id: 'mark-002',
          name: 'Sello Carmesí',
          trigger: 'Acumular 5 consumos destructivos sin limpieza espiritual',
          effect: 'Subida agresiva de corrupción y pérdida temporal de AURA máxima',
          severity: CorruptionSeverity.severe,
          unlocked: false,
        ),
        CorruptionMarkModel(
          id: 'mark-003',
          name: 'Cicatriz del Mercado',
          trigger: 'Abusar del refugio de dopamina durante 4 ciclos consecutivos',
          effect: 'Los precios del mercado escalan y el HP moral colapsa más rápido',
          severity: CorruptionSeverity.critical,
          unlocked: false,
        ),
      ];
}


