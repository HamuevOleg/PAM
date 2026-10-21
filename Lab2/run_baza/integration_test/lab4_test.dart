import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:run_baza/main.dart';
import 'package:run_baza/router.dart';
import 'package:run_baza/models/plan_model.dart';
import 'package:run_baza/widgets/data_status.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Lab 4 iOS state, profile and repository demonstration', (
    tester,
  ) async {
    final router = createRouter(initialLocation: '/home');
    await tester.pumpWidget(RunBazaApp(router: router));
    await tester.pump();
    expect(find.byType(LoadingView), findsOneWidget);
    await binding.takeScreenshot('01-home-loading');
    await tester.pumpAndSettle();

    Finder getList() => find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .last;
    Future<void> top() async {
      if (getList().evaluate().isNotEmpty) {
        tester.state<ScrollableState>(getList()).position.jumpTo(0);
        await tester.pumpAndSettle();
      }
    }

    Future<void> shot(String name) async {
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
      debugPrint('Captured $name');
    }

    Future<void> route(String path) async {
      final scaffold = find.byType(Scaffold).first;
      ScaffoldMessenger.of(tester.element(scaffold)).clearSnackBars();
      router.go(path);
      await tester.pumpAndSettle();
      await top();
    }

    Future<void> tap(Finder finder) async {
      if (finder.evaluate().isEmpty) {
        await tester.scrollUntilVisible(finder, 300, scrollable: getList());
      }
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> key(String name) => tap(find.byKey(Key(name)));
    Future<void> fill(String name, String value) async {
      final field = find.byKey(Key(name));
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
      await tester.pumpAndSettle();
    }

    Future<void> choose(String name, String value) async {
      await key(name);
      await tap(find.text(value).last);
    }

    Future<void> failure(bool enabled) async {
      await route('/profile');
      if (find.byKey(const Key('diagnostics')).evaluate().isNotEmpty ||
          find.byType(ErrorView).evaluate().isEmpty) {
        await key('diagnostics');
      }
      final control = find.byKey(const Key('simulate-error'));
      if (control.evaluate().isEmpty) {
        await tester.scrollUntilVisible(control, 300, scrollable: getList());
      }
      if (tester.widget<SwitchListTile>(control).value != enabled) {
        await tap(control);
      }
    }

    await shot('02-home-data');
    await route('/profile');
    await shot('03-profile');
    await route('/races/r4');
    final plan = tester
        .element(find.byKey(const Key('details-remove-plan')))
        .read<PlanModel>();
    expect(plan.count, 6);
    await shot('04-plan-before');
    await key('details-remove-plan');
    await shot('05-remove-dialog');
    await key('confirm-remove-plan');
    expect(plan.count, 5);
    expect(find.byKey(const Key('race-in-plan')), findsNothing);
    await shot('06-plan-after-remove');
    await route('/plan');
    await shot('07-plan-five');
    await route('/races/r4/participate');
    await choose('run-distance', '10.0 км');
    await fill('run-pace', '5:30');
    await choose('run-visibility', 'Участникам забега');
    await top();
    await shot('08-participation-valid');
    await key('submit-form');
    expect(plan.count, 6);
    expect(plan.forRace('r4')!.distance, 10);
    await top();
    await shot('09-plan-restored');
    await route('/plan');
    await shot('10-plan-six');

    await route('/profile/edit');
    await fill('profile-name', 'Hamuev Oleg');
    await fill(
      'profile-bio',
      'Бегаю по городу и тропам. Люблю новые маршруты и поездки вместе.',
    );
    await fill('profile-pace', '5:30');
    await fill('profile-goal', '10');
    await top();
    await key('avatar-2');
    await top();
    await shot('11-profile-edit');
    await tester.ensureVisible(find.byKey(const Key('profile-goal')));
    await shot('12-profile-goal');
    await key('profile-submit');
    await top();
    await shot('13-profile-saved');
    await tap(find.text('Тёмная'));
    await top();
    await shot('14-profile-dark');
    await tap(find.text('Светлая'));

    await failure(true);
    await route('/races');
    await key('reload-races');
    expect(find.byType(ErrorView), findsOneWidget);
    await route('/home');
    await shot('15-home-error');
    await key('retry');
    expect(find.byType(ErrorView), findsOneWidget);
    await failure(false);
    await route('/home');
    await key('retry');
    expect(find.byType(ErrorView), findsNothing);
    await shot('16-home-recovered');

    await route('/transfers/r3/offer');
    await fill('trip-name', 'Oleg Hamuev');
    await choose('trip-city', 'Chișinău');
    await fill('trip-pickup', 'Circ');
    await fill('trip-time', '06:30');
    await fill('trip-seats', '3');
    await fill('trip-price', '100');
    await fill('trip-phone', '+37360000000');
    await top();
    await shot('17-driver-valid');
    await failure(true);
    await route('/transfers/r3/offer');
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('trip-name')))
          .controller!
          .text,
      'Oleg Hamuev',
    );
    await key('submit-form');
    expect(
      router.routeInformationProvider.value.uri.path,
      '/transfers/r3/offer',
    );
    await shot('18-driver-error');
    await failure(false);
    await route('/transfers/r3/offer');
    await key('submit-form');
    expect(router.routeInformationProvider.value.uri.path, '/transfers/r3');
    await tester.scrollUntilVisible(
      find.text('Oleg Hamuev'),
      300,
      scrollable: getList(),
    );
    await shot('19-driver-created');
    await route('/profile');
    await shot('20-profile-final');
    expect(tester.takeException(), isNull);
  });
}
