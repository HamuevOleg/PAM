import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:run_baza/main.dart';
import 'package:run_baza/router.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Register on iPhone and display the session profile', (
    tester,
  ) async {
    final router = createRouter();
    await tester.pumpWidget(RunBazaApp(router: router));
    await tester.pumpAndSettle();
    Future<void> tap(String key) async {
      final target = find.byKey(Key(key));
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    Future<void> fill(String key, String value) async {
      final target = find.byKey(Key(key));
      await tester.ensureVisible(target);
      await tester.enterText(target, value);
      await tester.pumpAndSettle();
    }

    Future<void> shot(String name) async {
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
    }

    await tap('login-register');
    expect(find.byKey(const Key('register-submit')), findsOneWidget);
    await shot('20-registration');
    await tap('register-submit');
    expect(find.byKey(const Key('register-submit')), findsOneWidget);
    expect(find.text('Введите от 2 до 60 символов'), findsOneWidget);
    await shot('21-registration-errors');
    await fill('register-name', 'Oleg Hamuev');
    await fill('register-email', 'oleg@example.com');
    await fill('register-password', 'runbaza26');
    await fill('register-confirmation', 'runbaza27');
    await tap('register-submit');
    expect(find.text('Пароли не совпадают'), findsOneWidget);
    await fill('register-confirmation', 'runbaza26');
    await tap('register-submit');
    expect(router.routeInformationProvider.value.uri.path, '/home');
    expect(router.canPop(), isFalse);
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('oleg@example.com'), findsOneWidget);
    await shot('22-registered-profile');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}
