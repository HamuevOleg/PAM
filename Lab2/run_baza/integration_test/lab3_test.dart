import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:run_baza/main.dart';
import 'package:run_baza/router.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Lab 3 iOS demonstration and report evidence', (tester) async {
    final router = createRouter();
    await tester.pumpWidget(RunBazaApp(router: router));
    Future<void> shot(String name) async {
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
      debugPrint('Captured $name');
    }

    Future<void> route(String path) async {
      router.go(path);
      await tester.pumpAndSettle();
    }

    Future<void> tapKey(String key) async {
      final f = find.byKey(Key(key));
      if (f.evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          f,
          300,
          scrollable: find
              .byWidgetPredicate(
                (widget) =>
                    widget is Scrollable &&
                    widget.axisDirection == AxisDirection.down,
              )
              .last,
        );
      }
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    Future<void> fill(String key, String value) async {
      final f = find.byKey(Key(key));
      await tester.ensureVisible(f);
      await tester.enterText(f, value);
      await tester.pumpAndSettle();
    }

    Future<void> choose(String key, String value) async {
      await tapKey(key);
      await tester.tap(find.text(value).last);
      await tester.pumpAndSettle();
    }

    await shot('01-login');
    await tapKey('login-submit');
    await shot('02-login-errors');
    expect(find.text('Не менее 6 символов'), findsOneWidget);
    await fill('login-email', 'runner@example.com');
    await fill('login-password', 'runbaza26');
    await tapKey('login-submit');
    expect(router.canPop(), isFalse);
    await shot('03-home');
    for (final (path, name) in [
      ('/races', '04-races'),
      ('/transfers', '05-transfers'),
      ('/plan', '06-plan'),
      ('/profile', '07-profile'),
      ('/races/r1', '08-detail-orhei'),
      ('/races/r3', '09-detail-iasi'),
      ('/races/r1/distance/21.1', '10-distance'),
    ]) {
      await route(path);
      await shot(name);
    }
    await route('/races/r1/participate');
    await tapKey('submit-form');
    await shot('11-run-errors');
    await choose('run-distance', '21.1 км');
    await fill('run-pace', '6:00');
    await choose('run-visibility', 'Только мне');
    await shot('12-run-valid');
    await tapKey('submit-form');
    await shot('13-snackbar');
    for (final (mode, name) in [
      ('offer', '14-driver-errors'),
      ('request', '15-passenger-errors'),
    ]) {
      await route('/transfers/r1/$mode');
      await tapKey('submit-form');
      await tester.drag(find.byType(ListView).last, const Offset(0, 900));
      await tester.pumpAndSettle();
      await shot(name);
      if (mode == 'offer') {
        await tester.drag(find.byType(ListView).last, const Offset(0, -700));
        await tester.pumpAndSettle();
        await shot('19-driver-errors-bottom');
      }
    }
    await route('/profile');
    await fill('profile-name', '');
    await tapKey('profile-submit');
    await shot('16-profile-errors');
    await tapKey('logout');
    await shot('17-confirm-logout');
    await tester.tap(find.text('Остаться'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/profile');
    await tapKey('logout');
    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    await route('/races/unknown');
    await shot('18-not-found');
    await route('/home');
    expect(tester.takeException(), isNull);
  });
}
