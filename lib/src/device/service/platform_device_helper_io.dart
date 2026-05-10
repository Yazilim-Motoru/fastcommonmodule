import 'dart:io';
import '../model/fast_device_info.dart';

/// IO implementation of device helper using dart:io
class PlatformDeviceHelper {
  static FastDeviceInfo getDeviceInfo() {
    return FastDeviceInfo(
      os: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      processorCount: Platform.numberOfProcessors,
      language: Platform.localeName,
      isWeb: false,
      deviceId: Platform.localHostname,
    );
  }
}
