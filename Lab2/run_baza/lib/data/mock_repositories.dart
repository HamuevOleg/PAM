import 'entity.dart';
import 'mock_data.dart' as seed;
import 'race.dart';
import 'plan_entry.dart';
import 'transfer.dart';
import 'runner_profile.dart';
import 'repository.dart';
import 'race_repository.dart';
import 'plan_repository.dart';
import 'offer_repository.dart';
import 'request_repository.dart';
import 'profile_repository.dart';
import 'result.dart';

/// Shared only by the mock repositories and the failure demonstration control.
class MockFailure {
  bool enabled = false;
}

class MockRepository<T extends Entity> implements Repository<T> {
  MockRepository(
    Iterable<T> records,
    this._withId,
    this._prefix,
    this.failure, {
    this.latency = const Duration(milliseconds: 800),
  }) : _records = List.of(records);
  final List<T> _records;
  final T Function(T, String) _withId;
  final String _prefix;
  final MockFailure failure;
  final Duration latency;
  int _nextId = 1000;
  bool get simulateError => failure.enabled;
  set simulateError(bool value) => failure.enabled = value;

  Future<bool> _fails() async {
    await Future<void>.delayed(latency);
    return failure.enabled;
  }

  static const _networkError =
      'Не удалось выполнить запрос. Попробуйте ещё раз.';
  static const _missing = 'Запись больше не существует.';

  @override
  Future<Result<List<T>>> fetchAll() async {
    if (await _fails()) return const Err(_networkError);
    return Ok(List.unmodifiable(_records));
  }

  @override
  Future<Result<T>> fetchById(String id) async {
    if (await _fails()) return const Err(_networkError);
    final index = _records.indexWhere((r) => r.id == id);
    return index < 0 ? const Err(_missing) : Ok(_records[index]);
  }

  @override
  Future<Result<T>> create(T draft) async {
    if (await _fails()) return const Err(_networkError);
    String id;
    do {
      id = '$_prefix${_nextId++}';
    } while (_records.any((r) => r.id == id));
    final created = _withId(draft, id);
    _records.add(created);
    return Ok(created);
  }

  @override
  Future<Result<T>> update(T record) async {
    if (await _fails()) return const Err(_networkError);
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index < 0) return const Err(_missing);
    _records[index] = record;
    return Ok(record);
  }

  @override
  Future<Result<void>> delete(String id) async {
    if (await _fails()) return const Err(_networkError);
    final index = _records.indexWhere((r) => r.id == id);
    if (index < 0) return const Err(_missing);
    _records.removeAt(index);
    return const Ok(null);
  }
}

class MockRaceRepository extends MockRepository<Race>
    implements RaceRepository {
  MockRaceRepository(MockFailure failure, {super.latency})
    : super(seed.races, (r, id) => r.copyWith(id: id), 'r', failure);
}

class MockPlanRepository extends MockRepository<PlanEntry>
    implements PlanRepository {
  MockPlanRepository(MockFailure failure, {super.latency})
    : super(seed.plan, (r, id) => r.copyWith(id: id), 'p', failure);
}

class MockOfferRepository extends MockRepository<TransferOffer>
    implements OfferRepository {
  MockOfferRepository(MockFailure failure, {super.latency})
    : super(seed.offers, (r, id) => r.copyWith(id: id), 't', failure);
}

class MockRequestRepository extends MockRepository<SeatRequest>
    implements RequestRepository {
  MockRequestRepository(MockFailure failure, {super.latency})
    : super(seed.requests, (r, id) => r.copyWith(id: id), 's', failure);
}

class MockProfileRepository extends MockRepository<RunnerProfile>
    implements ProfileRepository {
  MockProfileRepository(MockFailure failure, {super.latency})
    : super([seed.runnerProfile], (r, id) => r.copyWith(id: id), 'u', failure);
}
