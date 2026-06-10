import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/achievement_model.dart';
import '../models/user_model.dart';
import '../providers/game_providers.dart';
import '../providers/profile_customization_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/dynamic_avatar_widget.dart';
import '../widgets/hex_radar_chart.dart';
import '../widgets/hud_bar.dart';

const _profileBg = Color(0xFF070B14);

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).valueOrNull ?? UserModel.mock();
    final customization = ref.watch(profileCustomizationProvider);
    final equippedTitle = HunterCodexMock.titles.firstWhere(
      (title) => title.id == customization.activeTitleId,
      orElse: () => HunterCodexMock.titles.first,
    );
    final showcase = _resolveShowcaseSlots(customization.showcaseAchievementIds);
    final meta = _buildHunterProfileMeta(user, equippedTitle, showcase);
    final profileStats = _buildProfileStats(user);

    return Scaffold(
      backgroundColor: _profileBg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 12,
          16,
          92,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileTopSection(
              user: user,
              equippedTitle: equippedTitle,
              meta: meta,
              onChangeTitle: () => _showTitleSelector(context, ref, customization.activeTitleId),
            ),
            const SizedBox(height: 26),
            _SectionTitle(
              title: '[ ATRIBUTOS DEL CAZADOR ]',
              icon: Icons.radar,
              accent: AppColors.neonCyan,
            ),
            const SizedBox(height: 12),
            _StatsRadarPanel(attributes: user.attributes),
            const SizedBox(height: 26),
            _SectionTitle(
              title: '[ VITRINA DE TROFEOS ]',
              icon: Icons.workspace_premium_outlined,
              accent: AppColors.neonGold,
              trailingAction: TextButton(
                onPressed: () => _showShowcaseSelector(context, ref, customization.showcaseAchievementIds),
                child: Text(
                  'GESTIONAR',
                  style: GoogleFonts.shareTechMono(
                    color: AppColors.neonGold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _TrophyShowcase(slots: showcase),
            const SizedBox(height: 28),
            _SectionTitle(
              title: '[ ESTADÍSTICAS GLOBALES ]',
              icon: Icons.grid_view_rounded,
              accent: AppColors.textPrimary,
            ),
            const SizedBox(height: 14),
            _GlobalStatsPanel(stats: profileStats),
          ],
        ),
      ),
    );
  }

  void _showTitleSelector(BuildContext context, WidgetRef ref, String activeTitleId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.attrCrea.withValues(alpha: 0.35)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[ SELECTOR DE TÍTULO ]',
                  style: GoogleFonts.shareTechMono(
                    color: AppColors.attrCrea,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                ...HunterCodexMock.titles.map((title) {
                  final selectable = title.state == HunterTitleState.unlocked || title.state == HunterTitleState.equipped;
                  final active = title.id == activeTitleId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: selectable
                          ? () {
                              ref.read(profileCustomizationProvider.notifier).equipTitle(title.id);
                              Navigator.pop(context);
                            }
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: active
                              ? title.accent.withValues(alpha: 0.10)
                              : Colors.black.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: active
                                ? title.accent.withValues(alpha: 0.55)
                                : AppColors.divider,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title.title.toUpperCase(),
                                    style: GoogleFonts.shareTechMono(
                                      color: selectable ? title.accent : AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    title.requirement,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              active ? '[ ACTIVO ]' : selectable ? '[ EQUIPAR ]' : '[ BLOQUEADO ]',
                              style: GoogleFonts.shareTechMono(
                                color: active
                                    ? title.accent
                                    : selectable
                                        ? AppColors.neonCyan
                                        : AppColors.neonRed,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showShowcaseSelector(BuildContext context, WidgetRef ref, List<String?> showcaseIds) {
    final unlocked = HunterCodexMock.achievements.where((a) => a.unlocked).toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.neonGold.withValues(alpha: 0.35)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[ CONFIGURAR VITRINA ]',
                  style: GoogleFonts.shareTechMono(
                    color: AppColors.neonGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                for (int slot = 0; slot < showcaseIds.length; slot++) ...[
                  Text(
                    'SLOT ${slot + 1}',
                    style: GoogleFonts.shareTechMono(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _SelectorChip(
                        label: 'VACÍO',
                        active: showcaseIds[slot] == null,
                        color: AppColors.divider,
                        onTap: () => ref.read(profileCustomizationProvider.notifier).setShowcaseAchievement(slot, null),
                      ),
                      for (final achievement in unlocked)
                        _SelectorChip(
                          label: achievement.name.toUpperCase(),
                          active: showcaseIds[slot] == achievement.id,
                          color: _rarityColor(achievement.rarity),
                          onTap: () => ref.read(profileCustomizationProvider.notifier).setShowcaseAchievement(slot, achievement.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTopSection extends StatelessWidget {
  final UserModel user;
  final HunterTitleModel equippedTitle;
  final _HunterProfileMeta meta;
  final VoidCallback onChangeTitle;

  const _ProfileTopSection({
    required this.user,
    required this.equippedTitle,
    required this.meta,
    required this.onChangeTitle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final avatarBlock = _AvatarLead(user: user, meta: meta);
        final infoBlock = _HunterIdentityPanel(
          user: user,
          equippedTitle: equippedTitle,
          meta: meta,
          onChangeTitle: onChangeTitle,
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: avatarBlock),
              const SizedBox(width: 20),
              Expanded(flex: 5, child: infoBlock),
            ],
          );
        }

        return Column(
          children: [
            avatarBlock,
            const SizedBox(height: 18),
            infoBlock,
          ],
        );
      },
    );
  }
}

class _AvatarLead extends StatelessWidget {
  final UserModel user;
  final _HunterProfileMeta meta;
  const _AvatarLead({required this.user, required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.08),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          DynamicAvatarWidget(
            attributes: user.attributes,
            level: user.level,
            size: 220,
            rankLabel: meta.rankLabel,
            buildLabel: meta.buildName,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _AffinityChip(label: meta.primaryAffinity, color: meta.primaryColor),
              _AffinityChip(label: meta.secondaryAffinity, color: meta.secondaryColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '[ DYNAMIC AVATAR SYSTEM ]',
            style: GoogleFonts.shareTechMono(
              color: AppColors.textSecondary,
              fontSize: 10,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HunterIdentityPanel extends StatelessWidget {
  final UserModel user;
  final HunterTitleModel equippedTitle;
  final _HunterProfileMeta meta;
  final VoidCallback onChangeTitle;

  const _HunterIdentityPanel({
    required this.user,
    required this.equippedTitle,
    required this.meta,
    required this.onChangeTitle,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = equippedTitle.accent == AppColors.neonGold
        ? AppColors.neonGold
        : AppColors.attrCrea;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F1520),
            titleColor.withValues(alpha: 0.08),
            const Color(0xFF0B111A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RankBanner(meta: meta),
          const SizedBox(height: 12),
          Text(
            'PLAYER STATUS',
            style: GoogleFonts.shareTechMono(
              color: AppColors.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user.username.toUpperCase(),
            style: GoogleFonts.shareTechMono(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _ExpSection(user: user),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: titleColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: titleColor.withValues(alpha: 0.75)),
              boxShadow: [
                BoxShadow(
                  color: titleColor.withValues(alpha: 0.18),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Text(
              '[ ${equippedTitle.title.toUpperCase()} ]',
              style: GoogleFonts.shareTechMono(
                color: titleColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onChangeTitle,
            style: OutlinedButton.styleFrom(
              foregroundColor: meta.primaryColor,
              side: BorderSide(color: meta.primaryColor.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              '[ CAMBIAR TÍTULO ]',
              style: GoogleFonts.shareTechMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ProfileHudStrip(user: user),
          const SizedBox(height: 16),
          _BuildDossier(meta: meta),
          const SizedBox(height: 18),
          Text(
            meta.flavorText,
            style: TextStyle(
              color: Colors.grey[350],
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBanner extends StatelessWidget {
  final _HunterProfileMeta meta;
  const _RankBanner({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            meta.rankColor.withValues(alpha: 0.14),
            Colors.black.withValues(alpha: 0.12),
            meta.primaryColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: meta.rankColor.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: meta.rankColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: meta.rankColor.withValues(alpha: 0.55)),
            ),
            child: Text(
              meta.rankLabel,
              style: GoogleFonts.shareTechMono(
                color: meta.rankColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.buildName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  meta.classSubtitle,
                  style: TextStyle(
                    color: Colors.grey[350],
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildDossier extends StatelessWidget {
  final _HunterProfileMeta meta;
  const _BuildDossier({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: meta.primaryColor.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[ BUILD DOSSIER ]',
            style: GoogleFonts.shareTechMono(
              color: meta.primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DossierPill(label: 'MAIN', value: meta.primaryAffinity, color: meta.primaryColor),
              _DossierPill(label: 'SUB', value: meta.secondaryAffinity, color: meta.secondaryColor),
              _DossierPill(label: 'FOCO', value: meta.focusLabel, color: meta.rankColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _AffinityChip extends StatelessWidget {
  final String label;
  final Color color;
  const _AffinityChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: GoogleFonts.shareTechMono(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _DossierPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DossierPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label · ',
              style: GoogleFonts.shareTechMono(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHudStrip extends StatelessWidget {
  final UserModel user;
  const _ProfileHudStrip({required this.user});

  @override
  Widget build(BuildContext context) {
    final auraCap = (user.level * 180).clamp(600, 2400);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _StatusBarLine(
            icon: Icons.favorite_border,
            color: AppColors.neonRed,
            child: HudBar(
              percent: user.hpPercent,
              color: AppColors.neonRed,
              label: 'HP',
              valueText: '${user.hp} / ${user.maxHp}',
              height: 9,
            ),
          ),
          const SizedBox(height: 10),
          _StatusBarLine(
            icon: Icons.hexagon_outlined,
            color: AppColors.neonGold,
            child: HudBar(
              percent: (user.auraBalance / auraCap).clamp(0.0, 1.0),
              color: AppColors.neonGold,
              label: 'AURA RESERVA',
              valueText: '${user.auraBalance} / $auraCap',
              height: 9,
            ),
          ),
          const SizedBox(height: 10),
          _StatusBarLine(
            icon: Icons.local_fire_department_outlined,
            color: const Color(0xFFFF8A3D),
            child: HudBar(
              percent: (user.currentStreak / 14).clamp(0.0, 1.0),
              color: const Color(0xFFFF8A3D),
              label: 'RACHA DE CAZA',
              valueText: '${user.currentStreak} / 14 DÍAS',
              height: 9,
            ),
          ),
          const SizedBox(height: 10),
          _StatusBarLine(
            icon: Icons.warning_amber_rounded,
            color: AppColors.neonRed,
            child: HudBar(
              percent: (user.corruptionScore / 100).clamp(0.0, 1.0),
              color: AppColors.neonRed,
              label: 'CORRUPCIÓN',
              valueText: '${user.corruptionScore}%',
              height: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBarLine extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Widget child;
  const _StatusBarLine({required this.icon, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    );
  }
}

class _ExpSection extends StatelessWidget {
  final UserModel user;
  const _ExpSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NIVEL ${user.level}',
          style: GoogleFonts.shareTechMono(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        _GradientExpBar(progress: user.xpPercent),
        const SizedBox(height: 8),
        Text(
          '${user.xpTotal} / ${user.xpForNextLevel} XP',
          style: GoogleFonts.shareTechMono(
            color: AppColors.textSecondary,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _GradientExpBar extends StatelessWidget {
  final double progress;
  const _GradientExpBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return Container(
      height: 14,
      decoration: BoxDecoration(
        color: const Color(0xFF111A28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: clamped,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.neonCyan, AppColors.neonBlue],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonBlue.withValues(alpha: 0.25),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRadarPanel extends StatelessWidget {
  final Map<String, int> attributes;
  const _StatsRadarPanel({required this.attributes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Text(
            'PERFIL DE ATRIBUTOS',
            style: GoogleFonts.shareTechMono(
              color: AppColors.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: HexRadarChart(
              attributes: attributes,
              size: 260,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrophyShowcase extends StatelessWidget {
  final List<AchievementBadgeModel?> slots;
  const _TrophyShowcase({required this.slots});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < slots.length; i++) ...[
            _ShowcaseSlot(achievement: slots[i]),
            if (i != slots.length - 1) const SizedBox(width: 18),
          ],
        ],
      ),
    );
  }
}

class _ShowcaseSlot extends StatelessWidget {
  final AchievementBadgeModel? achievement;
  const _ShowcaseSlot({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final filled = achievement != null;
    final color = filled ? _rarityColor(achievement!.rarity) : AppColors.divider;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: achievement == null ? null : () => _showAchievementSheet(context, achievement!),
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 86,
          height: 96,
          child: Center(
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: filled ? color.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: filled ? color : AppColors.divider.withValues(alpha: 0.75),
                    width: 1.4,
                  ),
                  boxShadow: filled
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.28),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Transform.rotate(
                  angle: -math.pi / 4,
                  child: Center(
                    child: filled
                        ? Icon(
                            achievement!.icon,
                            color: color,
                            size: 28,
                            shadows: [
                              Shadow(
                                color: color.withValues(alpha: 0.85),
                                blurRadius: 16,
                              ),
                            ],
                          )
                        : Icon(
                            Icons.add,
                            color: AppColors.textSecondary.withValues(alpha: 0.25),
                            size: 24,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAchievementSheet(BuildContext context, AchievementBadgeModel achievement) {
    final color = _rarityColor(achievement.rarity);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: color.withValues(alpha: 0.75)),
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
                width: 110,
                height: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                  border: Border.all(color: color, width: 1.3),
                ),
                child: Icon(
                  achievement.icon,
                  size: 54,
                  color: color,
                  shadows: [
                    Shadow(color: color.withValues(alpha: 0.85), blurRadius: 24),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                achievement.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.shareTechMono(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.unlockedAt == null
                    ? 'REGISTRO SIN FECHA'
                    : 'DESBLOQUEADO · ${_formatDate(achievement.unlockedAt!)}',
                style: GoogleFonts.shareTechMono(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.1,
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

class _GlobalStatsPanel extends StatelessWidget {
  final List<_ProfileStatCardData> stats;
  const _GlobalStatsPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100
            ? 4
            : width >= 700
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: width >= 700 ? 1.65 : 2.5,
          ),
          itemBuilder: (context, index) => _ProfileStatCard(data: stats[index]),
        );
      },
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final _ProfileStatCardData data;
  const _ProfileStatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: data.color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(data.icon, color: data.color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.label,
                  style: GoogleFonts.shareTechMono(
                    color: data.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (data.alert)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.neonRed.withValues(alpha: 0.45)),
                  ),
                  child: Text(
                    'ALERTA',
                    style: GoogleFonts.shareTechMono(
                      color: AppColors.neonRed,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.caption,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final Widget? trailingAction;

  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.accent,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.shareTechMono(
            color: Colors.grey[300],
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const Spacer(),
        trailingAction ?? const SizedBox.shrink(),
      ],
    );
  }
}

class _SelectorChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _SelectorChip({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.14) : Colors.black.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? color.withValues(alpha: 0.65) : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.shareTechMono(
            color: active ? color : AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ProfileStatCardData {
  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;
  final bool alert;

  const _ProfileStatCardData({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
    this.alert = false,
  });
}

class _HunterProfileMeta {
  final String rankLabel;
  final Color rankColor;
  final String buildName;
  final String classSubtitle;
  final String primaryAffinity;
  final String secondaryAffinity;
  final Color primaryColor;
  final Color secondaryColor;
  final String focusLabel;
  final String flavorText;

  const _HunterProfileMeta({
    required this.rankLabel,
    required this.rankColor,
    required this.buildName,
    required this.classSubtitle,
    required this.primaryAffinity,
    required this.secondaryAffinity,
    required this.primaryColor,
    required this.secondaryColor,
    required this.focusLabel,
    required this.flavorText,
  });
}

List<AchievementBadgeModel?> _resolveShowcaseSlots(List<String?> showcaseIds) {
  return showcaseIds.map((id) {
    if (id == null) return null;
    for (final achievement in HunterCodexMock.achievements) {
      if (achievement.id == id) return achievement;
    }
    return null;
  }).toList();
}

_HunterProfileMeta _buildHunterProfileMeta(
  UserModel user,
  HunterTitleModel activeTitle,
  List<AchievementBadgeModel?> showcase,
) {
  final entries = user.attributes.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final primary = entries.isNotEmpty ? entries[0] : const MapEntry('INT', 0);
  final secondary = entries.length > 1 ? entries[1] : primary;
  final trophyScore = showcase.whereType<AchievementBadgeModel>().fold<int>(0, (sum, item) {
    switch (item.rarity) {
      case AchievementRarity.bronze:
        return sum + 3;
      case AchievementRarity.silver:
        return sum + 6;
      case AchievementRarity.gold:
        return sum + 10;
    }
  });
  final titleBonus = activeTitle.state == HunterTitleState.equipped ? 6 : 3;
  final average = entries.isEmpty
      ? 0.0
      : entries.fold<int>(0, (sum, e) => sum + e.value) / entries.length;
  final score = average + (user.level * 2.8) + (user.currentStreak * 2) + trophyScore + titleBonus - (user.corruptionScore * 0.25);

  String rank;
  Color rankColor;
  if (score >= 115) {
    rank = 'S-RANK';
    rankColor = AppColors.neonGold;
  } else if (score >= 92) {
    rank = 'A-RANK';
    rankColor = const Color(0xFFFFA726);
  } else if (score >= 72) {
    rank = 'B-RANK';
    rankColor = const Color(0xFF9BE7FF);
  } else if (score >= 58) {
    rank = 'C-RANK';
    rankColor = AppColors.neonCyan;
  } else if (score >= 45) {
    rank = 'D-RANK';
    rankColor = const Color(0xFF90A4AE);
  } else {
    rank = 'E-RANK';
    rankColor = const Color(0xFF607D8B);
  }

  final primaryName = _statName(primary.key);
  final secondaryName = _statName(secondary.key);
  final buildName = switch (primary.key) {
    'INT' => 'ARQUITECTO ARCANO',
    'LOG' => 'ESTRATEGA DEL VACÍO',
    'VIT' => 'BERSERKER DISCIPLINADO',
    'ESP' => 'ORÁCULO DEL SILENCIO',
    'SOC' => 'DIPLOMÁTICO DE SOMBRA',
    'CREA' => 'ARTÍFICE DEL NEXO',
    _ => 'CAZADOR EN FORMACIÓN',
  };
  final subtitle = 'Afinidad dominante $primaryName · soporte $secondaryName';
  final focusLabel = user.corruptionScore >= 50
      ? 'RIESGO DE CORRUPCIÓN'
      : user.currentStreak >= 7
          ? 'MOMENTUM ACTIVO'
          : 'ESTABILIDAD TÁCTICA';
  final flavor = 'Rango $rank estabilizado por $primaryName, reforzado por $secondaryName '
      'y legitimado por ${showcase.whereType<AchievementBadgeModel>().length} trofeos en vitrina. '
      'La firma del cazador indica ${user.corruptionScore >= 50 ? 'volatilidad en el sistema' : 'progreso controlado y sostenible'}.';

  return _HunterProfileMeta(
    rankLabel: rank,
    rankColor: rankColor,
    buildName: buildName,
    classSubtitle: subtitle,
    primaryAffinity: primaryName,
    secondaryAffinity: secondaryName,
    primaryColor: _statColor(primary.key),
    secondaryColor: _statColor(secondary.key),
    focusLabel: focusLabel,
    flavorText: flavor,
  );
}

List<_ProfileStatCardData> _buildProfileStats(UserModel user) {
  final auraAccumulated = user.auraBalance + (user.level * 320) + (user.currentStreak * 95);
  final missionsCompleted = 42 + (user.level * 3);
  final corruption = user.corruptionScore;

  return [
    _ProfileStatCardData(
      label: 'AURA TOTAL ACUMULADA',
      value: auraAccumulated.toString(),
      caption: 'Energía absorbida a lo largo del progreso del cazador.',
      icon: Icons.hexagon,
      color: AppColors.neonGold,
    ),
    _ProfileStatCardData(
      label: 'MISIONES COMPLETADAS',
      value: missionsCompleted.toString(),
      caption: 'Contratos y quests resueltos con éxito por el sistema.',
      icon: Icons.task_alt,
      color: AppColors.neonCyan,
    ),
    _ProfileStatCardData(
      label: 'RACHA ACTUAL',
      value: '${user.currentStreak} DÍAS',
      caption: 'Constancia activa en ciclos consecutivos sin colapso.',
      icon: Icons.local_fire_department,
      color: Color(0xFFFF8A3D),
    ),
    _ProfileStatCardData(
      label: 'NIVEL DE CORRUPCIÓN',
      value: '$corruption%',
      caption: 'El mercado deja marcas. Mantén esta métrica bajo control.',
      icon: Icons.warning_amber_rounded,
      color: AppColors.neonRed,
      alert: corruption >= 50,
    ),
  ];
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

String _statName(String stat) {
  switch (stat) {
    case 'INT':
      return 'INTELECTO';
    case 'LOG':
      return 'LÓGICA';
    case 'CREA':
      return 'CREATIVIDAD';
    case 'ESP':
      return 'ESPIRITUALIDAD';
    case 'VIT':
      return 'VITALIDAD';
    case 'SOC':
      return 'SOCIAL';
    default:
      return stat;
  }
}

Color _statColor(String stat) {
  switch (stat) {
    case 'INT':
      return AppColors.attrInt;
    case 'LOG':
      return AppColors.attrLog;
    case 'CREA':
      return AppColors.attrCrea;
    case 'ESP':
      return AppColors.attrEsp;
    case 'VIT':
      return AppColors.attrVit;
    case 'SOC':
      return AppColors.attrSoc;
    default:
      return AppColors.neonCyan;
  }
}

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}

