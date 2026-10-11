import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run_baza/main.dart';
import 'package:run_baza/router.dart';
import 'package:run_baza/screens/trip_form_screen.dart';
import 'package:run_baza/screens/participation_form_screen.dart';
import 'package:run_baza/data/mock_data.dart';
import 'package:run_baza/screens/home_screen.dart';
import 'package:run_baza/screens/login_screen.dart';
import 'package:run_baza/screens/race_index_screen.dart';
import 'package:run_baza/screens/race_details_screen.dart';
import 'package:run_baza/screens/transfer_screen.dart';
import 'package:run_baza/screens/my_plan_screen.dart';
import 'package:run_baza/screens/settings_screen.dart';
import 'package:run_baza/screens/distance_screen.dart';
import 'package:run_baza/widgets/distance_option.dart';

void main() {
  final screens = <Widget>[
    const HomeScreen(),
    const RaceIndexScreen(),
    RaceDetailsScreen(id: races.first.id),
    TransferScreen(id: races.first.id),
    const MyPlanScreen(),
    const SettingsScreen(),
    const LoginScreen(),
    const TripFormScreen(id: 'r1', driver: true),
    const TripFormScreen(id: 'r1', driver: false),
    const ParticipationFormScreen(id: 'r1'),
    DistanceScreen(id: races[1].id, distance: 5),
    DistanceScreen(id: races.first.id, distance: 10),
    DistanceScreen(id: races.first.id, distance: 21.1),
    DistanceScreen(id: races[6].id, distance: 42.2),
    RaceDetailsScreen(id: races[2].id),
    DistanceScreen(id: races[2].id, distance: 10),
  ];
  for (final (width, brightness, scale) in [
    (320.0, Brightness.light, 1.2),
    (430.0, Brightness.light, 1.2),
    (390.0, Brightness.dark, 1.0),
    (390.0, Brightness.light, 1.6),
  ]) {
    for (var i = 0; i < screens.length; i++) {
      testWidgets(
        'Screen $i at width $width / $brightness / $scale, scroll without overflow',
        (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              theme: buildTheme(brightness),
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 900),
                  textScaler: TextScaler.linear(scale),
                ),
                child: screens[i],
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          for (var n = 0; n < 10; n++) {
            await tester.drag(
              find.byType(ListView).first,
              const Offset(0, -600),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }
  for (final (raceId, distance) in [
    ('r4', 5.0),
    ('r3', 10.0),
    ('r1', 21.1),
    ('r7', 42.2),
  ]) {
    testWidgets('Home preview $raceId opens the same city and distance', (
      tester,
    ) async {
      final router = createRouter(initialLocation: '/home');
      addTearDown(router.dispose);
      await tester.pumpWidget(RunBazaApp(router: router));
      await tester.pumpAndSettle();
      final option = find.byWidgetPredicate(
        (w) =>
            w is DistanceOption &&
            w.race.id == raceId &&
            w.distance == distance,
      );
      await tester.scrollUntilVisible(
        option,
        350,
        scrollable: find.byType(Scrollable).first,
      );
      await Scrollable.ensureVisible(tester.element(option), alignment: 0.5);
      await tester.pumpAndSettle();
      final preview = tester.widget<DistanceOption>(option);
      expect(preview.race.country, raceById(raceId).country);
      await tester.tap(option);
      await tester.pumpAndSettle();
      final page = tester.widget<DistanceScreen>(find.byType(DistanceScreen));
      expect(page.id, raceId);
      expect(page.distance, distance);
      expect(find.text(raceById(page.id).locationLabel), findsOneWidget);
    });
  }
  testWidgets('Home reaches calendar and returns', (tester) async {
    final router = createRouter(initialLocation: '/home');
    addTearDown(router.dispose);
    await tester.pumpWidget(RunBazaApp(router: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Забеги'));
    await tester.pumpAndSettle();
    expect(find.text('Календарь забегов'), findsOneWidget);
    await tester.tap(find.text('Главная'));
    await tester.pumpAndSettle();
    expect(find.text('RUNBAZA'), findsOneWidget);
  });
  for (final distance in [10.0, 21.1]) {
    testWidgets('Distance $distance opens from event, keeps race and returns', (
      tester,
    ) async {
      final router = createRouter(initialLocation: '/races/r1');
      addTearDown(router.dispose);
      await tester.pumpWidget(RunBazaApp(router: router));
      await tester.pumpAndSettle();
      final choice = find.byWidgetPredicate(
        (w) => w is DistanceOption && w.distance == distance,
      );
      await tester.scrollUntilVisible(
        choice,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(choice);
      await tester.pumpAndSettle();
      final page = tester.widget<DistanceScreen>(find.byType(DistanceScreen));
      expect(page.distance, distance);
      expect(page.id, races.first.id);
      expect(
        find.text(distance == 10 ? 'Десятка' : 'Полумарафон'),
        findsWidgets,
      );
      await tester.tap(find.text('На старт с попутчиками'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TransferScreen>(find.byType(TransferScreen)).id,
        races.first.id,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DistanceScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(RaceDetailsScreen), findsOneWidget);
    });
  }
  test('Mock data has valid references and required list sizes', () {
    expect(races.length, greaterThanOrEqualTo(8));
    expect(plan.length, greaterThanOrEqualTo(6));
    expect(offers.length, greaterThanOrEqualTo(6));
    expect(requests.length, greaterThanOrEqualTo(6));
    for (final entry in plan) {
      expect(raceById(entry.raceId).id, entry.raceId);
    }
    for (final offer in offers) {
      expect(raceById(offer.raceId).id, offer.raceId);
    }
    expect(offers.fold<int>(0, (s, o) => s + o.freeSeats), 12);
  });
}
