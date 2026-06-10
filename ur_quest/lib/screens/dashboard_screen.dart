import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mission_model.dart';
import '../models/user_model.dart';
import '../providers/game_providers.dart';
import '../services/regex_dictionary_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hud_bar.dart';
import '../widgets/hex_radar_chart.dart';
import '../widgets/mission_card.dart';
import '../widgets/system_quest_card.dart';
import '../widgets/create_entry_dialog.dart';
import 'achievements_screen.dart';
import 'market_screen.dart';
import 'user_profile_screen.dart';

// ── Índice de pestaña activa ───────────────────────────────
final _navIndexProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(_navIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: navIndex,
        children: const [
          _HudBody(),
          MarketScreen(),
          AchievementsScreen(),
          UserProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              icon: Icons.dashboard,
              label: 'HUD',
              active: navIndex == 0,
              onTap: () => ref.read(_navIndexProvider.notifier).state = 0,
            ),
            _NavIcon(
              icon: Icons.shopping_bag_outlined,
              label: 'MARKET',
              active: navIndex == 1,
              onTap: () => ref.read(_navIndexProvider.notifier).state = 1,
            ),
            _NavIcon(
              icon: Icons.emoji_events_outlined,
              label: 'LOGROS',
              active: navIndex == 2,
              onTap: () => ref.read(_navIndexProvider.notifier).state = 2,
            ),
            _NavIcon(
              icon: Icons.person_outline,
              label: 'PERFIL',
              active: navIndex == 3,
              onTap: () => ref.read(_navIndexProvider.notifier).state = 3,
            ),
          ],
        ),
      ),
    );
  }
}


// ── Cuerpo del HUD (extraído del build original) ──────────
class _HudBody extends ConsumerWidget {
  const _HudBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync     = ref.watch(userProvider);
    final missionsAsync = ref.watch(dailyMissionsProvider);

    // Mientras carga el usuario mostramos un HUD skeleton
    final user     = userAsync.valueOrNull     ?? UserModel.mock();
    final missions = missionsAsync.valueOrNull ?? [];
    final dailyBoardMissions = missions.where(_isDailyBoardMission).toList();
    final longTermMissions = missions.where(_isLongTermBoardMission).toList();

    final notifier = ref.read(dailyMissionsProvider.notifier);
    final userNotif= ref.read(userProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.neonCyan,
          foregroundColor: Colors.black,
          elevation: 0,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const CreateEntryDialog(mode: EntryMode.mission),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar / Header HUD ────────────────────────
          SliverAppBar(
            expandedHeight: 178,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.divider, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nombre + nivel
                    Row(
                      children: [
                        // Icono de nivel
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.neonCyan.withValues(alpha: 0.4)),
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
                            color: AppColors.neonGold.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.neonGold.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.hexagon,
                                  color: AppColors.neonGold, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${user.gritBalance} AURA',
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
                    const SizedBox(height: 5),
                    // Barra de XP
                    HudBar(
                      percent: user.xpPercent,
                      color: AppColors.neonGold,
                      label: 'XP',
                      valueText: '${user.xpTotal} / ${user.xpForNextLevel}',
                      height: 5,
                    ),
                    const SizedBox(height: 5),
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

                // ── Avatar de jugador (fuera del hexágono) ──
                _AttrAvatar(attributes: user.attributes, size: 80),
                const SizedBox(height: 8),

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

          // ── Sección: Daily Quests (PageView por atributo) ──
          SliverToBoxAdapter(
            child: _QuestBoardLayout(
              dailyMissions: dailyBoardMissions,
              longTermMissions: longTermMissions,
              notifier: notifier,
              userNotif: userNotif,
              ctx: context,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

DateTime _startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

bool _isDailyBoardMission(MissionModel mission) {
  if (mission.isDaily) return true;
  if (mission.dueDate == null) return false;

  final today = _startOfDay(DateTime.now());
  final due = _startOfDay(mission.dueDate!);
  final tomorrow = today.add(const Duration(days: 1));
  return !due.isAfter(tomorrow);
}

bool _isLongTermBoardMission(MissionModel mission) {
  if (mission.isDaily) return false;
  if (mission.dueDate == null) return true;

  final today = _startOfDay(DateTime.now());
  final due = _startOfDay(mission.dueDate!);
  return due.isAfter(today.add(const Duration(days: 1)));
}

// ── Widgets auxiliares ─────────────────────────────────────

// ── Avatar con glow de los 2 atributos más altos ──────────
class _AttrAvatar extends StatelessWidget {
  final Map<String, int> attributes;
  final double size;
  const _AttrAvatar({required this.attributes, required this.size});

  static const _attrColors = {
    'INT':  AppColors.attrInt,
    'LOG':  AppColors.attrLog,
    'CREA': AppColors.attrCrea,
    'ESP':  AppColors.attrEsp,
    'VIT':  AppColors.attrVit,
    'SOC':  AppColors.attrSoc,
  };

  @override
  Widget build(BuildContext context) {
    final sorted = attributes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final c1 = _attrColors[sorted[0].key] ?? AppColors.neonCyan;
    final c2 = _attrColors[sorted.length > 1 ? sorted[1].key : sorted[0].key]
        ?? AppColors.neonCyan;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: c1, width: 2),
        boxShadow: [
          BoxShadow(color: c1.withValues(alpha: 0.45), blurRadius: 16, spreadRadius: 2),
          BoxShadow(color: c2.withValues(alpha: 0.25), blurRadius: 28, spreadRadius: 0),
        ],
      ),
      child: ClipOval(
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: [c1, c2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Icon(Icons.person, size: size * 0.62, color: Colors.white),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String  title;
  final String  subtitle;
  final IconData icon;
  final Widget? trailingAction;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonCyan, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: TextStyle(
                  color: AppColors.neonCyan,
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
          trailingAction ?? const SizedBox.shrink(),
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
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4)],
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
  final VoidCallback? onTap;
  const _NavIcon({required this.icon, required this.label, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.neonCyan : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            Text(label, style: TextStyle(
              color: color, fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 1,
            )),
          ],
        ),
      ),
    );
  }
}

class _QuestBoardLayout extends StatelessWidget {
  final List<MissionModel> dailyMissions;
  final List<MissionModel> longTermMissions;
  final MissionsNotifier   notifier;
  final UserNotifier       userNotif;
  final BuildContext       ctx;

  const _QuestBoardLayout({
    required this.dailyMissions,
    required this.longTermMissions,
    required this.notifier,
    required this.userNotif,
    required this.ctx,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1100;

    final dailyPanel = _QuestCarouselPanel(
      title: 'DAILY QUESTS',
      subtitle: 'Rutina crítica y contratos con vencimiento hoy/mañana',
      emptyMessage: 'No hay quests inmediatas. Crea una misión diaria o acerca un deadline.',
      accent: AppColors.neonCyan,
      icon: Icons.bolt,
      variant: QuestCardVariant.daily,
      missions: dailyMissions,
      notifier: notifier,
      userNotif: userNotif,
      ctx: ctx,
    );

    final longTermPanel = _QuestCarouselPanel(
      title: 'LONG-TERM QUESTS',
      subtitle: 'Operaciones estratégicas con deadline futuro',
      emptyMessage: 'No hay contratos a largo plazo activos.',
      accent: const Color(0xFFB388FF),
      icon: Icons.auto_awesome,
      variant: QuestCardVariant.longTerm,
      missions: longTermMissions,
      notifier: notifier,
      userNotif: userNotif,
      ctx: ctx,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: dailyPanel),
                const SizedBox(width: 16),
                Expanded(child: longTermPanel),
              ],
            )
          : Column(
              children: [
                dailyPanel,
                const SizedBox(height: 20),
                longTermPanel,
              ],
            ),
    );
  }
}

class _QuestCarouselPanel extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emptyMessage;
  final Color accent;
  final IconData icon;
  final QuestCardVariant variant;
  final List<MissionModel> missions;
  final MissionsNotifier notifier;
  final UserNotifier userNotif;
  final BuildContext ctx;

  const _QuestCarouselPanel({
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.accent,
    required this.icon,
    required this.variant,
    required this.missions,
    required this.notifier,
    required this.userNotif,
    required this.ctx,
  });

  @override
  State<_QuestCarouselPanel> createState() => _QuestCarouselPanelState();
}

class _QuestCarouselPanelState extends State<_QuestCarouselPanel> {
  late final ScrollController _scroll;
  final Set<String> _completed = {};
  static const double _cardHeight = 540.0;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Map<String, List<MissionModel>> get _grouped {
    final map = <String, List<MissionModel>>{};
    for (final m in widget.missions) {
      map.putIfAbsent(m.attribute, () => []).add(m);
    }
    return map;
  }

  void _scrollTo(double delta) {
    if (!_scroll.hasClients) return;
    final target = (_scroll.offset + delta)
        .clamp(0.0, _scroll.position.maxScrollExtent);
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final attrs = grouped.keys.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 700
            ? 320.0
            : (constraints.maxWidth - 52).clamp(260.0, 360.0);
        final cardStep = cardWidth + 24;

        return Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.accent.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(widget.icon, color: widget.accent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: widget.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            attrs.isEmpty
                                ? widget.emptyMessage
                                : '${attrs.length} áreas · desliza o usa las flechas',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: widget.accent.withValues(alpha: 0.72),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (attrs.isEmpty)
                _EmptyQuestPanel(message: widget.emptyMessage, accent: widget.accent)
              else
                SizedBox(
                  height: _cardHeight,
                  child: Stack(
                    children: [
                      Center(
                        child: SingleChildScrollView(
                          controller: _scroll,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < attrs.length; i++)
                                Builder(
                                  builder: (_) {
                                    final attr = attrs[i];
                                    final missions = grouped[attr]!;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: SizedBox(
                                        width: cardWidth,
                                        child: SystemQuestCard(
                                          attribute: attr,
                                          missions: missions,
                                          variant: widget.variant,
                                          onComplete: (id) async {
                                            final mission = missions.firstWhere((m) => m.id == id);
                                            await widget.notifier.completeMission(id);
                                            widget.userNotif.addAura(mission.gritReward);
                                            widget.userNotif.addXp(mission.xpReward);
                                            setState(() => _completed.add(id));

                                            final allDone = missions.every(
                                              (m) => m.status == MissionStatus.completed || _completed.contains(m.id),
                                            );
                                            if (allDone) {
                                              Future.delayed(const Duration(milliseconds: 600), () {
                                                _scrollTo(cardStep);
                                              });
                                            }

                                            if (widget.ctx.mounted) {
                                              ScaffoldMessenger.of(widget.ctx).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: AppColors.surface,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    side: BorderSide(color: widget.accent, width: 1),
                                                  ),
                                                  content: Row(
                                                    children: [
                                                      Icon(Icons.check_circle, color: widget.accent, size: 16),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          '[SISTEMA]: +${mission.gritReward} AURA / +${mission.xpReward} XP',
                                                          style: const TextStyle(
                                                            color: AppColors.textPrimary,
                                                            fontSize: 12,
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
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _ArrowButton(
                            icon: Icons.arrow_back_ios_rounded,
                            onTap: () => _scrollTo(-cardStep),
                            color: widget.accent,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _ArrowButton(
                            icon: Icons.arrow_forward_ios_rounded,
                            onTap: () => _scrollTo(cardStep),
                            color: widget.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyQuestPanel extends StatelessWidget {
  final String message;
  final Color accent;

  const _EmptyQuestPanel({required this.message, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_late_outlined, color: accent.withValues(alpha: 0.75), size: 28),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón flecha de navegación ─────────────────────────────
class _ArrowButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final Color color;
  const _ArrowButton({required this.icon, required this.onTap, this.color = AppColors.neonCyan});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(
              color: color.withValues(alpha: 0.55), width: 1),
          boxShadow: [BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 12,
          )],
        ),
        child: Icon(icon, color: color, size: 16),
      ),
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
          Shadow(color: gc.withValues(alpha: 0.9), blurRadius: 8),
          Shadow(color: gc.withValues(alpha: 0.6), blurRadius: 20),
          Shadow(color: gc.withValues(alpha: 0.3), blurRadius: 40),
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
                color: AppColors.background.withValues(alpha: 0.5),
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
                      color: a.$2.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: a.$2.withValues(alpha: 0.5)),
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

