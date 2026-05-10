import 'dart:async';

/// A lightweight, zero-dependency Event Bus (Pub-Sub system).
///
/// Allows decoupling of application components by letting them
/// communicate via strongly-typed events instead of direct references.
class FastEventBus {
  final StreamController<dynamic> _streamController;

  /// Private constructor
  FastEventBus._() : _streamController = StreamController<dynamic>.broadcast();

  /// Global singleton instance
  static final FastEventBus instance = FastEventBus._();

  /// Listens for events of type [T].
  ///
  /// Returns a [Stream] that you can listen to.
  /// Example:
  /// ```dart
  /// FastEventBus.instance.on<UserLoggedInEvent>().listen((event) {
  ///   print(event.user.name);
  /// });
  /// ```
  Stream<T> on<T>() {
    if (T == dynamic) {
      return _streamController.stream as Stream<T>;
    } else {
      return _streamController.stream.where((event) => event is T).cast<T>();
    }
  }

  /// Fires a new event to all registered listeners.
  ///
  /// Example:
  /// ```dart
  /// FastEventBus.instance.fire(UserLoggedInEvent(user));
  /// ```
  void fire<T>(T event) {
    _streamController.add(event);
  }

  /// Closes the event bus and destroys the underlying stream.
  /// Only call this when the application is completely shutting down.
  void destroy() {
    _streamController.close();
  }
}
