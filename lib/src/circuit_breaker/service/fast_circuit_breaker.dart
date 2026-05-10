import 'dart:async';
import '../enums/fast_circuit_breaker_state.dart';
import '../model/fast_circuit_breaker_config.dart';
import '../model/fast_circuit_breaker_exception.dart';

/// A robust, zero-dependency Circuit Breaker implementation for fault tolerance.
class FastCircuitBreaker {
  final FastCircuitBreakerConfig config;

  FastCircuitBreakerState _state = FastCircuitBreakerState.closed;
  int _failureCount = 0;
  int _successCount = 0;
  Timer? _halfOpenTimer;

  /// Optional callback triggered when the state changes
  void Function(FastCircuitBreakerState from, FastCircuitBreakerState to)?
      onStateChanged;

  FastCircuitBreaker({
    FastCircuitBreakerConfig? config,
    this.onStateChanged,
  }) : config = config ?? const FastCircuitBreakerConfig();

  /// Returns the current state of the circuit breaker
  FastCircuitBreakerState get state => _state;

  /// Executes an asynchronous action through the circuit breaker.
  /// Throws FastCircuitBreakerException immediately if the circuit is OPEN.
  Future<T> execute<T>(Future<T> Function() action) async {
    if (_state == FastCircuitBreakerState.open) {
      throw const FastCircuitBreakerException();
    }

    try {
      final result = await action();
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
    }
  }

  void _onSuccess() {
    if (_state == FastCircuitBreakerState.halfOpen) {
      _successCount++;
      if (_successCount >= config.successThreshold) {
        _transitionTo(FastCircuitBreakerState.closed);
      }
    } else if (_state == FastCircuitBreakerState.closed) {
      // Reset failure count on a successful call during closed state
      _failureCount = 0;
    }
  }

  void _onFailure() {
    if (_state == FastCircuitBreakerState.halfOpen) {
      // If a failure occurs in half-open state, immediately open the circuit again
      _transitionTo(FastCircuitBreakerState.open);
    } else if (_state == FastCircuitBreakerState.closed) {
      _failureCount++;
      if (_failureCount >= config.failureThreshold) {
        _transitionTo(FastCircuitBreakerState.open);
      }
    }
  }

  void _transitionTo(FastCircuitBreakerState newState) {
    if (_state == newState) return;

    final oldState = _state;
    _state = newState;

    if (newState == FastCircuitBreakerState.open) {
      _halfOpenTimer?.cancel();
      _halfOpenTimer = Timer(config.resetTimeout, () {
        _transitionTo(FastCircuitBreakerState.halfOpen);
      });
    } else if (newState == FastCircuitBreakerState.closed) {
      _failureCount = 0;
      _successCount = 0;
      _halfOpenTimer?.cancel();
    } else if (newState == FastCircuitBreakerState.halfOpen) {
      _successCount = 0;
    }

    try {
      onStateChanged?.call(oldState, newState);
    } catch (_) {
      // Ignore callback errors
    }
  }

  /// Manually reset the circuit breaker to closed state
  void reset() {
    _transitionTo(FastCircuitBreakerState.closed);
  }
}
