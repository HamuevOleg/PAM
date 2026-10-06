import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/race_motif.dart';

// Original location-specific vector artwork, shared by previews and animation.
class RaceEmblem extends StatelessWidget {
  final RaceMotif motif;
  final double height;
  const RaceEmblem({super.key, required this.motif, this.height = 140});
  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: motifName(motif),
    child: SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: RaceMotifPainter(
          motif: motif,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ),
  );
}

/// Separate pen strokes allow both crisp static thumbnails and progressive ink.
List<Path> motifStrokes(RaceMotif kind) {
  final lines = <Path>[];
  void line(List<Offset> points) {
    final p = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      p.lineTo(point.dx, point.dy);
    }
    lines.add(p);
  }

  void circle(double x, double y, double radius) => lines.add(
    Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: radius)),
  );
  void rect(double x, double y, double w, double h) =>
      lines.add(Path()..addRect(Rect.fromLTWH(x, y, w, h)));

  switch (kind) {
    case RaceMotif.vineyard:
      // The tendril and serrated vine leaf frame a tapered bunch.
      lines.add(
        Path()
          ..moveTo(157, 79)
          ..cubicTo(161, 55, 145, 37, 161, 22)
          ..cubicTo(177, 10, 198, 26, 184, 38)
          ..cubicTo(175, 45, 171, 32, 180, 31),
      );
      line([
        const Offset(159, 60),
        const Offset(137, 32),
        const Offset(119, 39),
        const Offset(111, 24),
        const Offset(101, 49),
        const Offset(78, 46),
        const Offset(86, 66),
        const Offset(69, 78),
        const Offset(101, 85),
        const Offset(105, 99),
        const Offset(129, 83),
        const Offset(151, 79),
      ]);
      lines.add(
        Path()
          ..moveTo(88, 75)
          ..quadraticBezierTo(120, 72, 146, 58),
      );
      line([
        const Offset(109, 78),
        const Offset(104, 59),
        const Offset(102, 49),
      ]);
      line([const Offset(124, 70), const Offset(124, 45)]);
      lines.add(
        Path()
          ..moveTo(164, 56)
          ..cubicTo(183, 39, 214, 38, 232, 56)
          ..cubicTo(214, 74, 186, 74, 164, 56),
      );
      lines.add(
        Path()
          ..moveTo(164, 56)
          ..quadraticBezierTo(200, 50, 232, 56),
      );
      for (final row in [
        (98.0, [124.0, 160.0, 196.0]),
        (131.0, [142.0, 178.0]),
        (164.0, [160.0]),
        (193.0, [160.0]),
      ]) {
        for (final x in row.$2) {
          circle(x, row.$1, row.$1 == 193 ? 14 : 19);
        }
      }
      for (final center in [
        const Offset(124, 98),
        const Offset(178, 131),
        const Offset(160, 164),
      ]) {
        lines.add(
          Path()
            ..moveTo(center.dx - 10, center.dy - 2)
            ..quadraticBezierTo(
              center.dx - 10,
              center.dy - 11,
              center.dx - 2,
              center.dy - 11,
            ),
        );
      }
      lines.add(
        Path()
          ..moveTo(68, 219)
          ..cubicTo(112, 212, 129, 229, 163, 219)
          ..cubicTo(193, 209, 220, 218, 253, 215),
      );
    case RaceMotif.arch:
      // Chișinău's square triumphal arch: clock, cornice, four piers.
      line([const Offset(54, 221), const Offset(266, 221)]);
      line([const Offset(61, 213), const Offset(259, 213)]);
      rect(75, 82, 170, 126);
      rect(69, 70, 182, 12);
      rect(80, 28, 160, 42);
      rect(75, 21, 170, 7);
      line([const Offset(85, 16), const Offset(235, 16)]);
      rect(84, 91, 21, 109);
      rect(215, 91, 21, 109);
      rect(80, 200, 29, 8);
      rect(211, 200, 29, 8);
      rect(80, 84, 29, 8);
      rect(211, 84, 29, 8);
      lines.add(
        Path()
          ..moveTo(116, 208)
          ..lineTo(116, 145)
          ..cubicTo(116, 87, 204, 87, 204, 145)
          ..lineTo(204, 208),
      );
      lines.add(
        Path()
          ..moveTo(124, 208)
          ..lineTo(124, 146)
          ..cubicTo(124, 98, 196, 98, 196, 146)
          ..lineTo(196, 208),
      );
      circle(160, 48, 15);
      circle(160, 48, 11);
      line([
        const Offset(160, 40),
        const Offset(160, 48),
        const Offset(166, 51),
      ]);
      line([const Offset(88, 37), const Offset(128, 37)]);
      line([const Offset(192, 37), const Offset(232, 37)]);
      line([const Offset(88, 59), const Offset(128, 59)]);
      line([const Offset(192, 59), const Offset(232, 59)]);
      for (double y = 104; y < 196; y += 16) {
        line([Offset(86, y), Offset(103, y)]);
        line([Offset(217, y), Offset(234, y)]);
      }
      line([const Offset(158, 95), const Offset(158, 108)]);
    case RaceMotif.orhei:
      // A cliff-top bell tower and cave entrance above the Răut valley.
      lines.add(
        Path()
          ..moveTo(25, 175)
          ..cubicTo(55, 170, 63, 154, 86, 151)
          ..lineTo(116, 140)
          ..lineTo(181, 136)
          ..lineTo(230, 149)
          ..cubicTo(261, 154, 277, 168, 296, 170),
      );
      lines.add(
        Path()
          ..moveTo(36, 191)
          ..cubicTo(77, 181, 92, 163, 126, 164)
          ..cubicTo(164, 165, 175, 152, 216, 164)
          ..lineTo(280, 185),
      );
      lines.add(
        Path()
          ..moveTo(63, 207)
          ..cubicTo(111, 181, 132, 204, 171, 181)
          ..cubicTo(215, 169, 244, 198, 272, 196),
      );
      lines.add(
        Path()
          ..moveTo(21, 223)
          ..cubicTo(81, 200, 120, 240, 180, 214)
          ..cubicTo(236, 190, 274, 222, 301, 211),
      );
      rect(125, 84, 48, 54);
      rect(120, 78, 58, 7);
      line([
        const Offset(120, 78),
        const Offset(130, 59),
        const Offset(168, 59),
        const Offset(178, 78),
      ]);
      lines.add(
        Path()
          ..moveTo(130, 59)
          ..cubicTo(130, 47, 138, 42, 149, 34)
          ..cubicTo(160, 42, 168, 47, 168, 59),
      );
      line([const Offset(149, 34), const Offset(149, 15)]);
      line([const Offset(141, 22), const Offset(157, 22)]);
      lines.add(
        Path()
          ..moveTo(139, 120)
          ..lineTo(139, 103)
          ..quadraticBezierTo(149, 83, 159, 103)
          ..lineTo(159, 120)
          ..close(),
      );
      lines.add(
        Path()
          ..moveTo(143, 112)
          ..lineTo(143, 105)
          ..quadraticBezierTo(149, 96, 155, 105)
          ..lineTo(155, 112)
          ..close(),
      );
      line([const Offset(135, 123), const Offset(163, 123)]);
      lines.add(
        Path()
          ..moveTo(187, 171)
          ..lineTo(187, 158)
          ..quadraticBezierTo(198, 140, 208, 158)
          ..lineTo(208, 172),
      );
      line([const Offset(93, 148), const Offset(93, 106)]);
      line([const Offset(82, 119), const Offset(104, 119)]);
      for (var i = 0; i < 6; i++) {
        line([
          Offset(116 - i * 8, 165 + i * 6),
          Offset(129 - i * 8, 165 + i * 6),
        ]);
      }
      circle(238, 56, 19);
      lines.add(
        Path()
          ..moveTo(39, 67)
          ..quadraticBezierTo(48, 60, 57, 67)
          ..quadraticBezierTo(65, 61, 74, 66),
      );
    case RaceMotif.iasiPalace:
      // Palace of Culture: central clock tower, Gothic roof and long wings.
      line([const Offset(17, 225), const Offset(303, 225)]);
      rect(24, 207, 272, 10);
      rect(30, 129, 102, 78);
      rect(188, 129, 102, 78);
      line([
        const Offset(24, 129),
        const Offset(42, 107),
        const Offset(119, 107),
        const Offset(132, 129),
      ]);
      line([
        const Offset(188, 129),
        const Offset(201, 107),
        const Offset(278, 107),
        const Offset(296, 129),
      ]);
      rect(132, 80, 56, 127);
      rect(126, 75, 68, 7);
      line([
        const Offset(132, 75),
        const Offset(142, 40),
        const Offset(178, 40),
        const Offset(188, 75),
      ]);
      line([
        const Offset(142, 40),
        const Offset(160, 18),
        const Offset(178, 40),
      ]);
      line([const Offset(160, 18), const Offset(160, 7)]);
      for (final x in [126.0, 194.0]) {
        line([
          Offset(x - 5, 83),
          Offset(x - 5, 57),
          Offset(x, 44),
          Offset(x + 5, 57),
          Offset(x + 5, 83),
        ]);
      }
      circle(160, 101, 16);
      circle(160, 101, 12);
      line([
        const Offset(160, 92),
        const Offset(160, 101),
        const Offset(168, 105),
      ]);
      for (final x in [45.0, 70.0, 95.0, 211.0, 236.0, 261.0]) {
        lines.add(
          Path()
            ..moveTo(x, 169)
            ..lineTo(x, 145)
            ..lineTo(x + 8, 137)
            ..lineTo(x + 16, 145)
            ..lineTo(x + 16, 169)
            ..close(),
        );
        line([Offset(x + 8, 140), Offset(x + 8, 169)]);
        rect(x, 184, 16, 16);
      }
      for (final x in [145.0, 166.0]) {
        lines.add(
          Path()
            ..moveTo(x, 158)
            ..lineTo(x, 134)
            ..lineTo(x + 5, 126)
            ..lineTo(x + 10, 134)
            ..lineTo(x + 10, 158)
            ..close(),
        );
      }
      lines.add(
        Path()
          ..moveTo(147, 207)
          ..lineTo(147, 183)
          ..quadraticBezierTo(160, 157, 173, 183)
          ..lineTo(173, 207),
      );
      line([const Offset(30, 176), const Offset(132, 176)]);
      line([const Offset(188, 176), const Offset(290, 176)]);
      for (final x in [37.0, 282.0]) {
        line([
          Offset(x - 7, 128),
          Offset(x - 7, 109),
          Offset(x, 96),
          Offset(x + 7, 109),
          Offset(x + 7, 128),
        ]);
      }
    case RaceMotif.athenaeum:
      // Romanian Athenaeum: domed rotunda and six-column classical portico.
      line([const Offset(25, 226), const Offset(295, 226)]);
      rect(40, 215, 240, 7);
      rect(51, 207, 218, 8);
      rect(62, 129, 196, 78);
      lines.add(
        Path()
          ..moveTo(69, 101)
          ..cubicTo(73, 52, 104, 31, 160, 26)
          ..cubicTo(216, 31, 247, 52, 251, 101),
      );
      rect(66, 98, 188, 10);
      lines.add(
        Path()
          ..moveTo(98, 98)
          ..cubicTo(101, 54, 129, 32, 160, 26)
          ..cubicTo(191, 32, 219, 54, 222, 98),
      );
      lines.add(
        Path()
          ..moveTo(129, 98)
          ..quadraticBezierTo(127, 54, 160, 26)
          ..quadraticBezierTo(193, 54, 191, 98),
      );
      rect(151, 16, 18, 10);
      line([
        const Offset(148, 16),
        const Offset(160, 7),
        const Offset(172, 16),
      ]);
      line([
        const Offset(53, 130),
        const Offset(160, 89),
        const Offset(267, 130),
        const Offset(53, 130),
      ]);
      line([
        const Offset(76, 124),
        const Offset(160, 99),
        const Offset(244, 124),
      ]);
      rect(56, 131, 208, 7);
      for (final x in [73.0, 105.0, 137.0, 169.0, 201.0, 233.0]) {
        rect(x, 143, 13, 58);
        rect(x - 3, 138, 19, 5);
        rect(x - 3, 201, 19, 6);
        line([Offset(x + 5, 147), Offset(x + 5, 197)]);
      }
      for (final x in [95.0, 127.0, 159.0, 191.0, 223.0]) {
        circle(x, 150, 4);
        lines.add(
          Path()
            ..moveTo(x - 5, 199)
            ..lineTo(x - 5, 175)
            ..quadraticBezierTo(x, 164, x + 5, 175)
            ..lineTo(x + 5, 199),
        );
      }
    case RaceMotif.forest:
      // Broadleaf forest and winding trail, for the Codrii event in Lozova.
      for (final (x, y, r) in [
        (75.0, 96.0, 29.0),
        (158.0, 66.0, 38.0),
        (246.0, 101.0, 27.0),
      ]) {
        lines.add(
          Path()
            ..moveTo(x, y + r)
            ..cubicTo(
              x - r * 1.7,
              y + r,
              x - r * 1.5,
              y - r * .4,
              x - r * .7,
              y - r * .5,
            )
            ..cubicTo(
              x - r,
              y - r * 1.7,
              x + r * .7,
              y - r * 1.7,
              x + r * .7,
              y - r * .5,
            )
            ..cubicTo(x + r * 1.6, y - r * .4, x + r * 1.6, y + r, x, y + r),
        );
        line([Offset(x, y - 6), Offset(x, y + r + 57)]);
        line([Offset(x - 16, y + 9), Offset(x, y + 26), Offset(x + 16, y + 5)]);
        line([Offset(x - 9, y + r + 57), Offset(x + 11, y + r + 57)]);
      }
      lines.add(
        Path()
          ..moveTo(145, 155)
          ..cubicTo(106, 170, 203, 179, 159, 199)
          ..quadraticBezierTo(133, 211, 101, 227),
      );
      lines.add(
        Path()
          ..moveTo(157, 155)
          ..cubicTo(133, 169, 229, 181, 194, 205)
          ..quadraticBezierTo(178, 219, 169, 231),
      );
      lines.add(
        Path()
          ..moveTo(24, 192)
          ..quadraticBezierTo(63, 179, 115, 189),
      );
      lines.add(
        Path()
          ..moveTo(211, 191)
          ..quadraticBezierTo(263, 181, 299, 199),
      );
      lines.add(
        Path()
          ..moveTo(259, 22)
          ..cubicTo(247, 46, 271, 60, 282, 43)
          ..cubicTo(263, 49, 255, 37, 259, 22),
      );
    case RaceMotif.riverside:
      // Dniester river, reeds and a low riverside landscape.
      circle(237, 52, 22);
      lines.add(
        Path()
          ..moveTo(23, 100)
          ..quadraticBezierTo(76, 68, 136, 98)
          ..quadraticBezierTo(212, 76, 296, 108),
      );
      for (var i = 0; i < 4; i++) {
        final y = 121.0 + i * 24;
        lines.add(
          Path()
            ..moveTo(43 + i * 6, y)
            ..cubicTo(98, y - 15, 130, y + 15, 175, y)
            ..cubicTo(211, y - 12, 245, y + 10, 286 - i * 5, y),
        );
      }
      for (final x in [44.0, 62.0, 79.0]) {
        line([Offset(x, 220), Offset(x, 164)]);
        line([Offset(x, 205), Offset(x - 12, 183)]);
        line([Offset(x, 193), Offset(x + 10, 179)]);
        lines.add(Path()..addOval(Rect.fromLTWH(x - 3, 145, 6, 24)));
      }
      lines.add(
        Path()
          ..moveTo(231, 94)
          ..lineTo(231, 144)
          ..lineTo(201, 144)
          ..close(),
      );
      line([
        const Offset(231, 105),
        const Offset(250, 140),
        const Offset(235, 140),
      ]);
      line([
        const Offset(199, 150),
        const Offset(253, 150),
        const Offset(245, 158),
        const Offset(209, 158),
        const Offset(199, 150),
      ]);
      lines.add(
        Path()
          ..moveTo(106, 46)
          ..quadraticBezierTo(115, 38, 124, 46)
          ..quadraticBezierTo(132, 38, 141, 46),
      );
    case RaceMotif.parkSteps:
      // Valea Morilor: cascaded park steps opening toward the lake.
      for (var i = 0; i < 8; i++) {
        final y = 101.0 + i * 13;
        final inset = i * 8.0;
        line([Offset(130 - inset, y), Offset(190 + inset, y)]);
      }
      line([const Offset(117, 91), const Offset(57, 209)]);
      line([const Offset(203, 91), const Offset(263, 209)]);
      line([const Offset(108, 91), const Offset(48, 209)]);
      line([const Offset(212, 91), const Offset(272, 209)]);
      for (var i = 0; i < 5; i++) {
        final y = 113.0 + i * 19;
        line([Offset(112 - i * 10, y), Offset(112 - i * 10, y + 12)]);
        line([Offset(208 + i * 10, y), Offset(208 + i * 10, y + 12)]);
      }
      rect(111, 84, 98, 7);
      for (final x in [125.0, 151.0, 177.0]) {
        rect(x, 52, 7, 32);
      }
      lines.add(
        Path()
          ..moveTo(107, 52)
          ..quadraticBezierTo(160, 12, 213, 52)
          ..close(),
      );
      line([const Offset(160, 30), const Offset(160, 18)]);
      for (final x in [45.0, 275.0]) {
        lines.add(
          Path()
            ..moveTo(x, 127)
            ..lineTo(x, 80),
        );
        lines.add(
          Path()..addOval(
            Rect.fromCenter(center: Offset(x, 67), width: 35, height: 51),
          ),
        );
      }
      lines.add(
        Path()
          ..moveTo(20, 226)
          ..cubicTo(85, 212, 118, 239, 162, 226)
          ..cubicTo(215, 212, 246, 235, 299, 223),
      );

    case RaceMotif.stefan:
      // An original outline interpretation of the Chișinău monument.
      // Raised cross, crown, robe, sword and stone plinth form its silhouette.
      rect(105, 206, 112, 12);
      rect(97, 218, 128, 9);
      line([const Offset(86, 232), const Offset(236, 232)]);
      // Crown, hair and face.
      line([
        const Offset(140, 53),
        const Offset(138, 39),
        const Offset(148, 44),
        const Offset(154, 32),
        const Offset(161, 43),
        const Offset(170, 35),
        const Offset(171, 53),
        const Offset(140, 53),
      ]);
      line([const Offset(141, 48), const Offset(169, 48)]);
      lines.add(
        Path()
          ..moveTo(141, 54)
          ..cubicTo(132, 59, 134, 78, 142, 84)
          ..lineTo(147, 90)
          ..lineTo(162, 89)
          ..cubicTo(174, 82, 177, 64, 168, 54),
      );
      lines.add(
        Path()
          ..moveTo(139, 59)
          ..cubicTo(126, 66, 129, 89, 139, 97),
      );
      lines.add(
        Path()
          ..moveTo(170, 60)
          ..cubicTo(182, 69, 177, 88, 169, 98),
      );
      line([const Offset(143, 66), const Offset(149, 65)]);
      line([const Offset(159, 65), const Offset(165, 66)]);
      line([
        const Offset(155, 66),
        const Offset(152, 75),
        const Offset(157, 76),
      ]);
      lines.add(
        Path()
          ..moveTo(146, 81)
          ..quadraticBezierTo(154, 77, 163, 81),
      );
      line([const Offset(150, 85), const Offset(160, 85)]);
      // Mantle and raised right arm, on the viewer's left.
      lines.add(
        Path()
          ..moveTo(142, 89)
          ..lineTo(128, 96)
          ..lineTo(111, 85)
          ..lineTo(97, 53)
          ..lineTo(85, 56)
          ..lineTo(92, 98)
          ..lineTo(119, 116)
          ..lineTo(107, 194)
          ..lineTo(124, 204)
          ..lineTo(196, 204)
          ..lineTo(189, 165)
          ..lineTo(185, 113)
          ..lineTo(173, 99)
          ..lineTo(164, 90),
      );
      line([
        const Offset(88, 57),
        const Offset(86, 49),
        const Offset(90, 44),
        const Offset(96, 48),
        const Offset(98, 54),
      ]);
      // Cross and its solid outline.
      line([
        const Offset(88, 44),
        const Offset(88, 26),
        const Offset(77, 26),
        const Offset(77, 20),
        const Offset(88, 20),
        const Offset(88, 7),
        const Offset(94, 7),
        const Offset(94, 20),
        const Offset(105, 20),
        const Offset(105, 26),
        const Offset(94, 26),
        const Offset(94, 44),
      ]);
      line([
        const Offset(101, 68),
        const Offset(110, 93),
        const Offset(127, 106),
      ]);
      line([
        const Offset(142, 92),
        const Offset(153, 105),
        const Offset(167, 94),
      ]);
      lines.add(
        Path()
          ..moveTo(129, 99)
          ..cubicTo(132, 130, 125, 164, 117, 190),
      );
      lines.add(
        Path()
          ..moveTo(171, 101)
          ..cubicTo(160, 124, 163, 165, 171, 197),
      );
      // Belt, robe and sword hand.
      line([const Offset(133, 125), const Offset(169, 125)]);
      circle(153, 126, 4);
      line([
        const Offset(183, 111),
        const Offset(198, 133),
        const Offset(192, 143),
        const Offset(178, 129),
        const Offset(171, 115),
      ]);
      lines.add(
        Path()
          ..moveTo(192, 141)
          ..lineTo(184, 143)
          ..lineTo(182, 149)
          ..lineTo(190, 152)
          ..lineTo(194, 146),
      );
      line([const Offset(175, 152), const Offset(202, 152)]);
      line([
        const Offset(187, 153),
        const Offset(183, 193),
        const Offset(189, 201),
        const Offset(195, 153),
      ]);
      line([const Offset(142, 134), const Offset(132, 190)]);
      lines.add(
        Path()
          ..moveTo(153, 134)
          ..quadraticBezierTo(145, 169, 151, 198),
      );
      line([const Offset(161, 136), const Offset(163, 188)]);
      line([
        const Offset(125, 204),
        const Offset(135, 195),
        const Offset(142, 204),
      ]);
      line([
        const Offset(164, 204),
        const Offset(174, 196),
        const Offset(181, 204),
      ]);
  }
  return lines;
}

class RaceMotifPainter extends CustomPainter {
  final RaceMotif motif;
  final double progress;
  final Color color;
  RaceMotifPainter({
    required this.motif,
    required this.color,
    this.progress = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 320, size.height / 240);
    canvas.save();
    canvas.translate(
      (size.width - 320 * scale) / 2,
      (size.height - 240 * scale) / 2,
    );
    canvas.scale(scale);
    final paths = motifStrokes(motif);
    final metrics = [for (final path in paths) ...path.computeMetrics()];
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    var remaining = total * progress.clamp(0, 1);
    final ink = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final ghost = Paint()
      ..color = color.withValues(alpha: .065)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final path in paths) {
      canvas.drawPath(path, ghost);
    }
    for (final metric in metrics) {
      if (remaining <= 0) break;
      final length = math.min(remaining, metric.length);
      canvas.drawPath(metric.extractPath(0, length), ink);
      remaining -= metric.length;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RaceMotifPainter old) =>
      old.motif != motif || old.progress != progress || old.color != color;
}
