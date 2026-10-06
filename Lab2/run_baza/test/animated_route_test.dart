import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run_baza/main.dart';
import 'package:run_baza/widgets/animated_route.dart';
import 'package:run_baza/data/race_motif.dart';

Widget host({
  double distance = 10,
  bool reduceMotion = false,
  RaceMotif motif = RaceMotif.orhei,
}) => MaterialApp(
  theme: buildTheme(Brightness.light),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(
      body: AnimatedRoute(distance: distance, motif: motif),
    ),
  ),
);

double progress(WidgetTester tester) => tester
    .widget<LinearProgressIndicator>(
      find.byKey(const ValueKey('route-progress')),
    )
    .value!;

void main() {
  testWidgets('Route draws progressively, completes and can replay', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    expect(progress(tester), 0);
    await tester.pump(const Duration(milliseconds: 900));
    final first = progress(tester);
    expect(first, greaterThan(0));
    expect(first, lessThan(1));
    await tester.pump(const Duration(milliseconds: 900));
    expect(progress(tester), greaterThan(first));
    await tester.pumpAndSettle();
    expect(progress(tester), 1);
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.tap(find.byTooltip('Повторить анимацию маршрута'));
    await tester.pump();
    expect(progress(tester), 0);
    await tester.pumpAndSettle();
    expect(progress(tester), 1);
  });

  testWidgets('Reduced motion shows complete route without animated frames', (
    tester,
  ) async {
    await tester.pumpWidget(host(reduceMotion: true));
    expect(progress(tester), 1);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('Changing distance restarts with the other route', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await tester.pumpWidget(host(distance: 21.1));
    expect(progress(tester), 0);
    final canvas = tester.widget<CustomPaint>(
      find.byKey(const ValueKey('animated-route-canvas')),
    );
    expect((canvas.painter! as RouteLinePainter).halfMarathon, isTrue);
    await tester.pumpAndSettle();
    expect(progress(tester), 1);
  });

  testWidgets(
    'Changing city at the same distance restarts the correct artwork',
    (tester) async {
      await tester.pumpWidget(host(motif: RaceMotif.iasiPalace));
      await tester.pumpAndSettle();
      await tester.pumpWidget(host(motif: RaceMotif.athenaeum));
      expect(progress(tester), 0);
      final canvas = tester.widget<CustomPaint>(
        find.byKey(const ValueKey('animated-route-canvas')),
      );
      expect((canvas.painter! as RouteLinePainter).motif, RaceMotif.athenaeum);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('Leaving mid-animation disposes the ticker', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
