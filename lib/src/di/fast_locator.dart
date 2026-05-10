/// A lightweight, dependency-free Service Locator (Dependency Injection) container.
///
/// This class allows you to register and retrieve dependencies (singletons or factories)
/// throughout your application without needing external packages like get_it.
class FastLocator {
  static final FastLocator _instance = FastLocator._internal();

  /// Singleton instance of the locator.
  static FastLocator get instance => _instance;

  FastLocator._internal();

  final Map<Type, dynamic> _singletons = {};
  final Map<Type, dynamic Function()> _factories = {};

  /// Registers a singleton instance of type [T].
  ///
  /// The instance will be created once and the same instance will be returned
  /// every time it is requested.
  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  /// Registers a factory function that creates an instance of type [T].
  ///
  /// The factory function will be called every time the dependency is requested,
  /// returning a new instance.
  void registerFactory<T>(T Function() factoryFunc) {
    _factories[T] = factoryFunc;
  }

  /// Retrieves the registered dependency of type [T].
  ///
  /// Throws an [Exception] if the dependency is not registered.
  T get<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }

    throw Exception('Type $T is not registered in FastLocator');
  }

  /// Checks if a dependency of type [T] is registered.
  bool isRegistered<T>() {
    return _singletons.containsKey(T) || _factories.containsKey(T);
  }

  /// Unregisters a dependency of type [T].
  void unregister<T>() {
    _singletons.remove(T);
    _factories.remove(T);
  }

  /// Clears all registered dependencies.
  void reset() {
    _singletons.clear();
    _factories.clear();
  }
}

/// Global convenience function to access the FastLocator.
///
/// Example:
/// ```dart
/// final authService = locate<BaseAuthService>();
/// ```
T locate<T>() => FastLocator.instance.get<T>();
