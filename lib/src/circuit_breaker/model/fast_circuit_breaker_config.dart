/// Configuration for the FastCircuitBreaker
class FastCircuitBreakerConfig {
  /// The number of consecutive failures allowed before the circuit opens
  final int failureThreshold;

  /// The duration to wait in the open state before transitioning to half-open
  final Duration resetTimeout;

  /// In half-open state, how many successful calls are needed to close the circuit
  final int successThreshold;

  const FastCircuitBreakerConfig({
    this.failureThreshold = 5,
    this.resetTimeout = const Duration(seconds: 30),
    this.successThreshold = 1,
  });
}
