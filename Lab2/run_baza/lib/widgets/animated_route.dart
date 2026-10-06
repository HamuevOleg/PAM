import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/distance_profile.dart';
import 'design.dart';
import '../data/race_motif.dart';
import 'race_motif.dart';

/// An illustrative distance animation, not geographical or live tracking data.
class AnimatedRoute extends StatefulWidget {
  final double distance;
  final RaceMotif motif;
  const AnimatedRoute({super.key, required this.distance, required this.motif});

  @override
  State<AnimatedRoute> createState() => _AnimatedRouteState();
}

class _AnimatedRouteState extends State<AnimatedRoute>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );
  late final CurvedAnimation _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );
  bool? _reduceMotion;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion != reduce) {
      _reduceMotion = reduce;
      _start();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.distance != widget.distance ||
        oldWidget.motif != widget.motif) {
      _start();
    }
  }

  void _start() {
    if (_reduceMotion == true) {
      _controller.stop();
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final profile = DistanceProfile(widget.distance);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Eyebrow(motifName(widget.motif))),
              IconButton(
                tooltip: 'Повторить анимацию маршрута',
                onPressed: _reduceMotion == true ? null : _start,
                icon: const Icon(Icons.replay, size: 19),
                color: s.primary,
              ),
            ],
          ),
          Semantics(
            label: 'Декоративная анимация линии дистанции ${profile.label}',
            image: true,
            child: ExcludeSemantics(
              child: SizedBox(
                height: 250,
                child: CustomPaint(
                  key: const ValueKey('animated-route-canvas'),
                  painter: RouteLinePainter(
                    progress: _progress,
                    distance: widget.distance,
                    motif: widget.motif,
                    color: s.primary,
                    signal: s.tertiary,
                    surface: s.surfaceContainer,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'СТАРТ / 0 КМ',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              Expanded(
                child: Text(
                  'ФИНИШ / ${profile.label.toUpperCase()}',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // The controller repaints the illustration directly; only this small
          // strip rebuilds per frame, not the page or its list of details.
          AnimatedBuilder(
            animation: _progress,
            builder: (context, _) => LinearProgressIndicator(
              key: const ValueKey('route-progress'),
              value: _progress.value,
              minHeight: 3,
              color: s.primary,
              backgroundColor: s.primary.withValues(alpha: .12),
              semanticsLabel: 'Прорисовка линии дистанции',
            ),
          ),
        ],
      ),
    );
  }
}

class RouteLinePainter extends CustomPainter {
  final Animation<double> progress;
  final double distance;
  final RaceMotif motif;
  bool get halfMarathon => distance >= 20 && distance < 40;
  final Color color, signal, surface;
  RouteLinePainter({
    required this.progress,
    required this.distance,
    required this.motif,
    required this.color,
    required this.signal,
    required this.surface,
  }) : super(repaint: progress);

  Path _route() => Path()
    ..moveTo(20, 28)
    ..cubicTo(70, 48, 100, 5, 155, 23)
    ..cubicTo(212, 43, 250, 7, 295, 23);

  @override
  void paint(Canvas canvas, Size size) {
    final artHeight = size.height - 48;
    RaceMotifPainter(
      motif: motif,
      color: color,
      progress: progress.value,
    ).paint(canvas, Size(size.width, artHeight));
    final scale = math.min(size.width / 320, 1.0);
    canvas.save();
    canvas.translate((size.width - 320 * scale) / 2, artHeight + 2);
    canvas.scale(scale);
    final path = _route();
    final metric = path.computeMetrics().first;
    final value = progress.value.clamp(0.0, 1.0);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: .20);
    for (double i = 0; i < metric.length; i += 9) {
      canvas.drawPath(
        metric.extractPath(i, math.min(i + 3, metric.length)),
        stroke,
      );
    }
    final drawn = metric.extractPath(0, metric.length * value);
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color.withValues(alpha: .08),
    );
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
    for (final stop in [.25, .50, .75]) {
      if (value >= stop) {
        final point = metric
            .getTangentForOffset(metric.length * stop)!
            .position;
        canvas.drawCircle(point, 4.5, Paint()..color = surface);
        canvas.drawCircle(point, 3, Paint()..color = color);
      }
    }
    final start = metric.getTangentForOffset(0)!.position;
    final finish = metric.getTangentForOffset(metric.length)!.position;
    canvas.drawCircle(start, 5, Paint()..color = color);
    canvas.drawCircle(start, 2, Paint()..color = surface);
    // The flag becomes solid once the stroke reaches the finish.
    final flag = Paint()
      ..color = value >= .995 ? color : color.withValues(alpha: .25);
    canvas.drawLine(
      finish + const Offset(0, 4),
      finish + const Offset(0, -16),
      flag..strokeWidth = 1.5,
    );
    canvas.drawPath(
      Path()
        ..moveTo(finish.dx, finish.dy - 16)
        ..lineTo(finish.dx + 12, finish.dy - 12)
        ..lineTo(finish.dx, finish.dy - 7)
        ..close(),
      flag,
    );
    final head = metric.getTangentForOffset(metric.length * value)!.position;
    final halo = value < 1 ? 9 + 2 * math.sin(value * math.pi * 8) : 10.0;
    canvas.drawCircle(
      head,
      halo,
      Paint()..color = signal.withValues(alpha: .12),
    );
    canvas.drawCircle(head, 4.5, Paint()..color = signal);
    canvas.drawCircle(head, 1.5, Paint()..color = surface);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RouteLinePainter old) =>
      old.distance != distance ||
      old.motif != motif ||
      old.color != color ||
      old.signal != signal ||
      old.surface != surface ||
      old.progress != progress;
}
