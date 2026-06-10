import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/achievement_model.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _CodexHeader(),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.06),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.18),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  labelPadding: EdgeInsets.zero,
                  labelColor: AppColors.neonCyan,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    _CodexTab(label: '[ HITOS ]'),
                    _CodexTab(label: '[ TÍTULOS ]'),
                    _CodexTab(label: '[ MARCAS ]'),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    _AchievementsTab(),
                    _TitlesTab(),
                    _MarksTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodexHeader extends StatelessWidget {
  const _CodexHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.neonBlue.withValues(alpha: 0.08),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.7)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.18),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.neonCyan, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CÓDICE DE CAZADOR',
                      style: GoogleFonts.shareTechMono(
                        color: AppColors.neonCyan,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                        shadows: [
                          Shadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.8),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '[ REGISTRO DE HITOS, TÍTULOS Y CICATRICES DEL SISTEMA ]',
                      style: GoogleFonts.shareTechMono(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Una vitrina permanente para las hazañas que sobreviven al paso del tiempo y a la corrupción del mercado.',
            style: TextStyle(
              color: Colors.grey[350],
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodexTab extends StatelessWidget {
  final String label;
  const _CodexTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.shareTechMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _AchievementsTab extends StatelessWidget {
  const _AchievementsTab();

  @override
  Widget build(BuildContext context) {
    final items = HunterCodexMock.achievements;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1200
            ? 6
            : width >= 900
                ? 5
                : width >= 700
                    ? 4
                    : 3;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 16,
            childAspectRatio: 0.83,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => AchievementBadge(
            achievement: items[index],
            onTap: () => _showAchievementSheet(context, items[index]),
          ),
        );
      },
    );
  }

  void _showAchievementSheet(BuildContext context, AchievementBadgeModel achievement) {
    final color = _rarityColor(achievement.rarity);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: color.withValues(alpha: 0.7), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.24),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 120,
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
                      blurRadius: 26,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  achievement.icon,
                  size: 58,
                  color: achievement.unlocked
                      ? color
                      : AppColors.textSecondary.withValues(alpha: 0.4),
                  shadows: achievement.unlocked
                      ? [Shadow(color: color.withValues(alpha: 0.8), blurRadius: 24)]
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                achievement.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.shareTechMono(
                  color: achievement.unlocked ? color : AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.unlocked && achievement.unlockedAt != null
                    ? 'DESBLOQUEADO · ${_formatDate(achievement.unlockedAt!)}'
                    : 'REGISTRO AÚN NO DESCIFRADO',
                style: GoogleFonts.shareTechMono(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.18)),
                ),
                child: Text(
                  achievement.lore,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 13,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AchievementBadge extends StatelessWidget {
  final AchievementBadgeModel achievement;
  final VoidCallback onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor(achievement.rarity);
    final glowColor = achievement.unlocked ? color : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: achievement.unlocked
                              ? color.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: achievement.unlocked
                                ? color
                                : AppColors.divider.withValues(alpha: 0.8),
                            width: 1.4,
                          ),
                          boxShadow: achievement.unlocked
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.30),
                                    blurRadius: 18,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ),
                    Icon(
                      achievement.icon,
                      size: 34,
                      color: achievement.unlocked
                          ? color
                          : glowColor.withValues(alpha: 0.30),
                      shadows: achievement.unlocked
                          ? [
                              Shadow(
                                color: color.withValues(alpha: 0.85),
                                blurRadius: 18,
                              ),
                            ]
                          : [],
                    ),
                    if (!achievement.unlocked)
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.03),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.name.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.shareTechMono(
              color: achievement.unlocked ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _TitlesTab extends StatelessWidget {
  const _TitlesTab();

  @override
  Widget build(BuildContext context) {
    final titles = HunterCodexMock.titles;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: titles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _TitleRow(title: titles[index]),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final HunterTitleModel title;
  const _TitleRow({required this.title});

  @override
  Widget build(BuildContext context) {
    final canEquip = title.state == HunterTitleState.unlocked || title.state == HunterTitleState.equipped;
    final isEquipped = title.state == HunterTitleState.equipped;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: title.accent.withValues(alpha: 0.08),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: title.accent,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: title.accent.withValues(alpha: 0.45),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title.title,
                          style: TextStyle(
                            color: title.accent,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _TitleActionPill(
                        canEquip: canEquip,
                        isEquipped: isEquipped,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title.requirement,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title.lore,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  if (!canEquip) ...[
                    const SizedBox(height: 12),
                    Text(
                      '[ REQUISITOS NO CUMPLIDOS ]',
                      style: GoogleFonts.shareTechMono(
                        color: AppColors.neonRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleActionPill extends StatelessWidget {
  final bool canEquip;
  final bool isEquipped;

  const _TitleActionPill({required this.canEquip, required this.isEquipped});

  @override
  Widget build(BuildContext context) {
    final color = canEquip ? AppColors.neonCyan : AppColors.neonRed;
    final label = canEquip
        ? (isEquipped ? '[ EQUIPADO ]' : '[ EQUIPAR ]')
        : '[ REQUISITOS NO CUMPLIDOS ]';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: GoogleFonts.shareTechMono(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _MarksTab extends StatelessWidget {
  const _MarksTab();

  @override
  Widget build(BuildContext context) {
    final marks = HunterCodexMock.marks;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: marks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _MarkThreatCard(mark: marks[index]),
    );
  }
}

class _MarkThreatCard extends StatelessWidget {
  final CorruptionMarkModel mark;
  const _MarkThreatCard({required this.mark});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(mark.severity);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF19080C),
            const Color(0xFF120406),
            color.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.08),
                border: Border.all(color: color.withValues(alpha: 0.45)),
              ),
              child: Icon(
                mark.unlocked ? Icons.dangerous_outlined : Icons.lock_outline,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mark.name.toUpperCase(),
                    style: GoogleFonts.shareTechMono(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ThreatLine(label: 'TRIGGER', value: mark.trigger),
                  const SizedBox(height: 8),
                  _ThreatLine(label: 'PENALIZACIÓN', value: mark.effect),
                  const SizedBox(height: 12),
                  Text(
                    mark.unlocked ? '[ MARCA ACTIVA EN EL HISTORIAL ]' : '[ SELLO TODAVÍA LATENTE ]',
                    style: GoogleFonts.shareTechMono(
                      color: mark.unlocked ? color : color.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreatLine extends StatelessWidget {
  final String label;
  final String value;
  const _ThreatLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.shareTechMono(
            color: AppColors.neonRed.withValues(alpha: 0.85),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

Color _rarityColor(AchievementRarity rarity) {
  switch (rarity) {
    case AchievementRarity.bronze:
      return const Color(0xFFCD7F32);
    case AchievementRarity.silver:
      return const Color(0xFF9BE7FF);
    case AchievementRarity.gold:
      return AppColors.neonGold;
  }
}

Color _severityColor(CorruptionSeverity severity) {
  switch (severity) {
    case CorruptionSeverity.warning:
      return const Color(0xFFFF6D6D);
    case CorruptionSeverity.severe:
      return const Color(0xFFFF1744);
    case CorruptionSeverity.critical:
      return const Color(0xFFB71C1C);
  }
}

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}

