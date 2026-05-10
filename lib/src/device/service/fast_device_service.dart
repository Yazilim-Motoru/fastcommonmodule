import '../model/fast_device_info.dart';
import '../model/fast_app_info.dart';
import 'platform_device_helper.dart';

/// Service to provide device and application information.
///
/// It fetches device info automatically without external dependencies.
/// Application info can be optionally injected during initialization.
class FastDeviceService {
  FastDeviceInfo? _deviceInfoCache;
  FastAppInfo? _appInfoCache;

  /// Initialize the service with optional application info
  /// Since package_info_plus is not used to stay dependency-free,
  /// developers can inject their app info here.
  void initialize({FastAppInfo? appInfo}) {
    if (appInfo != null) {
      _appInfoCache = appInfo;
    }
  }

  /// Get the current device information
  FastDeviceInfo getDeviceInfo() {
    if (_deviceInfoCache != null) {
      return _deviceInfoCache!;
    }
    _deviceInfoCache = PlatformDeviceHelper.getDeviceInfo();
    return _deviceInfoCache!;
  }

  /// Get the current application information
  /// Returns a default FastAppInfo if not initialized.
  FastAppInfo getAppInfo() {
    if (_appInfoCache != null) {
      return _appInfoCache!;
    }
    return const FastAppInfo(
      appName: 'Unknown App',
      packageName: 'com.unknown.app',
      version: '1.0.0',
      buildNumber: '1',
    );
  }
}
