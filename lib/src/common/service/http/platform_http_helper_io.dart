import 'dart:io';
import 'dart:convert';
import 'fast_http_response.dart';

/// IO implementation of HTTP helper using dart:io
class PlatformHttpHelper {
  static Future<FastHttpResponse> send(
    String method,
    Uri url, {
    Map<String, String>? headers,
    String? body,
  }) async {
    final client = HttpClient();
    try {
      final request = await _openRequest(client, method, url);

      headers?.forEach((key, value) {
        request.headers.set(key, value);
      });

      if (body != null) {
        final bytes = utf8.encode(body);
        request.headers
            .set(HttpHeaders.contentLengthHeader, bytes.length.toString());
        request.add(bytes);
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      return FastHttpResponse(response.statusCode, responseBody);
    } finally {
      client.close();
    }
  }

  static Future<HttpClientRequest> _openRequest(
      HttpClient client, String method, Uri url) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await client.getUrl(url);
      case 'POST':
        return await client.postUrl(url);
      case 'PUT':
        return await client.putUrl(url);
      case 'DELETE':
        return await client.deleteUrl(url);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }
}
