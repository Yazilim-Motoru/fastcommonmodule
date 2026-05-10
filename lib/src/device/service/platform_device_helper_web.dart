import 'dart:js_interop';
import '../model/fast_device_info.dart';

@JS('window.navigator.userAgent')
external JSString get _userAgent;

@JS('window.navigator.language')
external JSString get _language;

@JS('window.navigator.platform')
external JSString get _platform;

@JS('window.navigator.hardwareConcurrency')
external JSNumber? get _hardwareConcurrency;

/// Web implementation of device helper using standard JS navigator API
class PlatformDeviceHelper {
  static FastDeviceInfo getDeviceInfo() {
    String ua = '';
    String lang = 'en-US';
    String plat = 'web';
    int processors = 1;

    try {
      ua = _userAgent.toDart;
    } catch (_) {}

    try {
      lang = _language.toDart;
    } catch (_) {}

    try {
      plat = _platform.toDart;
    } catch (_) {}

    try {
      if (_hardwareConcurrency != null) {
        processors = _hardwareConcurrency!.toDartInt;
      }
    } catch (_) {}

    return FastDeviceInfo(
      os: _getOsFromUserAgent(ua, plat),
      osVersion: 'Web Browser',
      processorCount: processors,
      language: lang,
      isWeb: true,
      deviceId: ua, // User agent serves as a fallback ID for web
    );
  }

  static String _getOsFromUserAgent(String ua, String platform) {
    final lowerUa = ua.toLowerCase();
    final lowerPlat = platform.toLowerCase();

    if (lowerUa.contains('android')) {
      return 'android';
    }
    if (lowerUa.contains('iphone') ||
        lowerUa.contains('ipad') ||
        lowerUa.contains('ipod')) {
      return 'ios';
    }
    if (lowerUa.contains('windows')) {
      return 'windows';
    }
    if (lowerUa.contains('mac') || lowerPlat.contains('mac')) {
      return 'macos';
    }
    if (lowerUa.contains('linux')) {
      return 'linux';
    }
    return 'web';
  }
}
