/// Exception thrown when a request is blocked because the circuit is open.
class FastCircuitBreakerException implements Exception {
  final String message;

  const FastCircuitBreakerException(
      [this.message = 'Service unavailable (Circuit is OPEN)']);

  @override
  String toString() => 'FastCircuitBreakerException: $message';
}
