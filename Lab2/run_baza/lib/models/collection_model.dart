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
  static const pageSize = 20;
  int _page = 1;
  String _search = '', _country = '';
  bool _loadingMore = false, _hasMore = false;
  String? _moreError;
  final Map<String, T> _known = {};
  bool get loadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String? get moreError => _moreError;
  String get search => _search;
  String get country => _country;

  List<T> get records => List.unmodifiable(_records);
  @override
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  @override
  String? get error => _error;
  int get count => _records.length;
  T? byId(String id) => _known[id];

  @override
  Future<void> load({String? search, String? country}) async {
    if (_disposed || _saving) return;
    _search = search ?? _search;
    _country = country ?? _country;
    _page = 1;
    _hasMore = false;
    _loadingMore = false;
    _moreError = null;
    final request = ++_revision;
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _repository.fetchAll(
      page: 1,
      limit: pageSize,
      search: _search,
      country: _country,
    );
    if (_disposed || request != _revision) return;
    switch (result) {
      case Ok(:final value):
        _records = List.of(value);
        for (final item in value) {
          _known[item.id] = item;
        }
        _hasMore = value.length == pageSize;
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_disposed || _loading || _saving || _loadingMore || !_hasMore) return;
    final revision = _revision;
    _loadingMore = true;
    _moreError = null;
    notifyListeners();
    final result = await _repository.fetchAll(
      page: _page + 1,
      limit: pageSize,
      search: _search,
      country: _country,
    );
    if (_disposed || revision != _revision) return;
    switch (result) {
      case Ok(:final value):
        final ids = _records.map((r) => r.id).toSet();
        _records = [..._records, ...value.where((r) => !ids.contains(r.id))];
        for (final item in value) {
          _known[item.id] = item;
        }
        _page++;
        _hasMore = value.length == pageSize;
      case Err(:final msg):
        _moreError = msg;
    }
    _loadingMore = false;
    notifyListeners();
  }

  Future<String?> add(T draft) =>
      _write(() => _repository.create(draft), (created) {
        _known[created.id] = created;
        _records = [..._records, created];
      });

  Future<String?> update(T record) =>
      _write(() => _repository.update(record), (saved) {
        _known[saved.id] = saved;
        _records = [
          for (final item in _records)
            if (item.id == saved.id) saved else item,
        ];
      });

  Future<String?> remove(String id) =>
      _write(() => _repository.delete(id), (_) {
        _known.remove(id);
        _records = _records.where((r) => r.id != id).toList();
      });

  Future<String?> _write<R>(
    Future<Result<R>> Function() operation,
    void Function(R) apply,
  ) async {
    if (_disposed) return 'Экран уже закрыт.';
    if (_saving || _loading) return 'Дождитесь завершения текущего действия.';
    _saving = true;
    _loadingMore = false;
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
