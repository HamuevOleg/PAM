import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:run_baza/data/entity.dart';
import 'package:run_baza/data/mock_repositories.dart';
import 'package:run_baza/data/plan_entry.dart';
import 'package:run_baza/data/repository.dart';
import 'package:run_baza/data/result.dart';
import 'package:run_baza/models/collection_model.dart';
import 'package:run_baza/models/plan_model.dart';

class Item implements Entity {
  @override
  final String id;
  const Item(this.id);
}

class DeferredRepository implements Repository<Item> {
  final reads = <Completer<Result<List<Item>>>>[];
  final creates = <Completer<Result<Item>>>[];
  @override
  Future<Result<List<Item>>> fetchAll() {
    final result = Completer<Result<List<Item>>>();
    reads.add(result);
    return result.future;
  }

  @override
  Future<Result<Item>> create(Item item) {
    final result = Completer<Result<Item>>();
    creates.add(result);
    return result.future;
  }

  @override
  Future<Result<Item>> fetchById(String id) async => const Err('missing');
  @override
  Future<Result<Item>> update(Item item) async => const Err('missing');
  @override
  Future<Result<void>> delete(String id) async => const Err('missing');
}

void main() {
  test('Loading and all mutations notify every subscriber', () async {
    final failure = MockFailure();
    final model = PlanModel(
      MockPlanRepository(failure, latency: Duration.zero),
    );
    addTearDown(model.dispose);
    final first = <(bool, bool, int)>[];
    final second = <int>[];
    model.addListener(
      () => first.add((model.isLoading, model.isSaving, model.count)),
    );
    model.addListener(() => second.add(model.count));
    await model.load();
    expect(first, [(true, false, 0), (false, false, 6)]);
    expect(() => model.records.clear(), throwsUnsupportedError);
    expect(
      await model.saveForRace(const PlanEntry('r5', 2, distance: 12)),
      isNull,
    );
    final added = model.forRace('r5')!;
    expect(added.id, startsWith('p'));
    expect(model.count, 7);
    expect(await model.saveForRace(added.copyWith(pace: '5:45')), isNull);
    expect(model.forRace('r5')!.pace, '5:45');
    expect(model.count, 7);
    expect(await model.remove(added.id), isNull);
    expect(model.forRace('r5'), isNull);
    expect(model.count, 6);
    expect(second, first.map((value) => value.$3).toList());
    expect(first.where((value) => value.$2).length, 3);
  });

  test('Failed writes keep data and failed loads can be retried', () async {
    final failure = MockFailure();
    final model = PlanModel(
      MockPlanRepository(failure, latency: Duration.zero),
    );
    addTearDown(model.dispose);
    await model.load();
    final before = model.records;
    failure.enabled = true;
    expect(await model.remove(before.first.id), isNotNull);
    expect(await model.saveForRace(const PlanEntry('r5', 1)), isNotNull);
    expect(await model.update(before.first.copyWith(pace: '4:30')), isNotNull);
    expect(model.records, before);
    await model.load();
    expect(model.error, isNotNull);
    expect(model.isLoading, isFalse);
    expect(model.records, before);
    failure.enabled = false;
    await model.load();
    expect(model.error, isNull);
    expect(model.records, before);
  });

  test('A later load wins over an older response', () async {
    final repo = DeferredRepository();
    final model = CollectionModel<Item>(repo);
    addTearDown(model.dispose);
    final old = model.load();
    final latest = model.load();
    repo.reads[1].complete(const Ok([Item('new')]));
    await latest;
    repo.reads[0].complete(const Err('old error'));
    await old;
    expect(model.byId('new'), isNotNull);
    expect(model.error, isNull);
  });

  test(
    'Duplicate submission is rejected and disposal ignores a late result',
    () async {
      final repo = DeferredRepository();
      final model = CollectionModel<Item>(repo);
      final save = model.add(const Item('draft'));
      expect(await model.add(const Item('draft')), isNotNull);
      expect(repo.creates.length, 1);
      model.dispose();
      repo.creates.single.complete(const Ok(Item('assigned')));
      expect(await save, isNotNull);
    },
  );

  test('Disposal while loading never notifies a disposed model', () async {
    final repo = DeferredRepository();
    final model = CollectionModel<Item>(repo);
    final pending = model.load();
    model.dispose();
    repo.reads.single.complete(const Ok([Item('late')]));
    await pending;
  });
}
