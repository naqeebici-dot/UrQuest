import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mission_model.dart';
import '../models/reward_model.dart';
import '../providers/game_providers.dart';
import '../services/regex_dictionary_service.dart';
import '../theme/app_theme.dart';

/// Diálogo modal para crear misiones o recompensas personalizadas (UGC)
class CreateEntryDialog extends ConsumerStatefulWidget {
  final EntryMode mode;
  const CreateEntryDialog({super.key, required this.mode});

  @override
  ConsumerState<CreateEntryDialog> createState() => _CreateEntryDialogState();
}

class _CreateEntryDialogState extends ConsumerState<CreateEntryDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  Timer? _debounce;
  EvaluationResult _eval = EvaluationResult.empty;
  bool _saving = false;
  bool _isDailyMission = true;
  DateTime? _selectedDueDate;

  bool get _isMission => widget.mode == EntryMode.mission;
  Color get _accentColor => _isMission ? AppColors.neonCyan : AppColors.neonGold;

  @override
  void dispose() {
    _debounce?.cancel();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final combined = [_titleCtrl.text.trim(), _descCtrl.text.trim()]
          .where((e) => e.isNotEmpty)
          .join(' ');
      setState(() => _eval = SystemParserService.evaluate(combined, mode: widget.mode));
    });
  }

  Color _attrColor(String? attr) {
    const map = {
      'INT': AppColors.attrInt, 'LOG': AppColors.attrLog, 'CREA': AppColors.attrCrea,
      'ESP': AppColors.attrEsp, 'VIT': AppColors.attrVit, 'SOC': AppColors.attrSoc,
    };
    return map[attr] ?? AppColors.textSecondary;
  }

  Color _tierColor(RewardTier tier) {
    switch (tier) {
      case RewardTier.BRONZE: return const Color(0xFFCD7F32);
      case RewardTier.SILVER: return const Color(0xFF00E5FF);
      case RewardTier.GOLD:   return const Color(0xFFFFD700);
    }
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? firstDate.add(const Duration(days: 1)),
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: _accentColor,
            surface: AppColors.surface,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _onCreate() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _saving) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_isMission && !_isDailyMission && _selectedDueDate == null) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.neonRed,
          behavior: SnackBarBehavior.floating,
          content: Text(
            '[SISTEMA]: Selecciona una fecha límite para la misión.',
            style: GoogleFonts.shareTechMono(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      Future<void> saveFuture;

      if (_isMission) {
        final aura = _eval.suggestedReward ?? 20;
        final mission = MissionModel(
          id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          description: _descCtrl.text.trim().isNotEmpty
              ? _descCtrl.text.trim()
              : 'Misión personalizada del jugador.',
          rank: MissionRank.C,
          type: _isDailyMission ? MissionType.daily : MissionType.secondary,
          isDaily: _isDailyMission,
          dueDate: _isDailyMission ? null : _selectedDueDate,
          gritReward: aura,
          xpReward: (aura ~/ 2) + 5,
          attribute: _eval.detectedAttribute ?? 'INT',
        );
        saveFuture = ref.read(dailyMissionsProvider.notifier).createMission(mission);
      } else {
        final cost = _eval.suggestedCost ?? 150;
        final reward = RewardModel(
          id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          description: _descCtrl.text.trim().isNotEmpty
              ? _descCtrl.text.trim()
              : 'Recompensa personalizada del jugador.',
          tier: _eval.detectedTier ?? RewardTier.BRONZE,
          baseCost: cost,
          currentCost: cost,
          weeklyPurchases: 0,
          emoji: _eval.suggestedEmoji ?? '✨',
        );
        saveFuture = ref.read(rewardsProvider.notifier).createReward(reward);
      }

      if (!mounted) return;

      unawaited(saveFuture);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          content: Text(
            '[SISTEMA]: Sistema actualizado',
            style: GoogleFonts.shareTechMono(color: AppColors.textPrimary),
          ),
        ),
      );
      return;
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.neonRed,
          behavior: SnackBarBehavior.floating,
          content: Text(
            '[SISTEMA]: Error al guardar',
            style: GoogleFonts.shareTechMono(color: Colors.white),
          ),
        ),
      );
    }

    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _accentColor, width: 1.5),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: _accentColor.withValues(alpha: 0.20), blurRadius: 30, spreadRadius: 2)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header tipo terminal ───────────────────────────
            Text(
              '> NEW ${_isMission ? "MISSION" : "REWARD"}_',
              style: GoogleFonts.shareTechMono(
                color: _accentColor, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2,
                shadows: [Shadow(color: _accentColor, blurRadius: 10)],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isMission ? 'Define una misión y el sistema calculará la recompensa.' : 'Define una recompensa y el sistema asignará el coste.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 20),

            // ── TextField: Título ─────────────────────────────
            TextField(
              controller: _titleCtrl,
              onChanged: _onTextChanged,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: _isMission ? 'Ej: Correr 5km, Leer 30 páginas...' : 'Ej: Pizza, Netflix, Fiesta...',
                hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.background,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _accentColor.withValues(alpha: 0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _accentColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // ── TextField: Descripción (opcional) ─────────────
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              onChanged: _onTextChanged,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Descripción (opcional)',
                hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.background,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _accentColor.withValues(alpha: 0.6)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            if (_isMission) ...[
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _accentColor.withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      value: _isDailyMission,
                      activeThumbColor: Colors.black,
                      activeTrackColor: _accentColor,
                      title: Text(
                        'Misión Diaria',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        _isDailyMission
                            ? 'Se mostrará en el bloque DAILY QUESTS.'
                            : 'Pasa a contrato con fecha límite manual.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isDailyMission = value;
                          if (value) _selectedDueDate = null;
                        });
                      },
                    ),
                    if (!_isDailyMission)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: InkWell(
                          onTap: _pickDueDate,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: _accentColor.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _accentColor.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.event, color: _accentColor, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _selectedDueDate == null
                                        ? 'Seleccionar fecha límite'
                                        : 'Fecha límite: ${_formatDate(_selectedDueDate!)}',
                                    style: GoogleFonts.shareTechMono(
                                      color: _selectedDueDate == null
                                          ? AppColors.textSecondary
                                          : _accentColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: _accentColor.withValues(alpha: 0.8)),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // ── Preview en tiempo real ────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accentColor.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.hexagon, color: _accentColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _isMission ? 'AURA SUGERIDA: ${_eval.suggestedReward ?? "—"}' : 'COSTE SUGERIDO: ${_eval.suggestedCost ?? "—"}',
                      style: GoogleFonts.shareTechMono(
                        color: _accentColor, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1,
                        shadows: [Shadow(color: _accentColor.withValues(alpha: 0.6), blurRadius: 8)],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  if (_isMission)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.radar, color: _attrColor(_eval.detectedAttribute), size: 14),
                          const SizedBox(width: 8),
                          Text(
                            'ATRIBUTO: ${_eval.detectedAttribute ?? "—"}',
                            style: GoogleFonts.shareTechMono(color: _attrColor(_eval.detectedAttribute), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          Icon(
                            _isDailyMission ? Icons.autorenew : Icons.event_available,
                            color: _accentColor.withValues(alpha: 0.85),
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isDailyMission
                                ? 'CADENCIA: DAILY QUEST'
                                : 'VENCE: ${_selectedDueDate != null ? _formatDate(_selectedDueDate!) : "—"}',
                            style: GoogleFonts.shareTechMono(
                              color: _accentColor.withValues(alpha: 0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]),
                      ],
                    )
                  else
                    Row(children: [
                      Icon(Icons.star, color: _eval.detectedTier != null ? _tierColor(_eval.detectedTier!) : AppColors.textSecondary, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'TIER: ${_eval.detectedTier?.name ?? "—"}',
                        style: GoogleFonts.shareTechMono(
                          color: _eval.detectedTier != null ? _tierColor(_eval.detectedTier!) : AppColors.textSecondary,
                          fontSize: 12, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                  const SizedBox(height: 10),
                  if (_eval.matchedKeywords.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _eval.matchedKeywords.map((kw) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _accentColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(kw, style: GoogleFonts.shareTechMono(color: _accentColor, fontSize: 10, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Botones ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('[ ABORTAR ]', style: GoogleFonts.shareTechMono(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1)),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _titleCtrl.text.trim().isNotEmpty && !_saving ? () => _onCreate() : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _accentColor),
                      boxShadow: [BoxShadow(color: _accentColor.withValues(alpha: 0.25), blurRadius: 12)],
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(_accentColor),
                            ),
                          )
                        : Text(
                            '[ CREAR ]',
                            style: GoogleFonts.shareTechMono(
                              color: _accentColor, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1,
                              shadows: [Shadow(color: _accentColor.withValues(alpha: 0.8), blurRadius: 8)],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

