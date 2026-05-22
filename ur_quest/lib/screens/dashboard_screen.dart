import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mission_model.dart';
import '../models/user_model.dart';
import '../providers/game_providers.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hud_bar.dart';
import '../widgets/hex_radar_chart.dart';
import '../widgets/mission_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync     = ref.watch(userProvider);
    final missionsAsync = ref.watch(dailyMissionsProvider);

    // Mientras carga el usuario mostramos un HUD skeleton
    final user     = userAsync.valueOrNull     ?? UserModel.mock();
    final missions = missionsAsync.valueOrNull ?? [];

    final notifier = ref.read(dailyMissionsProvider.notifier);
    final userNotif= ref.read(userProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar / Header HUD ────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.divider, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre + nivel
                    Row(
                      children: [
                        // Icono de nivel
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.neonCyan.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.shield,
                                  color: AppColors.neonCyan, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'LVL ${user.level}',
                                style: const TextStyle(
                                  color: AppColors.neonCyan,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _GlowText(
                          user.username.toUpperCase(),
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          glowColor: AppColors.neonCyan,
                        ),
                        const Spacer(),
                        // Saldo de Grit
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.neonGold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.neonGold.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.hexagon,
                                  color: AppColors.neonGold, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${user.gritBalance} \$ASH',
                                style: const TextStyle(
                                  color: AppColors.neonGold,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Barra de HP
                    HudBar(
                      percent: user.hpPercent,
                      color: AppColors.neonRed,
                      label: 'HP',
                      valueText: '${user.hp} / ${user.maxHp}',
                      height: 6,
                    ),
                    const SizedBox(height: 4),
                    // Racha
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Color(0xFFFF6D00), size: 13),
                        const SizedBox(width: 4),
                        _GlowText(
                          'RACHA: ${user.currentStreak} DÍAS',
                          color: const Color(0xFFFF6D00),
                          fontSize: 11,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Sección: Hexágono de Atributos ─────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'ATRIBUTOS',
                  subtitle: 'Perfil del Jugador',
                  icon: Icons.radar,
                  trailingAction: IconButton(
                    icon: const Icon(Icons.info_outline,
                        color: AppColors.neonCyan, size: 18),
                    tooltip: 'Qué significa cada atributo',
                    onPressed: () => _showAttrInfo(context),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      HexRadarChart(
                        attributes: user.attributes,
                        size: 230,
                      ),
                      const SizedBox(height: 16),
                      // Leyenda de atributos
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: [
                          _AttrLegend('INT',  AppColors.attrInt,  user.attributes['INT']  ?? 0),
                          _AttrLegend('LOG',  AppColors.attrLog,  user.attributes['LOG']  ?? 0),
                          _AttrLegend('CREA', AppColors.attrCrea, user.attributes['CREA'] ?? 0),
                          _AttrLegend('ESP',  AppColors.attrEsp,  user.attributes['ESP']  ?? 0),
                          _AttrLegend('VIT',  AppColors.attrVit,  user.attributes['VIT']  ?? 0),
                          _AttrLegend('SOC',  AppColors.attrSoc,  user.attributes['SOC']  ?? 0),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── Sección: Daily Quests ───────────────────────
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'DAILY QUESTS',
              subtitle: 'Misiones del día — No falles',
              icon: Icons.bolt,
              accent: AppColors.neonCyan,
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final m = missions[i];
                return _MissionCardWrapper(
                  mission: m,
                  onComplete: () async {
                    if (m.status != MissionStatus.pending) return;
                    await notifier.completeMission(m.id);
                    userNotif.addGrit(m.gritReward);
                    userNotif.addXp(m.xpReward);
                    if (ctx.mounted) {
                      AudioService.instance.playSuccess();
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surface,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AppColors.neonCyan, width: 1),
                          ),
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: AppColors.neonCyan, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '[SISTEMA]: Misión completada. +${m.gritReward} \$ASH / +${m.xpReward} XP',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                );
              },
              childCount: missions.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      // ── Bottom nav placeholder ──────────────────────────
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(icon: Icons.dashboard,       label: 'HUD',     active: true),
            _NavIcon(icon: Icons.shopping_bag_outlined, label: 'MARKET', active: false),
            _NavIcon(icon: Icons.emoji_events_outlined, label: 'LOGROS',  active: false),
            _NavIcon(icon: Icons.person_outline,  label: 'PERFIL',  active: false),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String  title;
  final String  subtitle;
  final IconData icon;
  final Color   accent;
  final Widget? trailingAction;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.accent = AppColors.neonCyan,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              Text(subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (trailingAction != null) trailingAction!,
        ],
      ),
    );
  }
}

class _AttrLegend extends StatelessWidget {
  final String attr;
  final Color  color;
  final int    value;
  const _AttrLegend(this.attr, this.color, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 4)],
          ),
        ),
        const SizedBox(width: 4),
        Text('$attr $value',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     active;
  const _NavIcon({required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.neonCyan : AppColors.textSecondary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        Text(label, style: TextStyle(
          color: color, fontSize: 9,
          fontWeight: FontWeight.w700, letterSpacing: 1,
        )),
      ],
    );
  }
}

// ── Texto con efecto glow tipo anime ───────────────────────
class _GlowText extends StatelessWidget {
  final String text;
  final Color  color;
  final Color? glowColor;
  final double fontSize;

  const _GlowText(this.text, {
    required this.color,
    this.glowColor,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final gc = glowColor ?? color;
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        shadows: [
          Shadow(color: gc.withOpacity(0.9), blurRadius: 8),
          Shadow(color: gc.withOpacity(0.6), blurRadius: 20),
          Shadow(color: gc.withOpacity(0.3), blurRadius: 40),
        ],
      ),
    );
  }
}

// ── Wrapper de MissionCard con estado de carga ─────────────
class _MissionCardWrapper extends StatefulWidget {
  final MissionModel mission;
  final Future<void> Function() onComplete;
  const _MissionCardWrapper({required this.mission, required this.onComplete});

  @override
  State<_MissionCardWrapper> createState() => _MissionCardWrapperState();
}

class _MissionCardWrapperState extends State<_MissionCardWrapper> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MissionCard(
          mission: widget.mission,
          onComplete: _loading
              ? null
              : () async {
                  setState(() => _loading = true);
                  await widget.onComplete();
                  if (mounted) setState(() => _loading = false);
                },
        ),
        if (_loading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.neonCyan),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Diálogo de info de atributos ───────────────────────────
void _showAttrInfo(BuildContext context) {
  const attrs = [
    ('INT',  AppColors.attrInt,  'Intelecto',     'Cursos, idiomas, aprendizaje continuo'),
    ('LOG',  AppColors.attrLog,  'Lógica',        'Estrategia, finanzas, pensamiento crítico'),
    ('CREA', AppColors.attrCrea, 'Creatividad',   'Arte, diseño, escritura, música'),
    ('ESP',  AppColors.attrEsp,  'Espiritualidad','Meditación, bienestar mental, propósito'),
    ('VIT',  AppColors.attrVit,  'Vitalidad',     'Ejercicio, nutrición, descanso, salud'),
    ('SOC',  AppColors.attrSoc,  'Social',        'Relaciones, comunidad, comunicación'),
  ];

  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.neonCyan, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.radar, color: AppColors.neonCyan, size: 20),
                const SizedBox(width: 8),
                const Text('ATRIBUTOS',
                  style: TextStyle(
                    color: AppColors.neonCyan,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: AppColors.neonCyan, blurRadius: 10),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Los 6 pilares de tu crecimiento',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 16),
            ...attrs.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: a.$2.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: a.$2.withOpacity(0.5)),
                    ),
                    child: Text(a.$1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: a.$2, fontSize: 10,
                        fontWeight: FontWeight.w800,
                        shadows: [Shadow(color: a.$2, blurRadius: 6)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.$3,
                          style: TextStyle(
                            color: a.$2,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(a.$4,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CERRAR',
                  style: TextStyle(
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    shadows: [Shadow(color: AppColors.neonCyan, blurRadius: 8)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

