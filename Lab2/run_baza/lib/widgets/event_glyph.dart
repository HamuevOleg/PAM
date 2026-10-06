import 'dart:math' as math;

import 'package:flutter/material.dart';

// Native adaptation of EventGlyph.tsx. These drawings are decorative emblems,
// not a real race route or elevation profile.
class EventGlyph extends StatelessWidget {
  final String kind;
  final double height;
  const EventGlyph({super.key, this.kind = 'summit', this.height = 140});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _GlyphPainter(kind, Theme.of(context).colorScheme.primary),
      ),
    ),
  );
}

String glyphFor(String id) => switch (id) {
  'r2' || 'r6' => 'arch',
  'r4' => 'vineyard',
  'r5' => 'forest',
  'r1' => 'summit',
  _ => 'course',
};

class _GlyphPainter extends CustomPainter {
  final String kind;
  final Color color;
  _GlyphPainter(this.kind, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 320, size.height / 250);
    canvas.translate(
      (size.width - 320 * scale) / 2,
      (size.height - 250 * scale) / 2,
    );
    canvas.scale(scale);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;
    final fine = Paint()
      ..color = color.withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    for (double y = 25; y < 230; y += 7) {
      canvas.drawLine(Offset(160, y), Offset(160, y + 1), fine);
    }
    for (double x = 20; x < 300; x += 7) {
      canvas.drawLine(Offset(x, 125), Offset(x + 1, 125), fine);
    }
    for (final o in [
      const Offset(20, 23),
      const Offset(288, 23),
      const Offset(20, 215),
      const Offset(288, 215),
    ]) {
      canvas.drawLine(o, o + const Offset(12, 0), fine);
      canvas.drawLine(o, o + const Offset(0, 12), fine);
    }
    switch (kind) {
      case 'arch':
        for (var i = 0; i < 9; i++) {
          final x = 66 + i * 8.0,
              y = 111 + i * 3.0,
              rx = 94 - i * 8.0,
              ry = 88 - i * 7.0;
          final path = Path()
            ..moveTo(x, 207)
            ..lineTo(x, y)
            ..arcTo(
              Rect.fromCenter(
                center: Offset(160, y),
                width: rx * 2,
                height: ry * 2,
              ),
              math.pi,
              math.pi,
              false,
            )
            ..lineTo(254 - i * 8, 207);
          canvas.drawPath(path, p);
        }
        for (final y in [207.0, 216.0, 64.0, 56.0]) {
          canvas.drawLine(
            Offset(y < 100 ? 88 : 49, y),
            Offset(y < 100 ? 232 : 271, y),
            p,
          );
        }
      case 'forest':
        for (var i = 0; i < 10; i++) {
          canvas.drawPath(
            Path()
              ..moveTo(160, 32 + i * 13)
              ..lineTo(62 + i * 5, 160 + i * 5)
              ..lineTo(160, 129 + i * 7)
              ..lineTo(258 - i * 5, 160 + i * 5)
              ..close(),
            p,
          );
        }
        canvas.drawLine(const Offset(160, 180), const Offset(160, 220), p);
      case 'vineyard':
        for (final point in [
          const Offset(112, 89),
          const Offset(160, 89),
          const Offset(208, 89),
          const Offset(136, 132),
          const Offset(184, 132),
          const Offset(160, 175),
        ]) {
          for (final r in [32.0, 25.0, 18.0]) {
            canvas.drawCircle(point, r, p);
          }
        }
        canvas.drawPath(
          Path()
            ..moveTo(160, 58)
            ..lineTo(160, 30)
            ..cubicTo(186, 30, 206, 39, 210, 54)
            ..cubicTo(185, 59, 168, 51, 160, 30),
          p,
        );
      case 'summit':
        for (var i = 0; i < 12; i++) {
          canvas.drawPath(
            Path()
              ..moveTo(48 + i * 10, 210)
              ..lineTo(160, 36 + i * 10)
              ..lineTo(272 - i * 10, 210)
              ..close(),
            p,
          );
        }
        for (var i = 0; i < 7; i++) {
          canvas.drawLine(
            Offset(70 + i * 11, 185 - i * 22),
            Offset(260 - i * 14, 210),
            fine,
          );
          canvas.drawLine(
            Offset(250 - i * 11, 185 - i * 22),
            Offset(60 + i * 14, 210),
            fine,
          );
        }
      default:
        canvas.translate(160, 125);
        canvas.rotate(-math.pi / 10);
        for (var i = 0; i < 8; i++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: 222 - i * 20,
                height: 166 - i * 18,
              ),
              Radius.circular(83 - i * 9),
            ),
            p,
          );
        }
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.kind != kind || old.color != color;
}
