import 'package:flutter/foundation.dart';

import '../data/entity.dart';
import '../data/repository.dart';
import '../data/result.dart';

/// Repository-backed state shared by all screens that display this collection.
abstract interface class LoadableState {
  bool get isLoading;
  String? get error;
  Future<void> load();
}

class CollectionModel<T extends Entity> extends ChangeNotifier
    implements LoadableState {
  CollectionModel(this._repository);
  final Repository<T> _repository;
  List<T> _records = const [];
  bool _loading = false, _saving = false, _disposed = false;
  String? _error;
  int _revision = 0;

  List<T> get records => List.unmodifiable(_records);
  @override
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  @override
  String? get error => _error;
  int get count => _records.length;
  T? byId(String id) {
    for (final record in _records) {
      if (record.id == id) return record;
    }
    return null;
  }

  @override
  Future<void> load() async {
    if (_disposed || _saving) return;
    final request = ++_revision;
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.fetchAll();
    if (_disposed || request != _revision) return;
    switch (result) {
      case Ok(:final value):
        _records = List.of(value);
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> add(T draft) => _write(
    () => _repository.create(draft),
    (created) => _records = [..._records, created],
  );

  Future<String?> update(T record) => _write(
    () => _repository.update(record),
    (saved) => _records = [
      for (final item in _records)
        if (item.id == saved.id) saved else item,
    ],
  );

  Future<String?> remove(String id) => _write(
    () => _repository.delete(id),
    (_) => _records = _records.where((r) => r.id != id).toList(),
  );

  Future<String?> _write<R>(
    Future<Result<R>> Function() operation,
    void Function(R) apply,
  ) async {
    if (_disposed) return 'Экран уже закрыт.';
    if (_saving || _loading) return 'Дождитесь завершения текущего действия.';
    _saving = true;
    ++_revision;
    notifyListeners();
    final result = await operation();
    if (_disposed) return 'Экран уже закрыт.';
    String? message;
    switch (result) {
      case Ok(:final value):
        apply(value);
      case Err(:final msg):
        message = msg;
    }
    _saving = false;
    notifyListeners();
    return message;
  }

  @override
  void dispose() {
    _disposed = true;
    ++_revision;
    super.dispose();
  }
}
