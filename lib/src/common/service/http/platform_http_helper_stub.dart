import 'fast_http_response.dart';

/// Stub implementation for unsupported platforms
class PlatformHttpHelper {
  static Future<FastHttpResponse> send(
    String method,
    Uri url, {
    Map<String, String>? headers,
    String? body,
  }) async {
    throw UnsupportedError('HTTP is not supported on this platform');
  }
}
