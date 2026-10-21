import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run_baza/forms/validators.dart';

import 'navigation_forms_test.dart' show launch, fill, tapVisible;

void main() {
  test('Registration password and exact confirmation boundaries', () {
    for (final bad in ['', '1234567', '        ', '  abcdef  ']) {
      expect(Validators.registrationPassword(bad), isNotNull);
    }
    expect(Validators.registrationPassword('runner26'), isNull);
    expect(Validators.confirmPassword('', 'runner26'), 'Повторите пароль');
    expect(
      Validators.confirmPassword('runner26 ', 'runner26'),
      'Пароли не совпадают',
    );
    expect(Validators.confirmPassword('runner26', 'runner26'), isNull);
  });

  testWidgets('Registration returns to login without losing typed email', (
    tester,
  ) async {
    final router = await launch(tester, '/login');
    await fill(tester, 'login-email', 'runner@example.com');
    await tapVisible(tester, find.byKey(const Key('login-register')));
    expect(find.byKey(const Key('register-submit')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tapVisible(tester, find.byKey(const Key('register-login')));
    expect(router.routeInformationProvider.value.uri.path, '/login');
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('login-email')))
          .controller!
          .text,
      'runner@example.com',
    );
  });

  testWidgets('Direct registration link has a working back action', (
    tester,
  ) async {
    final router = await launch(tester, '/register');
    await tester.tap(find.byKey(const Key('register-back')));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/login');
  });

  testWidgets('Small screen validates every off-screen registration field', (
    tester,
  ) async {
    await launch(tester, '/register');
    tester.view.physicalSize = const Size(320, 600);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('register-submit')));
    expect(find.byKey(const Key('register-submit')), findsOneWidget);
    expect(find.text('Введите от 2 до 60 символов'), findsOneWidget);
    expect(
      find.text('Введите e-mail, например runner@example.com'),
      findsOneWidget,
    );
    expect(find.text('Повторите пароль').last, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Changing original password invalidates a previously matching confirmation',
    (tester) async {
      final router = await launch(tester, '/register');
      await fill(tester, 'register-name', 'Test Runner');
      await fill(tester, 'register-email', 'runner@example.com');
      await fill(tester, 'register-password', 'runner26');
      await fill(tester, 'register-confirmation', 'runner26');
      await fill(tester, 'register-password', 'different26');
      await tapVisible(tester, find.byKey(const Key('register-submit')));
      expect(find.byKey(const Key('register-submit')), findsOneWidget);
      expect(find.text('Пароли не совпадают'), findsOneWidget);
      await fill(tester, 'register-confirmation', 'different26');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/home');
      expect(router.canPop(), isFalse);
      await tester.tap(find.text('Профиль').last);
      await tester.pumpAndSettle();
      expect(find.text('runner@example.com'), findsOneWidget);
      expect(find.text('Test Runner'), findsOneWidget);
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'Registration supports $brightness, large text and password visibility',
      (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        await launch(tester, '/register');
        tester.view.physicalSize = const Size(320, 650);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await fill(tester, 'register-password', 'runner26');
        expect(
          tester
              .widget<TextField>(
                find.descendant(
                  of: find.byKey(const Key('register-password')),
                  matching: find.byType(TextField),
                ),
              )
              .obscureText,
          isTrue,
        );
        await tapVisible(
          tester,
          find.byKey(const Key('register-password-visibility')),
        );
        expect(
          tester
              .widget<TextField>(
                find.descendant(
                  of: find.byKey(const Key('register-password')),
                  matching: find.byType(TextField),
                ),
              )
              .obscureText,
          isFalse,
        );
        expect(
          tester
              .widget<TextField>(
                find.descendant(
                  of: find.byKey(const Key('register-confirmation')),
                  matching: find.byType(TextField),
                ),
              )
              .obscureText,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
