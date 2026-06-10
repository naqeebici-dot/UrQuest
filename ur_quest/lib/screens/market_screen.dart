import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reward_model.dart';
import '../models/user_model.dart';
import '../providers/game_providers.dart';
import '../services/audio_service.dart';
import '../services/regex_dictionary_service.dart';
import '../theme/app_theme.dart';
import '../widgets/create_entry_dialog.dart';

// ─────────────────────────────────────────────────────────
// Helpers de tier
// ─────────────────────────────────────────────────────────
Color _tierColor(RewardTier tier) {
  switch (tier) {
    case RewardTier.BRONZE: return const Color(0xFFCD7F32);
    case RewardTier.SILVER: return const Color(0xFF00E5FF);
    case RewardTier.GOLD:   return const Color(0xFFFFD700);
  }
}

String _tierName(RewardTier tier) {
  switch (tier) {
    case RewardTier.BRONZE: return 'BRONZE';
    case RewardTier.SILVER: return 'SILVER';
    case RewardTier.GOLD:   return 'GOLD';
  }
}

/// Emoji representativo de cada recompensa
String _rewardEmoji(RewardModel r) {
  if (r.emoji.trim().isNotEmpty) return r.emoji;
  final parsed = SystemParserService.evaluate(
    '${r.title} ${r.description}',
    mode: EntryMode.reward,
  );
  return parsed.suggestedEmoji ?? '🎁';
}

// Provider local para carta seleccionada (panel lateral web)
final _selectedRewardProvider = StateProvider<RewardModel?>((ref) => null);

// ─────────────────────────────────────────────────────────
// MarketScreen
// ─────────────────────────────────────────────────────────
class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(rewardsProvider);
    final user = ref.watch(userProvider).valueOrNull ?? UserModel.mock();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.neonGold.withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.neonGold,
          foregroundColor: Colors.black,
          elevation: 0,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const CreateEntryDialog(mode: EntryMode.reward),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          final isWide = constraints.maxWidth > 800;
          return Column(
            children: [
              _MarketHeader(user: user),
              Expanded(
                child: rewardsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.neonGold),
                  ),
                  error: (e, _) => Center(
                    child: Text('Error: $e',
                        style: const TextStyle(color: AppColors.neonRed)),
                  ),
                  data: (rewards) => isWide
                      ? _WideLayout(rewards: rewards, user: user)
                      : _NarrowLayout(rewards: rewards, user: user),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Header "REFUGIO DE DOPAMINA"
// ─────────────────────────────────────────────────────────
class _MarketHeader extends StatelessWidget {
  final UserModel user;
  const _MarketHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final corruption = user.corruptionScore;
    final corrColor  = corruption > 80 ? AppColors.neonRed : const Color(0xFFAA00FF);

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 10, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
            bottom: BorderSide(color: AppColors.divider, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGold.withValues(alpha: 0.05),
            blurRadius: 20, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REFUGIO DE DOPAMINA',
                      style: GoogleFonts.shareTechMono(
                        color: AppColors.neonGold,
                        fontSize: 15, fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        shadows: [Shadow(
                          color: AppColors.neonGold.withValues(alpha: 0.8),
                          blurRadius: 12,
                        )],
                      ),
                    ),
                    Text(
                      '[ MERCADO DE RECOMPENSAS — AURA EXCHANGE ]',
                      style: GoogleFonts.shareTechMono(
                        color: AppColors.textSecondary,
                        fontSize: 8, letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Saldo $ASH badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.neonGold.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.neonGold.withValues(alpha: 0.4)),
                  boxShadow: [BoxShadow(
                    color: AppColors.neonGold.withValues(alpha: 0.18), blurRadius: 12,
                  )],
                ),
                child: Row(children: [
                  const Icon(Icons.hexagon, color: AppColors.neonGold, size: 14),
                  const SizedBox(width: 6),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '${user.gritBalance}',
                        style: GoogleFonts.shareTechMono(
                          color: AppColors.neonGold, fontSize: 14,
                          fontWeight: FontWeight.w700,
                          shadows: [const Shadow(color: AppColors.neonGold, blurRadius: 8)],
                        ),
                      ),
                      TextSpan(
                        text: ' AURA',
                        style: GoogleFonts.shareTechMono(
                          color: AppColors.neonGold.withValues(alpha: 0.65),
                          fontSize: 9, letterSpacing: 1,
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: corrColor, size: 12),
              const SizedBox(width: 6),
              Text('CORRUPCIÓN',
                style: GoogleFonts.shareTechMono(
                  color: corrColor, fontSize: 8, letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: corruption / 100,
                    minHeight: 4,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation(corrColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$corruption%',
                style: GoogleFonts.shareTechMono(
                  color: corrColor, fontSize: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Layout escritorio/web
// ─────────────────────────────────────────────────────────
class _WideLayout extends ConsumerWidget {
  final List<RewardModel> rewards;
  final UserModel user;
  const _WideLayout({required this.rewards, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedRewardProvider);
    return Row(
      children: [
        Expanded(
          flex: 65,
          child: _RewardsGrid(
            rewards: rewards, user: user,
            selected: selected,
            onSelect: (r) =>
                ref.read(_selectedRewardProvider.notifier).state = r,
          ),
        ),
        Container(width: 1, color: AppColors.divider),
        Expanded(
          flex: 35,
          child: selected == null
              ? _EmptyDetailPanel()
              : _DetailContent(reward: selected, user: user, onClose: null),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Layout móvil
// ─────────────────────────────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  final List<RewardModel> rewards;
  final UserModel user;
  const _NarrowLayout({required this.rewards, required this.user});

  @override
  Widget build(BuildContext context) {
    return _RewardsGrid(
      rewards: rewards, user: user, selected: null,
      onSelect: (r) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _DetailSheet(reward: r, user: user),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Grid de recompensas
// ─────────────────────────────────────────────────────────
class _RewardsGrid extends StatelessWidget {
  final List<RewardModel> rewards;
  final UserModel user;
  final RewardModel? selected;
  final void Function(RewardModel) onSelect;

  const _RewardsGrid({
    required this.rewards,
    required this.user,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bronze = rewards.where((r) => r.tier == RewardTier.BRONZE).toList();
    final silver = rewards.where((r) => r.tier == RewardTier.SILVER).toList();
    final gold   = rewards.where((r) => r.tier == RewardTier.GOLD).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: _AmbientBanner()),
        _buildTierSliver(bronze, RewardTier.BRONZE),
        _buildTierSliver(silver, RewardTier.SILVER),
        _buildTierSliver(gold,   RewardTier.GOLD),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  SliverToBoxAdapter _buildTierSliver(List<RewardModel> items, RewardTier tier) {
    if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final color = _tierColor(tier);
    final name  = _tierName(tier);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 2, height: 14,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 8)],
                ),
              ),
              const SizedBox(width: 10),
              Text(name, style: GoogleFonts.shareTechMono(
                color: color, fontSize: 11,
                fontWeight: FontWeight.w700, letterSpacing: 3,
                shadows: [Shadow(color: color.withValues(alpha: 0.7), blurRadius: 10)],
              )),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.2))),
              const SizedBox(width: 8),
              Text('${items.length} ITEMS',
                style: GoogleFonts.shareTechMono(
                  color: AppColors.textSecondary, fontSize: 8, letterSpacing: 1,
                ),
              ),
            ]),
            const SizedBox(height: 10),
            LayoutBuilder(builder: (ctx, c) {
              final cols = c.maxWidth > 1200
                  ? 6
                  : c.maxWidth > 920
                      ? 5
                      : c.maxWidth > 680
                          ? 4
                          : c.maxWidth > 460
                              ? 3
                              : 2;
              final aspectRatio = c.maxWidth > 920
                  ? 1.18
                  : c.maxWidth > 680
                      ? 1.10
                      : 1.0;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (_, index) {
                  final r = items[index];
                  return RewardCard(
                    reward: r,
                    userBalance: user.gritBalance,
                    isSelected: selected?.id == r.id,
                    onTap: () => onSelect(r),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Banner ambiental decorativo
class _AmbientBanner extends StatelessWidget {
  const _AmbientBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(colors: [
          AppColors.neonGold.withValues(alpha: 0.05),
          AppColors.neonCyan.withValues(alpha: 0.03),
          const Color(0xFFAA00FF).withValues(alpha: 0.05),
        ]),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, color: AppColors.neonGold.withValues(alpha: 0.5), size: 13),
          const SizedBox(width: 8),
          Text('SELECCIONA UN ITEM PARA VER DETALLES',
            style: GoogleFonts.shareTechMono(
              color: AppColors.textSecondary, fontSize: 8, letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.auto_awesome, color: AppColors.neonGold.withValues(alpha: 0.5), size: 13),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// RewardCard — Fondo negro puro, borde + emoji neón
// ─────────────────────────────────────────────────────────
class RewardCard extends StatelessWidget {
  final RewardModel  reward;
  final int          userBalance;
  final bool         isSelected;
  final VoidCallback onTap;

  const RewardCard({
    super.key,
    required this.reward,
    required this.userBalance,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color       = _tierColor(reward.tier);
    final canAfford   = userBalance >= reward.currentCost;
    final isPurchased = reward.isPurchased;
    final emoji       = isPurchased ? '✅' : _rewardEmoji(reward);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          // ── FONDO: negro puro garantizado, SIN color del tier ──
          color: const Color(0xFF0A0A0C),
          borderRadius: BorderRadius.circular(8),
          // ── BORDE: único sitio permitido para el color del tier ──
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: isPurchased ? 0.30 : 1.0),
            width: isSelected ? 1.6 : 1.0,
          ),
          // ── GLOW: aura exterior, no rellena el interior ──────────
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isPurchased ? 0.10 : (isSelected ? 0.50 : 0.30)),
              blurRadius: isSelected ? 18 : 12,
              spreadRadius: isSelected ? 1.5 : 1,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Opacity(
          opacity: isPurchased ? 0.45 : 1.0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // ── Chips superiores ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tier badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: color.withValues(alpha: 0.70), width: 0.8),
                      ),
                      child: Text(
                        _tierName(reward.tier),
                        style: GoogleFonts.shareTechMono(
                          color: color,
                          fontSize: 6,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          shadows: [Shadow(
                            color: color,
                            blurRadius: 4,
                            offset: Offset.zero,
                          )],
                        ),
                      ),
                    ),
                    // Badge inflación
                    if (reward.weeklyPurchases > 0 && !isPurchased)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppColors.neonRed.withValues(alpha: 0.8),
                              width: 0.8),
                        ),
                        child: Text(
                          '↑${reward.inflationPercent}%',
                          style: TextStyle(
                            color: AppColors.neonRed,
                            fontSize: 6,
                            fontWeight: FontWeight.w800,
                            shadows: [Shadow(
                              color: AppColors.neonRed,
                              blurRadius: 4,
                              offset: Offset.zero,
                            )],
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),

                // ── Emoji holográfico central ───────────────────
                Expanded(
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize: 46,
                        shadows: isPurchased
                            ? []
                            : [
                                Shadow(
                                  color: color,
                                  blurRadius: 14,
                                  offset: Offset.zero,
                                ),
                              ],
                      ),
                    ),
                  ),
                ),

                // ── Divider ─────────────────────────────────────
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      color.withValues(alpha: 0.50),
                      Colors.transparent,
                    ]),
                  ),
                ),

                // ── Título ──────────────────────────────────────
                Flexible(
                  child: Text(
                    reward.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.shareTechMono(
                      color: isPurchased ? AppColors.textSecondary : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
                const SizedBox(height: 1),

                // ── Subtítulo tier ──────────────────────────────
                Text(
                  _tierName(reward.tier),
                  style: GoogleFonts.shareTechMono(
                    color: color.withValues(alpha: 0.60),
                    fontSize: 6,
                    letterSpacing: 1.0,
                    shadows: [Shadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 3,
                      offset: Offset.zero,
                    )],
                  ),
                ),
                const SizedBox(height: 2),

                // ── Precio ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isPurchased
                          ? color.withValues(alpha: 0.20)
                          : color.withValues(alpha: canAfford ? 0.75 : 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: isPurchased
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('CANJEADO',
                                style: GoogleFonts.shareTechMono(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  letterSpacing: 0.8,
                                )),
                            ],
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hexagon, size: 18,
                                  color: canAfford ? color : AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('${reward.currentCost}',
                                style: GoogleFonts.shareTechMono(
                                  color: canAfford ? color : AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  shadows: canAfford
                                      ? [Shadow(
                                          color: color,
                                          blurRadius: 8,
                                          offset: Offset.zero,
                                        )]
                                      : [],
                                )),
                              Text(' AURA',
                                style: GoogleFonts.shareTechMono(
                                  color: canAfford
                                      ? color.withValues(alpha: 0.75)
                                      : AppColors.textSecondary,
                                  fontSize: 14,
                                )),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Panel detalle vacío (web)
// ─────────────────────────────────────────────────────────
class _EmptyDetailPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined,
            color: AppColors.textSecondary.withValues(alpha: 0.25), size: 52),
          const SizedBox(height: 12),
          Text('SELECCIONA UN ITEM',
            style: GoogleFonts.shareTechMono(
              color: AppColors.textSecondary.withValues(alpha: 0.35),
              fontSize: 11, letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// BottomSheet de detalles (móvil)
// ─────────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final RewardModel reward;
  final UserModel   user;
  const _DetailSheet({required this.reward, required this.user});

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(reward.tier);
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, scroll) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: color.withValues(alpha: 0.6), width: 1.5),
          ),
          boxShadow: [BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 30, offset: const Offset(0, -4),
          )],
        ),
        child: SingleChildScrollView(
          controller: scroll,
          child: _DetailContent(
            reward: reward, user: user,
            onClose: () => Navigator.pop(ctx),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Contenido del panel de detalles — RPG Inspector
// ─────────────────────────────────────────────────────────
class _DetailContent extends ConsumerWidget {
  final RewardModel  reward;
  final UserModel    user;
  final VoidCallback? onClose;
  const _DetailContent({
    required this.reward,
    required this.user,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color       = _tierColor(reward.tier);
    final canAfford   = user.gritBalance >= reward.currentCost;
    final isPurchased = reward.isPurchased;
    final isGold      = reward.tier == RewardTier.GOLD;
    final emoji       = isPurchased ? '✅' : _rewardEmoji(reward);

    return Container(
      // ── REGLA 1: fondo azul marino casi negro ──────────────
      color: const Color(0xFF070B14),
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Drag handle (solo en bottom sheet) ─────────────
          if (onClose != null) ...[
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── REGLA 2: Emoji holograma gigante ───────────────
          Text(
            emoji,
            style: TextStyle(
              fontSize: 120,
              shadows: isPurchased ? [] : [
                Shadow(
                  color: color,
                  blurRadius: 20,
                  offset: Offset.zero,
                ),
                Shadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 60,
                  offset: Offset.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── REGLA 3: Título en blanco grande ───────────────
          Text(
            reward.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // ── Chip "INFLACIÓN ACTIVA" (solo si weeklyPurchases > 0) ──
          if (reward.weeklyPurchases > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.neonRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neonRed, width: 1.2),
                boxShadow: [BoxShadow(
                  color: AppColors.neonRed.withValues(alpha: 0.30),
                  blurRadius: 14,
                )],
              ),
              child: Text(
                '[ INFLACIÓN ACTIVA ]',
                style: GoogleFonts.shareTechMono(
                  color: AppColors.neonRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  shadows: [const Shadow(color: AppColors.neonRed, blurRadius: 8)],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ── REGLA 3: Badge tier tipo píldora ───────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 1.2),
              boxShadow: [BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 16,
              )],
            ),
            child: Text(
              _tierName(reward.tier),
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                shadows: [Shadow(color: color, blurRadius: 8)],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ── REGLA 4: Caja de lore con borde izquierdo ──────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border(
                left: BorderSide(color: color, width: 4),
              ),
            ),
            child: Text(
              reward.description,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 18,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ── REGLA 5: Advertencia GOLD ───────────────────────
          if (isGold) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.55), width: 1.5,
                ),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.redAccent, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '⚠️ ADVERTENCIA: Aumenta la Corrupción',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 30),
          ],

          // ── Fondos insuficientes ────────────────────────────
          if (!canAfford && !isPurchased) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neonRed.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.neonRed.withValues(alpha: 0.40)),
              ),
              child: Row(children: [
                const Icon(Icons.block, color: AppColors.neonRed, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'FONDOS INSUFICIENTES — FALTAN ${reward.currentCost - user.gritBalance} AURA',
                    style: GoogleFonts.shareTechMono(
                      color: AppColors.neonRed, fontSize: 13, letterSpacing: 0.8,
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
          ],

          // Empuja el botón abajo si hay espacio
          const Spacer(),

          // ── REGLA 6: CTA gigante ────────────────────────────
          _BigCtaButton(
            reward: reward, user: user,
            canAfford: canAfford, isPurchased: isPurchased,
            onClose: onClose, ref: ref,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// _BigCtaButton — CTA gigante para el panel de detalles
// ─────────────────────────────────────────────────────────
class _BigCtaButton extends StatelessWidget {
  final RewardModel  reward;
  final UserModel    user;
  final bool         canAfford;
  final bool         isPurchased;
  final VoidCallback? onClose;
  final WidgetRef    ref;

  const _BigCtaButton({
    required this.reward,
    required this.user,
    required this.canAfford,
    required this.isPurchased,
    required this.ref,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final color    = _tierColor(reward.tier);
    final disabled = isPurchased || !canAfford;

    if (isPurchased) {
      return Container(
        width: double.infinity, height: 70,
        decoration: BoxDecoration(
          color: Colors.greenAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.greenAccent.withValues(alpha: 0.40), width: 2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent, size: 24),
            SizedBox(width: 12),
            Text('INTERCAMBIO COMPLETADO',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2,
              )),
          ],
        ),
      );
    }

    return InkWell(
      onTap: disabled ? null : () => _confirmPurchase(context),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity, height: 70,
        decoration: BoxDecoration(
          color: disabled
              ? Colors.grey.withValues(alpha: 0.08)
              : color.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: disabled ? Colors.grey.withValues(alpha: 0.30) : color,
            width: 2,
          ),
          boxShadow: disabled ? [] : [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 20, spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              disabled ? Icons.lock_outline : Icons.bolt,
              color: disabled ? Colors.grey : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
              Flexible(
                child: Text(
                  disabled
                      ? '[ FONDOS INSUFICIENTES ]'
                      : 'CANJEAR · ${reward.currentCost} AURA',
                  style: TextStyle(
                    color: disabled ? Colors.grey : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0,
                    shadows: disabled ? [] : [
                      Shadow(color: color, blurRadius: 12, offset: Offset.zero),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmPurchase(BuildContext context) async {
    final color = _tierColor(reward.tier);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.warning_amber_rounded, color: color, size: 18),
                const SizedBox(width: 10),
                Text('CONFIRMAR CANJE',
                  style: GoogleFonts.shareTechMono(
                    color: color, fontSize: 14, fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    shadows: [Shadow(
                        color: color.withValues(alpha: 0.8), blurRadius: 10)],
                  )),
              ]),
              const SizedBox(height: 14),
              Text(reward.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13, fontWeight: FontWeight.w700,
                )),
              const SizedBox(height: 4),
              Text(reward.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11, height: 1.4,
                )),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.neonGold.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.neonGold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('COSTE:', style: GoogleFonts.shareTechMono(
                      color: AppColors.textSecondary, fontSize: 11,
                    )),
                    Row(children: [
                      const Icon(Icons.hexagon,
                          color: AppColors.neonGold, size: 13),
                      const SizedBox(width: 4),
                      Text('${reward.currentCost} AURA',
                        style: GoogleFonts.shareTechMono(
                          color: AppColors.neonGold, fontSize: 13,
                          fontWeight: FontWeight.w700,
                        )),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'SALDO RESTANTE: ${user.gritBalance - reward.currentCost} AURA',
                style: GoogleFonts.shareTechMono(
                  color: AppColors.textSecondary, fontSize: 8,
                ),
              ),
              if (reward.tier == RewardTier.GOLD) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.neonRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppColors.neonRed.withValues(alpha: 0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.neonRed, size: 14),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '⚠️ ADVERTENCIA: Aumentará tu nivel de corrupción.',
                        style: TextStyle(
                          color: AppColors.neonRed,
                          fontSize: 11, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('ABORTAR',
                      style: GoogleFonts.shareTechMono(
                        color: AppColors.textSecondary,
                        fontSize: 11, letterSpacing: 1,
                      )),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.neonCyan),
                        boxShadow: [BoxShadow(
                          color: AppColors.neonCyan.withValues(alpha: 0.28),
                          blurRadius: 14,
                        )],
                      ),
                      child: Text('[ CONFIRMAR ]',
                        style: GoogleFonts.shareTechMono(
                          color: AppColors.neonCyan, fontSize: 11,
                          fontWeight: FontWeight.w700, letterSpacing: 1,
                          shadows: [Shadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.9),
                            blurRadius: 8,
                          )],
                        )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(rewardsProvider.notifier).buyReward(reward);
      AudioService.instance.playSuccess();
      onClose?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: _tierColor(reward.tier), width: 1),
          ),
          content: Row(children: [
            const Icon(Icons.check_circle, color: AppColors.neonCyan, size: 15),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '[SISTEMA]: Intercambio completado — ${reward.title}',
                style: GoogleFonts.shareTechMono(
                  color: AppColors.textPrimary, fontSize: 11,
                ),
              ),
            ),
          ]),
          duration: const Duration(seconds: 3),
        ));
      }
    }
  }
}

// ─────────────────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────────────────
