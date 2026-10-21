import 'package:flutter_test/flutter_test.dart';
import 'package:run_baza/data/entity.dart';
import 'package:run_baza/data/mock_repositories.dart';
import 'package:run_baza/data/plan_entry.dart';
import 'package:run_baza/data/repository.dart';
import 'package:run_baza/data/result.dart';

Future<void> checkCrud<T extends Entity>(Repository<T> repository) async {
  final initial = (await repository.fetchAll() as Ok<List<T>>).value;
  expect(initial, isNotEmpty);
  expect(() => initial.clear(), throwsUnsupportedError);
  final draft = initial.first;
  final created = (await repository.create(draft) as Ok<T>).value;
  expect(created.id, isNot(draft.id));
  expect((await repository.fetchById(created.id) as Ok<T>).value, created);
  expect(await repository.update(created), isA<Ok<T>>());
  expect(await repository.delete(created.id), isA<Ok<void>>());
  expect(await repository.fetchById(created.id), isA<Err<T>>());
  expect(await repository.update(created), isA<Err<T>>());
  expect(await repository.delete(created.id), isA<Err<void>>());
  expect(
    (await repository.fetchAll() as Ok<List<T>>).value.length,
    initial.length,
  );
}

void main() {
  test('Every repository implements CRUD and reports missing IDs', () async {
    final failure = MockFailure();
    await checkCrud(MockRaceRepository(failure, latency: Duration.zero));
    await checkCrud(MockPlanRepository(failure, latency: Duration.zero));
    await checkCrud(MockOfferRepository(failure, latency: Duration.zero));
    await checkCrud(MockRequestRepository(failure, latency: Duration.zero));
    await checkCrud(MockProfileRepository(failure, latency: Duration.zero));
  });

  test(
    'A shared failure rejects reads and writes without changing data',
    () async {
      final failure = MockFailure();
      final repo = MockPlanRepository(failure, latency: Duration.zero);
      final races = MockRaceRepository(failure, latency: Duration.zero);
      final before = (await repo.fetchAll() as Ok<List<PlanEntry>>).value;
      repo.simulateError = true;
      expect(await races.fetchAll(), isA<Err>());
      expect(await repo.fetchAll(), isA<Err>());
      expect(await repo.fetchById(before.first.id), isA<Err>());
      expect(await repo.create(before.first), isA<Err>());
      expect(
        await repo.update(before.first.copyWith(pace: '5:20')),
        isA<Err>(),
      );
      expect(await repo.delete(before.first.id), isA<Err>());
      repo.simulateError = false;
      final after = (await repo.fetchAll() as Ok<List<PlanEntry>>).value;
      expect(after, before);
    },
  );

  test('Concurrent creates get different IDs and keep both records', () async {
    final repo = MockPlanRepository(MockFailure(), latency: Duration.zero);
    final results = await Future.wait([
      repo.create(const PlanEntry('r5', 1)),
      repo.create(const PlanEntry('r8', 2)),
    ]);
    final ids = results.map((r) => (r as Ok<PlanEntry>).value.id).toSet();
    expect(ids.length, 2);
    expect((await repo.fetchAll() as Ok<List<PlanEntry>>).value.length, 8);
  });

  test(
    'Repositories return independent snapshots and immutable race distances',
    () async {
      final repo = MockRaceRepository(MockFailure(), latency: Duration.zero);
      final snapshot = (await repo.fetchAll() as Ok).value;
      expect(() => snapshot.first.distances.add(99.0), throwsUnsupportedError);
      await repo.delete(snapshot.first.id);
      expect(snapshot.length, 8);
      expect((await repo.fetchAll() as Ok).value.length, 7);
      final fresh = MockRaceRepository(MockFailure(), latency: Duration.zero);
      expect((await fresh.fetchAll() as Ok).value.length, 8);
    },
  );

  testWidgets('Mock latency leaves a visible loading interval', (tester) async {
    final repo = MockPlanRepository(MockFailure());
    var completed = false;
    final pending = repo.fetchAll().then((_) => completed = true);
    await tester.pump(const Duration(milliseconds: 799));
    expect(completed, isFalse);
    await tester.pump(const Duration(milliseconds: 1));
    await pending;
    expect(completed, isTrue);
  });
}
