import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:run_baza/main.dart';
import 'package:run_baza/router.dart';
import 'package:run_baza/data/session_controller.dart';
import 'package:run_baza/data/token_store.dart';
import 'package:run_baza/models/race_catalog.dart';
import 'package:run_baza/models/plan_model.dart';
import 'package:run_baza/widgets/data_status.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Lab 5 real backend auth CRUD search failure recovery and 401', (
    tester,
  ) async {
    final tokens = TokenStore();
    await tokens.clear();
    final session = SessionController(tokens: tokens);
    await session.restore();
    final router = createRouter(session: session);
    await tester.pumpWidget(RunBazaApp(session: session, router: router));
    await tester.pumpAndSettle();
    Finder scroll() => find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .last;
    Future<void> tap(Finder f) async {
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      if (f.evaluate().isEmpty) {
        await tester.scrollUntilVisible(f, 350, scrollable: scroll());
      }
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(tester.getCenter(f));
      await tester.pump(const Duration(milliseconds: 80));
      await gesture.up();
      await tester.pumpAndSettle();
    }

    Future<void> field(String key, String value) async {
      final f = find.byKey(Key(key));
      if (f.evaluate().isEmpty) {
        await tester.scrollUntilVisible(f, 300, scrollable: scroll());
      }
      await tester.ensureVisible(f);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      final widget = tester.widget(f);
      if (widget is TextFormField && widget.controller != null) {
        // Avoid iOS restoring an old secure-field edit in the test input bridge.
        widget.controller!.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
        await tester.pumpAndSettle();
        expect(widget.controller!.text, value);
      } else {
        await tester.enterText(f, value);
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
      router.go(path);
      await tester.pumpAndSettle();
      if (scroll().evaluate().isNotEmpty) {
        tester.state<ScrollableState>(scroll()).position.jumpTo(0);
        await tester.pumpAndSettle();
      }
    }

    Future<void> control(String action) async {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8091/$action'),
      );
      expect(response.statusCode, 200);
    }

    final email = 'ios-${DateTime.now().millisecondsSinceEpoch}@example.com';
    await shot('01-login');
    await tap(find.byKey(const Key('login-register')));
    await field('register-name', 'Oleg Runner');
    await field('register-email', email);
    await field('register-password', 'runbaza26');
    await field('register-confirmation', 'runbaza26');
    await shot('02-registration');
    await tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();
    expect(session.signedIn, isTrue);
    expect(await tokens.read(), isNotNull);
    await shot('03-home-server');
    await route('/races');
    final catalog = tester
        .element(find.byKey(const Key('race-search')))
        .read<RaceCatalog>();
    expect(catalog.count, 20);
    expect(catalog.hasMore, isTrue);
    await shot('04-page-one');
    final listPosition = tester.state<ScrollableState>(scroll()).position;
    listPosition.jumpTo(listPosition.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(catalog.count, 28);
    await shot('05-page-two');
    await route('/races');
    await field('race-search', 'Iași');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(catalog.records.every((r) => r.city == 'Iași'), isTrue);
    expect(catalog.count, greaterThan(0));
    await shot('06-server-search');
    await tap(find.byTooltip('Очистить поиск'));
    await route('/races/r1/participate');
    await tap(find.byKey(const Key('run-distance')));
    await tap(find.text('10.0 км').last);
    await field('run-pace', '5:40');
    await tap(find.byKey(const Key('submit-form')));
    await tester.pumpAndSettle();
    final plan = tester.element(find.byType(Scaffold).first).read<PlanModel>();
    expect(plan.count, 1);
    expect(plan.records.first.id.length, 36);
    await route('/plan');
    await shot('07-plan-created');
    await route('/profile');
    await shot('08-profile');
    await route('/races');
    await control('stop');
    await tap(find.byKey(const Key('reload-races')));
    expect(find.byType(ErrorView), findsOneWidget);
    await shot('09-server-stopped');
    await control('start');
    await tap(find.byKey(const Key('retry')));
    expect(find.byType(ErrorView), findsNothing);
    await shot('10-retry-restored');
    // Recreate the complete app/session from persisted preferences.
    await tester.pumpWidget(const SizedBox());
    router.dispose();
    session.dispose();
    final restored = SessionController();
    await restored.restore();
    for (var i = 0; i < 100 && !restored.signedIn; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(restored.signedIn, isTrue);
    final router2 = createRouter(session: restored);
    await tester.pumpWidget(RunBazaApp(session: restored, router: router2));
    await tester.pumpAndSettle();
    expect(router2.routeInformationProvider.value.uri.path, '/home');
    await shot('11-token-restored');
    router2.go('/races');
    await tester.pumpAndSettle();
    await control('rotate');
    await tap(find.byKey(const Key('reload-races')));
    await tester.pumpAndSettle();
    expect(router2.routeInformationProvider.value.uri.path, '/login');
    expect(await tokens.read(), isNull);
    await shot('12-expired-session');
    await field('login-email', email);
    await field('login-password', 'wrong123');
    await tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Неверный email или пароль.'), findsOneWidget);
    await shot('13-wrong-password');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await field('login-password', 'runbaza26');
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('login-password')))
          .controller!
          .text,
      'runbaza26',
    );
    await tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    for (var i = 0; i < 100 && !restored.signedIn; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(restored.signedIn, isTrue);
    router2.go('/plan');
    await tester.pumpAndSettle();
    expect(
      tester.element(find.byType(Scaffold).first).read<PlanModel>().count,
      1,
    );
    await shot('14-persisted-plan');
    router2.go('/profile');
    await tester.pumpAndSettle();
    await tap(find.byKey(const Key('logout')));
    await tap(find.widgetWithText(FilledButton, 'Выйти'));
    await tester.pumpAndSettle();
    expect(await tokens.read(), isNull);
    expect(router2.routeInformationProvider.value.uri.path, '/login');
    await shot('15-logout');
    await field('login-email', email);
    await field('login-password', 'runbaza26');
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('login-password')))
          .controller!
          .text,
      'runbaza26',
    );
    await tap(find.byKey(const Key('login-submit')));
    for (var i = 0; i < 100 && !restored.signedIn; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(restored.signedIn, isTrue);
    await tester.pumpWidget(const SizedBox());
    router2.dispose();
    restored.dispose();
  });
}
