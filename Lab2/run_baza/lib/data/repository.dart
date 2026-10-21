import 'entity.dart';
import 'result.dart';

abstract interface class Repository<T extends Entity> {
  Future<Result<List<T>>> fetchAll();
  Future<Result<T>> fetchById(String id);
  Future<Result<T>> create(T draft);
  Future<Result<T>> update(T record);
  Future<Result<void>> delete(String id);
}
