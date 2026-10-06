import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run_baza/main.dart';
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
    RaceDetailsScreen(race: races.first),
    TransferScreen(race: races.first),
    const MyPlanScreen(),
    const SettingsScreen(),
    const LoginScreen(),
    DistanceScreen(race: races[1], distance: 5),
    DistanceScreen(race: races.first, distance: 10),
    DistanceScreen(race: races.first, distance: 21.1),
    DistanceScreen(race: races[6], distance: 42.2),
    RaceDetailsScreen(race: races[2]),
    DistanceScreen(race: races[2], distance: 10),
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
      await tester.pumpWidget(const RunBazaApp());
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
      expect(page.race.id, raceId);
      expect(page.distance, distance);
      expect(find.text(page.race.locationLabel), findsOneWidget);
    });
  }
  testWidgets('Home reaches calendar and returns', (tester) async {
    await tester.pumpWidget(const RunBazaApp());
    await tester.tap(find.text('Забеги'));
    await tester.pumpAndSettle();
    expect(find.text('Календарь забегов'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('RUNBAZA'), findsOneWidget);
  });
  testWidgets('Login stays static without validation', (tester) async {
    await tester.pumpWidget(const RunBazaApp());
    await tester.tap(find.byTooltip('Вход'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(Form), findsNothing);
    expect(
      tester.widgetList<TextField>(find.byType(TextField)).last.obscureText,
      isTrue,
    );
    await tester.scrollUntilVisible(
      find.text('Войти'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('RUNBAZA'), findsOneWidget);
  });
  for (final distance in [10.0, 21.1]) {
    testWidgets('Distance $distance opens from event, keeps race and returns', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(Brightness.light),
          home: RaceDetailsScreen(race: races.first),
        ),
      );
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
      expect(page.race.id, races.first.id);
      expect(
        find.text(distance == 10 ? 'Десятка' : 'Полумарафон'),
        findsWidgets,
      );
      await tester.tap(find.text('На старт с попутчиками'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TransferScreen>(find.byType(TransferScreen)).race.id,
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
