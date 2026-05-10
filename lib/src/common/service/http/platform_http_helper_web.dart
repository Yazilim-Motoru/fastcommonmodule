import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'fast_http_response.dart';

@JS('fetch')
external JSPromise _fetch(JSString url, [JSObject? init]);

/// Web implementation of HTTP helper using standard JS fetch API via dart:js_interop
/// This ensures full WASM compatibility without needing dart:html or package:web
class PlatformHttpHelper {
  static Future<FastHttpResponse> send(
    String method,
    Uri url, {
    Map<String, String>? headers,
    String? body,
  }) async {
    final init = JSObject();
    init.setProperty('method'.toJS, method.toJS);

    if (headers != null) {
      final jsHeaders = JSObject();
      headers.forEach((key, value) {
        jsHeaders.setProperty(key.toJS, value.toJS);
      });
      init.setProperty('headers'.toJS, jsHeaders);
    }

    if (body != null) {
      init.setProperty('body'.toJS, body.toJS);
    }

    try {
      final promise = _fetch(url.toString().toJS, init);
      final responseObj = await promise.toDart as JSObject;

      final statusJS = responseObj.getProperty('status'.toJS);
      final status = (statusJS as JSNumber).toDartInt;

      final textPromise = responseObj.callMethod('text'.toJS) as JSPromise;
      final textJS = await textPromise.toDart as JSString;

      return FastHttpResponse(status, textJS.toDart);
    } catch (e) {
      throw Exception('Network error during fetch: $e');
    }
  }
}
