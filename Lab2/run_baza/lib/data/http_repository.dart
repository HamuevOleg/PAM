import 'api_client.dart';
import 'entity.dart';
import 'repository.dart';
import 'result.dart';

class HttpRepository<T extends Entity> implements Repository<T> {
  HttpRepository(this.api, this.path, this.fromJson, this.toJson);
  final ApiClient api;
  final String path;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, Object?> Function(T) toJson;

  @override
  Future<Result<List<T>>> fetchAll() => api.request(
    'GET',
    path,
    successStatus: 200,
    decode: (json) {
      final envelope = json as Map<String, dynamic>;
      return (envelope['items'] as List)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    },
  );
  @override
  Future<Result<T>> fetchById(String id) => api.request(
    'GET',
    '$path/${Uri.encodeComponent(id)}',
    successStatus: 200,
    decode: (json) => fromJson(json as Map<String, dynamic>),
  );
  @override
  Future<Result<T>> create(T draft) => api.request(
    'POST',
    path,
    successStatus: 201,
    body: toJson(draft),
    decode: (json) => fromJson(json as Map<String, dynamic>),
  );
  @override
  Future<Result<T>> update(T record) => api.request(
    'PUT',
    '$path/${Uri.encodeComponent(record.id)}',
    successStatus: 200,
    body: toJson(record),
    decode: (json) => fromJson(json as Map<String, dynamic>),
  );
  @override
  Future<Result<void>> delete(String id) => api.request<void>(
    'DELETE',
    '$path/${Uri.encodeComponent(id)}',
    successStatus: 204,
    decode: (_) {},
  );
}
