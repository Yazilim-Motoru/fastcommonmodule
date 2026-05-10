/// Standardized HTTP response to abstract away platform-specific details.
class FastHttpResponse {
  /// HTTP status code
  final int statusCode;

  /// Response body as string
  final String body;

  const FastHttpResponse(this.statusCode, this.body);
}
