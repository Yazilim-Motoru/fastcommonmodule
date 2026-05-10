/// Represents the current state of the Circuit Breaker
enum FastCircuitBreakerState {
  /// Normal operation. Requests are allowed to pass through.
  closed,

  /// Circuit is open due to consecutive failures. Requests are blocked immediately.
  open,

  /// Testing mode. A limited number of requests are allowed to check if the underlying issue is resolved.
  halfOpen,
}
