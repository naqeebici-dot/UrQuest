import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mission_model.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────
// Meta-datos por atributo
// ─────────────────────────────────────────────────────────
const _attrMeta = {
  'VIT':  _AttrMeta('VITALIDAD',      AppColors.attrVit,  '💪'),
  'INT':  _AttrMeta('INTELECTO',      AppColors.attrInt,  '📚'),
  'LOG':  _AttrMeta('LÓGICA',         AppColors.attrLog,  '🧠'),
  'ESP':  _AttrMeta('ESPIRITUALIDAD', AppColors.attrEsp,  '🧘'),
  'CREA': _AttrMeta('CREATIVIDAD',    AppColors.attrCrea, '🎨'),
  'SOC':  _AttrMeta('SOCIAL',         AppColors.attrSoc,  '🤝'),
};

const _attrLore = {
  'VIT': 'Incrementa la resistencia a la fatiga física y el HP máximo.',
  'INT': 'Aumenta la velocidad de procesamiento cognitivo y la retención de datos.',
  'LOG': 'Mejora el pensamiento crítico, el orden y la resolución de problemas.',
  'ESP': 'Fortalece la voluntad, la resistencia a la corrupción y la paz mental.',
  'SOC': 'Expande la red de influencia y las habilidades diplomáticas.',
  'CREA': 'Canaliza ideas en prototipos, piezas artísticas y soluciones originales.',
};

enum QuestCardVariant { daily, longTerm }

class _AttrMeta {
  final String label;
  final Color  color;
  final String emoji;
  const _AttrMeta(this.label, this.color, this.emoji);
}

// ─────────────────────────────────────────────────────────
// SystemQuestCard
// ─────────────────────────────────────────────────────────
class SystemQuestCard extends StatefulWidget {
  final String             attribute;
  final List<MissionModel> missions;
  final Future<void> Function(String missionId) onComplete;
  final QuestCardVariant variant;

  const SystemQuestCard({
    super.key,
    required this.attribute,
    required this.missions,
    required this.onComplete,
    this.variant = QuestCardVariant.daily,
  });

  @override
  State<SystemQuestCard> createState() => _SystemQuestCardState();
}

class _SystemQuestCardState extends State<SystemQuestCard>
    with SingleTickerProviderStateMixin {
  final Set<String> _localCompleted = {};
  final Set<String> _loading        = {};

  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool _isCompleted(MissionModel m) =>
      m.status == MissionStatus.completed || _localCompleted.contains(m.id);

  Future<void> _completeMission(MissionModel m) async {
    if (_isCompleted(m) || _loading.contains(m.id)) return;
    setState(() => _localCompleted.add(m.id));
    AudioService.instance.playSuccess();
    await widget.onComplete(m.id);
  }

  /// Abre un Dialog holográfico con la carta expandida al 80%
  void _openInspectionDialog(BuildContext context) {
    final meta  = _attrMeta[widget.attribute]
        ?? const _AttrMeta('SISTEMA', AppColors.neonCyan, '⚡');
    final color = meta.color;
    final frameColor = widget.variant == QuestCardVariant.longTerm
        ? const Color(0xFFB388FF)
        : Colors.cyanAccent;
    final total     = widget.missions.length;
    final completed = widget.missions.where(_isCompleted).length;
    final allDone   = completed == total;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: MediaQuery.of(ctx).size.width * 0.9,
          height: MediaQuery.of(ctx).size.height * 0.80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.variant == QuestCardVariant.longTerm
                  ? const [Color(0xFF19112A), Color(0xFF05030B)]
                  : const [Color(0xFF0F172A), Color(0xFF020617)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: frameColor.withValues(alpha: 0.75),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: frameColor.withValues(alpha: 0.30),
                blurRadius: 50,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.30),
                blurRadius: 60,
                spreadRadius: 5,
              ),
              if (widget.variant == QuestCardVariant.longTerm)
                BoxShadow(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.16),
                  blurRadius: 44,
                  spreadRadius: 2,
                ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              // Botón de cerrar
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.redAccent, width: 1.5),
                    ),
                    child: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Cabecera
              _buildHeader(meta),
              const SizedBox(height: 8),
              Text(
                widget.variant == QuestCardVariant.longTerm
                    ? 'LONG-TERM QUEST  ·  ${meta.label} OPERATION'
                    : 'DAILY QUEST  ·  ${meta.label} TRAINING',
                textAlign: TextAlign.center,
                style: GoogleFonts.shareTechMono(
                  color: Colors.grey[400],
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatAnalysis(meta, frameColor),
              const SizedBox(height: 16),
              _buildProgressBar(completed, total, color),
              const SizedBox(height: 20),
              _buildGoalsSeparator(),
              // Misiones con scroll
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.missions.length,
                  itemBuilder: (_, i) {
                    final m = widget.missions[i];
                    return _MissionRow(
                      mission:     m,
                      isCompleted: _isCompleted(m),
                      isLoading:   _loading.contains(m.id),
                      accentColor: color,
                      onTap:       () {
                        _completeMission(m);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
              // Footer
              _buildFooter(allDone),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta  = _attrMeta[widget.attribute]
        ?? const _AttrMeta('SISTEMA', AppColors.neonCyan, '⚡');
    final color = meta.color;
    final frameColor = widget.variant == QuestCardVariant.longTerm
        ? const Color(0xFFB388FF)
        : Colors.cyanAccent;

    final total     = widget.missions.length;
    final completed = widget.missions.where(_isCompleted).length;
    final allDone   = completed == total;

    return GestureDetector(
      onLongPress: () => _openInspectionDialog(context),
      onDoubleTap: () => _openInspectionDialog(context),
      child: Container(
        // ── REGLA 2: degradado azul oscuro exacto ─────────────
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.variant == QuestCardVariant.longTerm
                ? const [Color(0xFF181126), Color(0xFF05030A)]
                : const [Color(0xFF0F172A), Color(0xFF020617)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: frameColor.withValues(alpha: allDone ? 0.85 : 0.55),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: frameColor.withValues(alpha: allDone ? 0.25 : 0.15),
              blurRadius: 30,
              spreadRadius: 5,
            ),
            if (allDone)
              BoxShadow(
                color: color.withValues(alpha: 0.28),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            if (widget.variant == QuestCardVariant.longTerm)
              BoxShadow(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.10),
                blurRadius: 28,
                spreadRadius: 1,
              ),
          ],
        ),
        // ── REGLA 3: padding generoso ─────────────────────────
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── CABECERA ─────────────────────────────────────
            _buildHeader(meta),
            const SizedBox(height: 8),

            // ── SUBTÍTULO (fontSize 14) ───────────────────────
            Text(
              widget.variant == QuestCardVariant.longTerm
                  ? 'LONG-TERM QUEST  ·  ${meta.label} OPERATION'
                  : 'DAILY QUEST  ·  ${meta.label} TRAINING',
              textAlign: TextAlign.center,
              style: GoogleFonts.shareTechMono(
                color: Colors.grey[400],
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // ── Barra de progreso ────────────────────────────
            _buildProgressBar(completed, total, color),
            const SizedBox(height: 20),

            // ── GOALS (fontSize 18) ───────────────────────────
            _buildGoalsSeparator(),

            // ── MISIONES con scroll interno (ANTI-OVERFLOW) ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                physics: const BouncingScrollPhysics(),
                itemCount: widget.missions.length,
                itemBuilder: (_, i) {
                  final m = widget.missions[i];
                  return _MissionRow(
                    mission:     m,
                    isCompleted: _isCompleted(m),
                    isLoading:   _loading.contains(m.id),
                    accentColor: color,
                    onTap:       () => _completeMission(m),
                  );
                },
              ),
            ),

            // ── FOOTER CAUTION (fontSize 18) ──────────────────
            _buildFooter(allDone),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(_AttrMeta meta) {
    final frameColor = widget.variant == QuestCardVariant.longTerm
        ? const Color(0xFFB388FF)
        : Colors.cyanAccent;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) => Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: frameColor.withValues(alpha: _pulse.value),
                width: 1.8,
              ),
              boxShadow: [BoxShadow(
                color: frameColor.withValues(alpha: _pulse.value * 0.5),
                blurRadius: 16,
              )],
            ),
            child: Center(
              child: Text('!',
                style: GoogleFonts.shareTechMono(
                  color: frameColor.withValues(alpha: _pulse.value),
                  fontSize: 18, fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'QUEST INFO',
          style: GoogleFonts.shareTechMono(
            color: frameColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            shadows: [
              Shadow(color: frameColor, blurRadius: 18),
              Shadow(color: frameColor, blurRadius: 40),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(meta.emoji, style: TextStyle(
          fontSize: 24,
          shadows: [Shadow(
            color: meta.color, blurRadius: 20, offset: Offset.zero,
          )],
        )),
      ],
    );
  }

  Widget _buildStatAnalysis(_AttrMeta meta, Color frameColor) {
    final lore = _attrLore[widget.attribute] ?? 'Sin telemetría adicional disponible para esta clase.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: frameColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[ STAT ANALYSIS ]',
            style: GoogleFonts.shareTechMono(
              color: frameColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              shadows: [Shadow(color: frameColor.withValues(alpha: 0.7), blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meta.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lore,
                  style: TextStyle(
                    color: Colors.grey[350],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int completed, int total, Color color) {
    final pct = total == 0 ? 0.0 : completed / total;
    return Row(children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: const Color(0xFF1E2D40),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text('$completed / $total',
        style: GoogleFonts.shareTechMono(
          color: color, fontSize: 12,
          shadows: [Shadow(color: color, blurRadius: 8, offset: Offset.zero)],
        )),
    ]);
  }

  Widget _buildGoalsSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(child: Container(
          height: 0.8,
          color: Colors.greenAccent.withValues(alpha: 0.30),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('GOALS',
            style: GoogleFonts.shareTechMono(
              color: Colors.greenAccent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 4.0,
              shadows: const [
                Shadow(color: Colors.greenAccent, blurRadius: 14, offset: Offset.zero),
                Shadow(color: Colors.greenAccent, blurRadius: 32, offset: Offset.zero),
              ],
            ),
          ),
        ),
        Expanded(child: Container(
          height: 0.8,
          color: Colors.greenAccent.withValues(alpha: 0.30),
        )),
      ]),
    );
  }

  Widget _buildFooter(bool allDone) {
    final isLongTerm = widget.variant == QuestCardVariant.longTerm;

    return Column(children: [
      Divider(color: Colors.cyanAccent.withValues(alpha: 0.12), height: 24),
      if (allDone) ...[
        Text(isLongTerm ? '✦  CONTRACT COMPLETE  ✦' : '✦  QUEST COMPLETE  ✦',
          style: GoogleFonts.shareTechMono(
            color: Colors.greenAccent,
            fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 3,
            shadows: const [
              Shadow(color: Colors.greenAccent, blurRadius: 20),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(isLongTerm ? 'DEADLINE SECURED' : 'PENALTY AVOIDED',
          style: GoogleFonts.shareTechMono(
            color: Colors.greenAccent.withValues(alpha: 0.50),
            fontSize: 12, letterSpacing: 2,
          )),
      ] else ...[
        Text('CAUTION!',
          style: GoogleFonts.shareTechMono(
            color: Colors.redAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: const [
              Shadow(color: Colors.redAccent, blurRadius: 16, offset: Offset.zero),
              Shadow(color: Colors.redAccent, blurRadius: 32, offset: Offset.zero),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isLongTerm
              ? 'IF THE LONG-TERM CONTRACT MISSES ITS DEADLINE,\nSYSTEM PENALTIES WILL SCALE WITH DELAY.'
              : 'IF THE DAILY QUEST REMAINS INCOMPLETE,\nPENALTIES WILL BE GIVEN ACCORDINGLY.',
          textAlign: TextAlign.center,
          style: GoogleFonts.shareTechMono(
            color: Colors.grey[500],
            fontSize: 12,
            height: 1.6,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) => Icon(
            Icons.hourglass_bottom_rounded,
            size: 24,
            color: Colors.redAccent.withValues(alpha: _pulse.value),
            shadows: [Shadow(
              color: Colors.redAccent.withValues(alpha: _pulse.value * 0.8),
              blurRadius: 18, offset: Offset.zero,
            )],
          ),
        ),
      ],
    ]);
  }
}

// ─────────────────────────────────────────────────────────
// _MissionRow
// ─────────────────────────────────────────────────────────
class _MissionRow extends StatelessWidget {
  final MissionModel mission;
  final bool         isCompleted;
  final bool         isLoading;
  final Color        accentColor;
  final VoidCallback onTap;

  const _MissionRow({
    required this.mission,
    required this.isCompleted,
    required this.isLoading,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = mission.dueDate == null
        ? null
        : '${mission.dueDate!.day.toString().padLeft(2, '0')}/${mission.dueDate!.month.toString().padLeft(2, '0')}';

    return Column(children: [
      InkWell(
        onTap: isCompleted ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: accentColor.withValues(alpha: 0.10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isCompleted
                ? Colors.greenAccent.withValues(alpha: 0.04)
                : Colors.transparent,
            border: isCompleted
                ? Border.all(
                    color: Colors.greenAccent.withValues(alpha: 0.18),
                    width: 0.8)
                : null,
          ),
          child: Row(children: [
            // Barra lateral
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              width: 3, height: 26,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isCompleted
                    ? Colors.greenAccent
                    : accentColor.withValues(alpha: 0.45),
                boxShadow: isCompleted
                    ? [const BoxShadow(color: Colors.greenAccent, blurRadius: 8)]
                    : [],
              ),
            ),
            // Título (fontSize 16, blanco)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '— ${mission.title.toUpperCase()}',
                    style: GoogleFonts.shareTechMono(
                      color: isCompleted
                          ? Colors.greenAccent.withValues(alpha: 0.50)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Colors.greenAccent.withValues(alpha: 0.50),
                      decorationThickness: 1.5,
                    ),
                ),
                  if (mission.isDaily || dateLabel != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _MissionMetaChip(
                          label: mission.isDaily ? 'DAILY' : 'LONG-TERM',
                          color: mission.isDaily ? accentColor : const Color(0xFFB388FF),
                        ),
                        if (dateLabel != null)
                          _MissionMetaChip(
                            label: 'DUE $dateLabel',
                            color: const Color(0xFFFFD54F),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            // [ 0/1 ] o [ 1/1 ] (fontSize 16, bold)
            if (isLoading)
              SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation(accentColor),
                ),
              )
            else
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 320),
                style: GoogleFonts.shareTechMono(
                  color: isCompleted ? Colors.greenAccent : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: isCompleted
                      ? const [Shadow(
                          color: Colors.greenAccent,
                          blurRadius: 12,
                          offset: Offset.zero,
                        )]
                      : [],
                ),
                child: Text(isCompleted ? '[ 1 / 1 ]' : '[ 0 / 1 ]'),
              ),
          ]),
        ),
      ),
      // Espaciado entre filas (SizedBox 16)
      const SizedBox(height: 16),
    ]);
  }
}

class _MissionMetaChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MissionMetaChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.shareTechMono(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

