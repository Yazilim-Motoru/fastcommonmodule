import '../model/fast_model.dart';
import '../model/fast_response.dart';

/// Abstract base class for repositories.
///
/// Implement this class to provide data access logic for your models.
abstract class BaseRepository<T extends FastModel> {
  /// Retrieves all items.
  Future<FastResponse<List<T>>> getAll();

  /// Retrieves an item by its [id].
  Future<FastResponse<T?>> getById(String id);

  /// Adds a new [item].
  Future<FastResponse<void>> add(T item);

  /// Updates an existing [item].
  Future<FastResponse<void>> update(T item);

  /// Deletes an item by its [id].
  Future<FastResponse<void>> delete(String id);
}
