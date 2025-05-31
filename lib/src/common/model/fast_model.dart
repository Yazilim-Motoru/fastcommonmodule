import 'dart:math';

/// Abstract base model for data objects.
///
/// Extend this class to provide serialization and dummy data logic for your models.
abstract class FastModel {
  /// Unique identifier for the model.
  final String id;

  /// Creates a [FastModel] instance.
  const FastModel({required this.id});

  /// Converts the model to a JSON map.
  Map<String, dynamic> toJson();

  /// Creates a model from a JSON map.
  ///
  /// Throws [UnimplementedError] if not overridden in a subclass.
  static FastModel fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in subclasses');
  }

  /// Returns a dummy instance of the model with random data.
  ///
  /// Throws [UnimplementedError] if not overridden in a subclass.
  static T dummyModel<T extends FastModel>() {
    throw UnimplementedError('dummyModel must be implemented in subclasses');
  }

  /// Returns a list of dummy instances of the model with random data.
  static List<T> dummyDataList<T extends FastModel>({int count = 5}) {
    return List.generate(count, (_) => dummyModel<T>());
  }

  /// Generates a random string for dummy data.
  static String randomString([int length = 8]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }
}
