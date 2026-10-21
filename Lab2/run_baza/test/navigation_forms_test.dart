import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:run_baza/main.dart';
import 'package:run_baza/router.dart';
import 'package:run_baza/forms/validators.dart';
import 'package:provider/provider.dart';
import 'package:run_baza/models/transfer_models.dart';
import 'package:run_baza/models/plan_model.dart';
import 'package:run_baza/screens/race_details_screen.dart';

Future<GoRouter> launch(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(430, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = createRouter(initialLocation: location);
  addTearDown(router.dispose);
  await tester.pumpWidget(RunBazaApp(router: router));
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  return router;
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      400,
      scrollable: find.byType(Scrollable).last,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> fill(WidgetTester tester, String key, String text) async {
  final field = find.byKey(Key(key));
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
}

Future<void> select(WidgetTester tester, String key, String value) async {
  await tapVisible(tester, find.byKey(Key(key)));
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}

void main() {
  test('Validation boundaries and malformed inputs', () {
    for (final bad in ['', 'a', 'a@', 'a b@example.com']) {
      expect(Validators.email(bad), isNotNull);
    }
    expect(Validators.email('runner@example.com'), isNull);
    expect(Validators.password('12345'), isNotNull);
    expect(Validators.password('123456'), isNull);
    for (final bad in ['', '0', '9', '-1', '1.5', 'two']) {
      expect(Validators.seats(bad), isNotNull);
    }
    expect(Validators.seats('8'), isNull);
    expect(Validators.price('0'), isNull);
    expect(Validators.price('5000'), isNull);
    expect(Validators.price('5001'), isNotNull);
    expect(Validators.time('23:59'), isNull);
    expect(Validators.time('24:00'), isNotNull);
    expect(Validators.time('6:90'), isNotNull);
    expect(Validators.pace('2:59'), isNotNull);
    expect(Validators.pace('15:01'), isNotNull);
    expect(Validators.pace('3:00'), isNull);
    expect(Validators.pace('15:00'), isNull);
    expect(Validators.phone('+37360000000'), isNull);
    expect(Validators.phone('373+60000000'), isNotNull);
  });
  testWidgets(
    'Small viewport validates off-screen dropdown and retains its error',
    (tester) async {
      final router = await launch(tester, '/transfers/r1/offer');
      tester.view.physicalSize = const Size(320, 600);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('submit-form')));
      expect(
        router.routeInformationProvider.value.uri.path,
        '/transfers/r1/offer',
      );
      expect(find.text('Выберите город выезда'), findsOneWidget);
      expect(find.text('От 1 до 8 мест'), findsOneWidget);
      expect(find.text('От 0 до 5000 MDL'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, 1200));
      await tester.pumpAndSettle();
      expect(find.text('Выберите город выезда'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Login validates, then go removes login from history', (
    tester,
  ) async {
    final router = await launch(tester, '/login');
    expect(find.byType(NavigationBar), findsNothing);
    await tapVisible(tester, find.byKey(const Key('login-submit')));
    expect(find.text('Не менее 6 символов'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/login');
    await fill(tester, 'login-email', 'runner@example.com');
    await fill(tester, 'login-password', 'abcdef');
    await tapVisible(tester, find.byKey(const Key('login-submit')));
    expect(router.routeInformationProvider.value.uri.path, '/home');
    expect(router.canPop(), isFalse);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
  testWidgets('Branches retain filter, scroll, detail ID and back stack', (
    tester,
  ) async {
    final router = await launch(tester, '/races');
    await fill(tester, 'race-search', 'Iași');
    await tapVisible(tester, find.byKey(const ValueKey('r3')));
    expect(
      tester.widget<RaceDetailsScreen>(find.byType(RaceDetailsScreen)).id,
      'r3',
    );
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Забеги'));
    await tester.pumpAndSettle();
    expect(find.byType(RaceDetailsScreen), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('race-search')))
          .controller!
          .text,
      'Iași',
    );
    expect(find.byKey(const ValueKey('r1')), findsNothing);
    await fill(tester, 'race-search', '');
    final list = find.byType(ListView);
    await tester.drag(list, const Offset(0, -550));
    await tester.pumpAndSettle();
    final offset = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;
    await tester.tap(find.text('Мой план'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Забеги'));
    await tester.pumpAndSettle();
    expect(
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .pixels,
      closeTo(offset, 1),
    );
  });
  for (final path in [
    '/races/missing',
    '/races/r1/distance/abc',
    '/races/r1/distance/42.2',
    '/no-such-page',
    '/transfers/unknown/offer',
  ]) {
    testWidgets('Bad link $path is recoverable', (tester) async {
      await launch(tester, path);
      expect(find.text('Страница не найдена'), findsOneWidget);
      await tapVisible(tester, find.text('Открыть календарь'));
      expect(find.text('Календарь забегов'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final driver in [true, false]) {
    testWidgets(
      'Trip form driver=$driver rejects errors, writes valid values through the repository',
      (tester) async {
        final path = '/transfers/r1/${driver ? 'offer' : 'request'}';
        final router = await launch(tester, path);
        final context = tester.element(find.byKey(const Key('submit-form')));
        final offers = context.read<OfferModel>();
        final requests = context.read<RequestModel>();
        final count = offers.count + requests.count;
        await tapVisible(tester, find.byKey(const Key('submit-form')));
        expect(router.routeInformationProvider.value.uri.path, path);
        expect(find.text('От 1 до 8 мест'), findsOneWidget);
        await fill(tester, 'trip-name', 'Test Runner');
        await select(tester, 'trip-city', 'Chișinău');
        await fill(tester, 'trip-pickup', 'Central square');
        await fill(tester, 'trip-time', '06:30');
        await fill(tester, 'trip-seats', '2');
        if (driver) await fill(tester, 'trip-price', '0');
        await fill(tester, 'trip-phone', '+37360000000');
        await tapVisible(tester, find.byKey(const Key('submit-form')));
        expect(router.routeInformationProvider.value.uri.path, '/transfers/r1');
        expect(find.byType(SnackBar), findsOneWidget);
        expect(offers.count + requests.count, count + 1);
        if (driver) {
          expect(offers.records.last.phone, '+37360000000');
          expect(offers.records.last.driverName, 'Test Runner');
        } else {
          expect(requests.records.last.phone, '+37360000000');
          expect(requests.records.last.departureTime, '06:30');
        }
      },
    );
  }
  testWidgets('Participation edits a saved entry after validating its fields', (
    tester,
  ) async {
    final router = await launch(tester, '/races/r1/participate');
    final model = tester
        .element(find.byKey(const Key('submit-form')))
        .read<PlanModel>();
    final before = model.count;
    await fill(tester, 'run-pace', '');
    await tapVisible(tester, find.byKey(const Key('submit-form')));
    expect(find.text(Validators.pace('')!), findsOneWidget);
    await select(tester, 'run-distance', '21.1 км');
    await fill(tester, 'run-pace', '6:00');
    await select(tester, 'run-visibility', 'Только мне');
    await tapVisible(tester, find.byKey(const Key('submit-form')));
    expect(router.routeInformationProvider.value.uri.path, '/races/r1');
    expect(find.text('Старт сохранён в плане'), findsOneWidget);
    expect(model.count, before);
    expect(model.forRace('r1')!.distance, 21.1);
  });
  testWidgets('Profile validation and logout: cancel, dismiss, confirm', (
    tester,
  ) async {
    final router = await launch(tester, '/profile/edit');
    await fill(tester, 'profile-name', '');
    await tapVisible(tester, find.byKey(const Key('profile-submit')));
    expect(find.text('Введите от 2 до 60 символов'), findsOneWidget);
    await fill(tester, 'profile-name', 'Test Runner');
    await tapVisible(tester, find.byKey(const Key('profile-submit')));
    expect(find.text('Профиль сохранён'), findsOneWidget);
    expect(find.text('Test Runner'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tapVisible(tester, find.byKey(const Key('logout')));
    await tester.tap(find.text('Остаться'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/profile');
    await tapVisible(tester, find.byKey(const Key('logout')));
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/profile');
    await tapVisible(tester, find.byKey(const Key('logout')));
    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/login');
    expect(router.canPop(), isFalse);
  });
}
