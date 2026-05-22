import 'package:flutter/material.dart';
import '../../models/mission_model.dart';
import '../../theme/app_theme.dart';

/// Tarjeta de misión estilo HUD con borde neón
class MissionCard extends StatelessWidget {
  final MissionModel mission;
  final VoidCallback? onComplete;

  const MissionCard({
    super.key,
    required this.mission,
    this.onComplete,
  });

  Color get _rankColor {
    switch (mission.rank) {
      case MissionRank.S: return const Color(0xFFFFD700);
      case MissionRank.A: return const Color(0xFFFF6D00);
      case MissionRank.B: return const Color(0xFF00E5FF);
      case MissionRank.C: return const Color(0xFF8899A6);
    }
  }

  Color get _attrColor {
    const map = {
      'INT':  AppColors.attrInt,
      'LOG':  AppColors.attrLog,
      'CREA': AppColors.attrCrea,
      'ESP':  AppColors.attrEsp,
      'VIT':  AppColors.attrVit,
      'SOC':  AppColors.attrSoc,
    };
    return map[mission.attribute] ?? AppColors.neonCyan;
  }

  bool get _isDone => mission.status == MissionStatus.completed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isDone ? 0.45 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isDone
                ? AppColors.divider
                : _rankColor.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: _isDone
              ? []
              : [
                  BoxShadow(
                    color: _rankColor.withOpacity(0.12),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Indicador de rango
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _rankColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _rankColor.withOpacity(0.5)),
                ),
                alignment: Alignment.center,
                child: Text(
                  mission.rank.name,
                  style: TextStyle(
                    color: _rankColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Título y descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: TextStyle(
                        color: _isDone ? AppColors.textSecondary : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: _isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mission.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Grit reward
                        _Chip(
                          icon: Icons.hexagon_outlined,
                          color: AppColors.neonGold,
                          label: '+${mission.gritReward} \$ASH',
                        ),
                        const SizedBox(width: 6),
                        // Atributo
                        _Chip(
                          icon: Icons.bolt,
                          color: _attrColor,
                          label: mission.attribute,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Botón completar
              if (_isDone)
                const Icon(Icons.check_circle,
                    color: AppColors.neonCyan, size: 28)
              else
                _CompleteButton(onTap: onComplete, color: _rankColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   label;
  const _Chip({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          )),
        ],
      ),
    );
  }
}

class _CompleteButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color color;
  const _CompleteButton({required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          'DONE',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}


