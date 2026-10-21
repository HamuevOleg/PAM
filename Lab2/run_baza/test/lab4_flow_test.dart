import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:run_baza/data/mock_repositories.dart';
import 'package:run_baza/models/plan_model.dart';
import 'package:run_baza/models/profile_model.dart';
import 'package:run_baza/widgets/data_status.dart';

import 'navigation_forms_test.dart' show launch, fill, select, tapVisible;

void main() {
  testWidgets(
    'Removing and restoring a plan entry updates details, badge and profile',
    (tester) async {
      final router = await launch(tester, '/races/r4');
      final model = tester
          .element(find.byKey(const Key('details-remove-plan')))
          .read<PlanModel>();
      final count = model.count;
      await tapVisible(tester, find.byKey(const Key('details-remove-plan')));
      await tapVisible(tester, find.byKey(const Key('confirm-remove-plan')));
      expect(model.count, count - 1);
      expect(find.byKey(const Key('race-in-plan')), findsNothing);
      expect(
        (tester.widget<Badge>(find.byKey(const Key('plan-badge'))).label!
                as Text)
            .data,
        '${count - 1}',
      );
      router.go('/profile');
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const Key('profile-plan-count'))).data,
        '${count - 1} / 8',
      );
      router.go('/races/r4/participate');
      await tester.pumpAndSettle();
      await select(tester, 'run-distance', '5.0 км');
      await fill(tester, 'run-pace', '5:40');
      await select(tester, 'run-visibility', 'Участникам забега');
      await tapVisible(tester, find.byKey(const Key('submit-form')));
      expect(model.count, count);
      expect(model.forRace('r4')!.pace, '5:40');
      expect(model.forRace('r4')!.id, startsWith('p'));
      expect(find.byKey(const Key('race-in-plan')), findsOneWidget);
      router.go('/plan');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(ValueKey(model.forRace('r4')!.id)),
        400,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.byKey(ValueKey(model.forRace('r4')!.id)), findsOneWidget);
    },
  );

  testWidgets('The profile failure switch controls catalog errors and retry', (
    tester,
  ) async {
    final router = await launch(tester, '/profile');
    await tapVisible(tester, find.byKey(const Key('diagnostics')));
    await tapVisible(tester, find.byKey(const Key('simulate-error')));
    router.go('/races');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reload-races')));
    await tester.pump();
    expect(find.byType(LoadingView), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(ErrorView), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('retry')));
    expect(find.byType(ErrorView), findsOneWidget);
    router.go('/profile');
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('simulate-error')));
    await tapVisible(tester, find.byKey(const Key('retry')));
    router.go('/races');
    await tester.pumpAndSettle();
    expect(find.byType(ErrorView), findsNothing);
    expect(find.byKey(const ValueKey('r1')), findsOneWidget);
  });

  testWidgets(
    'A failed profile save keeps input, then retry updates the passport',
    (tester) async {
      final router = await launch(tester, '/profile/edit');
      final context = tester.element(find.byKey(const Key('profile-name')));
      final repository = context.read<MockRaceRepository>();
      final model = context.read<ProfileModel>();
      final before = model.profile!.name;
      await fill(tester, 'profile-name', 'Oleg Runner');
      await fill(tester, 'profile-bio', 'Trail running and new places.');
      await fill(tester, 'profile-goal', '12');
      repository.simulateError = true;
      await tapVisible(tester, find.byKey(const Key('profile-submit')));
      expect(router.routeInformationProvider.value.uri.path, '/profile/edit');
      expect(model.profile!.name, before);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('profile-name')))
            .controller!
            .text,
        'Oleg Runner',
      );
      expect(
        find.text('Не удалось выполнить запрос. Попробуйте ещё раз.'),
        findsOneWidget,
      );
      repository.simulateError = false;
      await tapVisible(tester, find.byKey(const Key('profile-submit')));
      expect(router.routeInformationProvider.value.uri.path, '/profile');
      expect(model.profile!.name, 'Oleg Runner');
      expect(model.profile!.seasonGoal, 12);
      expect(find.text('Oleg Runner'), findsOneWidget);
    },
  );

  testWidgets(
    'Invalid profile goals are rejected and theme changes affect the app',
    (tester) async {
      final router = await launch(tester, '/profile/edit');
      await fill(tester, 'profile-goal', '0');
      await tapVisible(tester, find.byKey(const Key('profile-submit')));
      expect(find.text('Укажите от 1 до 52 стартов'), findsOneWidget);
      await fill(tester, 'profile-goal', '53');
      await tapVisible(tester, find.byKey(const Key('profile-submit')));
      expect(find.text('Укажите от 1 до 52 стартов'), findsOneWidget);
      await fill(tester, 'profile-goal', '10');
      await tapVisible(tester, find.byKey(const Key('profile-submit')));
      await tapVisible(tester, find.text('Тёмная'));
      expect(
        Theme.of(tester.element(find.text('Тёмная'))).brightness,
        Brightness.dark,
      );
      router.go('/races');
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.text('Календарь забегов'))).brightness,
        Brightness.dark,
      );
    },
  );
}
