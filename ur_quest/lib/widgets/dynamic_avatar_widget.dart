import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DynamicAvatarWidget extends StatefulWidget {
  final Map<String, int> attributes;
  final int level;
  final double size;
  final String? rankLabel;
  final String? buildLabel;

  const DynamicAvatarWidget({
    super.key,
    required this.attributes,
    required this.level,
    this.size = 220,
    this.rankLabel,
    this.buildLabel,
  });

  static const _defaultColor = AppColors.neonCyan;

  @override
  State<DynamicAvatarWidget> createState() => _DynamicAvatarWidgetState();
}

class _DynamicAvatarWidgetState extends State<DynamicAvatarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dominantStat = _dominantStat(widget.attributes);
    final auraColor = _auraColorForStat(dominantStat);
    final size = widget.size;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final pulseValue = 0.88 + (_pulse.value * 0.24);
        final pulseGlow = 0.20 + (_pulse.value * 0.22);

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1320),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.45),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.10),
                      blurRadius: 24,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: auraColor.withValues(alpha: 0.10 + (_pulse.value * 0.08)),
                      blurRadius: 30,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              Container(
                width: size * 0.88,
                height: size * 0.88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: auraColor.withValues(alpha: 0.14 + (_pulse.value * 0.10)),
                    width: 1,
                  ),
                ),
              ),
              Transform.scale(
                scale: pulseValue,
                child: Container(
                  width: size * 0.68,
                  height: size * 0.68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: auraColor.withValues(alpha: 0.24 + pulseGlow),
                        blurRadius: 42 + (_pulse.value * 12),
                        spreadRadius: 10 + (_pulse.value * 4),
                      ),
                      BoxShadow(
                        color: auraColor.withValues(alpha: 0.12 + (_pulse.value * 0.12)),
                        blurRadius: 74 + (_pulse.value * 12),
                        spreadRadius: 18 + (_pulse.value * 6),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 22,
                right: 28,
                child: Opacity(
                  opacity: 0.24 + (_pulse.value * 0.26),
                  child: Icon(
                    Icons.auto_awesome,
                    color: auraColor,
                    size: 16,
                  ),
                ),
              ),
              if (widget.rankLabel != null)
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: auraColor.withValues(alpha: 0.45)),
                      boxShadow: [
                        BoxShadow(
                          color: auraColor.withValues(alpha: 0.18),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.rankLabel!,
                      style: TextStyle(
                        color: auraColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              Icon(
                Icons.person_outline_rounded,
                size: size * 0.62,
                color: const Color(0xFFD9E1EA),
                shadows: [
                  Shadow(
                    color: Colors.white.withValues(alpha: 0.16),
                    blurRadius: 18,
                  ),
                ],
              ),
              if (widget.level > 50)
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: auraColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: auraColor.withValues(alpha: 0.35)),
                    ),
                    child: const Text(
                      'FX SLOT',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: auraColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    widget.buildLabel == null ? dominantStat : '$dominantStat · ${widget.buildLabel!}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _dominantStat(Map<String, int> attributes) {
    if (attributes.isEmpty) return 'INT';
    final sorted = attributes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  static Color _auraColorForStat(String stat) {
    switch (stat) {
      case 'VIT':
        return AppColors.attrVit;
      case 'INT':
        return AppColors.neonBlue;
      case 'LOG':
        return AppColors.attrCrea;
      case 'ESP':
        return AppColors.attrEsp;
      case 'SOC':
        return AppColors.attrSoc;
      case 'CREA':
        return AppColors.attrCrea;
      default:
        return DynamicAvatarWidget._defaultColor;
    }
  }
}

