import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Radar chart hexagonal para los 6 atributos del jugador
class HexRadarChart extends StatelessWidget {
  /// Mapa de atributo → valor (0–100)
  final Map<String, int> attributes;
  final double size;

  const HexRadarChart({
    super.key,
    required this.attributes,
    this.size = 200,
  });

  static const _labels = ['INT', 'LOG', 'CREA', 'ESP', 'VIT', 'SOC'];
  static const _colors = [
    AppColors.attrInt,
    AppColors.attrLog,
    AppColors.attrCrea,
    AppColors.attrEsp,
    AppColors.attrVit,
    AppColors.attrSoc,
  ];

  @override
  Widget build(BuildContext context) {
    final values = _labels.map((l) => (attributes[l] ?? 0) / 100.0).toList();

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexPainter(values: values, labels: _labels, colors: _colors),
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final List<Color>  colors;

  _HexPainter({
    required this.values,
    required this.labels,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = (size.width / 2) * 0.65;

    // ── Fondo hexagonal (capas) ──
    for (int ring = 1; ring <= 4; ring++) {
      final fraction = ring / 4;
      final r = maxR * fraction;
      final path = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (pi / 3) * i - pi / 2;
        final x = cx + r * cos(angle);
        final y = cy + r * sin(angle);
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path.close();

      // Relleno sutil para los anillos internos
      if (ring == 4) {
        final bgPaint = Paint()
          ..color = AppColors.neonCyan.withOpacity(0.03)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, bgPaint);
      }

      final gridPaint = Paint()
        ..color = AppColors.divider.withOpacity(0.4 + fraction * 0.4)
        ..strokeWidth = 0.6
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, gridPaint);
    }

    // ── Ejes ──
    final axisPaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.1)
      ..strokeWidth = 0.8;
    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 2;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + maxR * cos(angle), cy + maxR * sin(angle)),
        axisPaint,
      );
    }

    // ── Área del jugador: glow exterior ──
    final valuePoints = <Offset>[];
    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 2;
      final r = maxR * values[i];
      valuePoints.add(Offset(cx + r * cos(angle), cy + r * sin(angle)));
    }
    final valuePath = Path()..moveTo(valuePoints[0].dx, valuePoints[0].dy);
    for (int i = 1; i < 6; i++) {
      valuePath.lineTo(valuePoints[i].dx, valuePoints[i].dy);
    }
    valuePath.close();

    // Glow exterior suave
    final glowPaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(valuePath, glowPaint);

    // Relleno principal
    final fillPaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.22)
      ..style = PaintingStyle.fill;
    canvas.drawPath(valuePath, fillPaint);

    // Borde con glow
    final glowStroke = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.5)
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..style = PaintingStyle.stroke;
    canvas.drawPath(valuePath, glowStroke);

    final strokePaint = Paint()
      ..color = AppColors.neonCyan
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(valuePath, strokePaint);

    // ── Puntos de vértice con glow por color ──
    for (int i = 0; i < 6; i++) {
      final glowDot = Paint()
        ..color = colors[i].withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(valuePoints[i], 6, glowDot);

      final dotPaint = Paint()..color = colors[i];
      canvas.drawCircle(valuePoints[i], 3.5, dotPaint);

      // Punto central brillante
      final centerDot = Paint()..color = Colors.white.withOpacity(0.8);
      canvas.drawCircle(valuePoints[i], 1.2, centerDot);
    }

    // ── Etiquetas con glow ──
    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 2;
      final labelR = maxR + 20;
      final lx = cx + labelR * cos(angle);
      final ly = cy + labelR * sin(angle);

      // Sombra glow
      final tpGlow = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: colors[i].withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            shadows: [
              Shadow(color: colors[i], blurRadius: 10),
              Shadow(color: colors[i], blurRadius: 20),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpGlow.paint(canvas, Offset(lx - tpGlow.width / 2, ly - tpGlow.height / 2));
    }
  }

  @override
  bool shouldRepaint(_HexPainter old) =>
      old.values.toString() != values.toString();
}


