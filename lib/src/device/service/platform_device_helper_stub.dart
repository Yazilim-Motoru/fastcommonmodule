import '../model/fast_device_info.dart';

/// Stub implementation of device helper
class PlatformDeviceHelper {
  static FastDeviceInfo getDeviceInfo() {
    return FastDeviceInfo(
      os: 'unknown',
      osVersion: 'unknown',
      processorCount: 1,
      language: 'en',
      isWeb: false,
      deviceId: 'unknown',
    );
  }
}
