import 'package:flutter/material.dart';
import '../game/sort_game.dart';

/// Maps ArrowColor to display colors (base + highlight for 3D effect).
class ArrowTheme {
  static Color base(ArrowColor c) => switch (c) {
        ArrowColor.red => const Color(0xFFE53935),
        ArrowColor.blue => const Color(0xFF1E88E5),
        ArrowColor.green => const Color(0xFF43A047),
        ArrowColor.yellow => const Color(0xFFFDD835),
        ArrowColor.purple => const Color(0xFF8E24AA),
        ArrowColor.orange => const Color(0xFFFB8C00),
      };

  static Color light(ArrowColor c) => switch (c) {
        ArrowColor.red => const Color(0xFFFF8A80),
        ArrowColor.blue => const Color(0xFF82B1FF),
        ArrowColor.green => const Color(0xFFA5D6A7),
        ArrowColor.yellow => const Color(0xFFFFF176),
        ArrowColor.purple => const Color(0xFFCE93D8),
        ArrowColor.orange => const Color(0xFFFFCC80),
      };

  static Color dark(ArrowColor c) => switch (c) {
        ArrowColor.red => const Color(0xFFB71C1C),
        ArrowColor.blue => const Color(0xFF0D47A1),
        ArrowColor.green => const Color(0xFF1B5E20),
        ArrowColor.yellow => const Color(0xFFF9A825),
        ArrowColor.purple => const Color(0xFF4A148C),
        ArrowColor.orange => const Color(0xFFE65100),
      };
}

/// Paints a single 3D glossy arrow pointing up.
class ArrowPainter extends CustomPainter {
  final ArrowColor color;

  ArrowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final base = ArrowTheme.base(color);
    final light = ArrowTheme.light(color);
    final dark = ArrowTheme.dark(color);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final shadowPath = _arrowPath(w, h, 2, 3);
    canvas.drawPath(shadowPath, shadowPaint);

    // Main body with vertical gradient
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [dark, base, light, base, dark],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(_arrowPath(w, h, 0, 0), bodyPaint);

    // Top gloss highlight
    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45);
    final glossPath = Path()
      ..moveTo(w * 0.32, h * 0.06)
      ..lineTo(w * 0.5, h * 0.02)
      ..lineTo(w * 0.5, h * 0.62)
      ..lineTo(w * 0.32, h * 0.62)
      ..close();
    canvas.drawPath(glossPath, glossPaint);

    // Outline
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = dark;
    canvas.drawPath(_arrowPath(w, h, 0, 0), outlinePaint);
  }

  Path _arrowPath(double w, double h, double dx, double dy) {
    return Path()
      ..moveTo(w * 0.5 + dx, dy) // tip
      ..lineTo(w * 0.85 + dx, h * 0.35 + dy) // right wing
      ..lineTo(w * 0.65 + dx, h * 0.35 + dy) // right inner
      ..lineTo(w * 0.65 + dx, h + dy) // right shaft bottom
      ..lineTo(w * 0.35 + dx, h + dy) // left shaft bottom
      ..lineTo(w * 0.35 + dx, h * 0.35 + dy) // left inner
      ..lineTo(w * 0.15 + dx, h * 0.35 + dy) // left wing
      ..close();
  }

  @override
  bool shouldRepaint(covariant ArrowPainter old) => old.color != color;
}

/// Paints a glass tube container.
class TubePainter extends CustomPainter {
  final bool highlighted;
  final bool selected;

  TubePainter({this.highlighted = false, this.selected = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = Radius.circular(w * 0.18);

    // Outer glass
    final glassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    final glassRect = RRect.fromLTRBR(0, 0, w, h, r);
    canvas.drawRRect(glassRect, glassPaint);

    // Glass border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = selected ? 3.5 : 2
      ..color = selected
          ? const Color(0xFFFFD54F)
          : highlighted
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.35);
    canvas.drawRRect(glassRect, borderPaint);

    // Left shine streak
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromLTRBR(w * 0.12, h * 0.06, w * 0.22, h * 0.94,
          Radius.circular(w * 0.05)),
      shinePaint,
    );

    // Bottom base
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF5C6BC0).withValues(alpha: 0.6),
          const Color(0xFF3949AB).withValues(alpha: 0.8),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.92, w, h * 0.08));
    canvas.drawRRect(
      RRect.fromLTRBR(0, h * 0.9, w, h, r),
      basePaint,
    );

    // Selection glow
    if (selected) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawRRect(
        RRect.fromLTRBR(-6, -6, w + 6, h + 6, Radius.circular(w * 0.22)),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TubePainter old) =>
      old.highlighted != highlighted || old.selected != selected;
}
