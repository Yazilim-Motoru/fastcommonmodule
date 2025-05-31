import '../model/fast_setting.dart';
import '../model/fast_response.dart';

/// Abstract service for dynamic application settings/config management.
abstract class FastSettingsService {
  /// Get a setting by id/key (optionally for user/role/tenant).
  Future<FastResponse<FastSetting>> getSetting(String id,
      {String? userId, String? roleId, String? tenantId});

  /// Set or update a setting value (optionally for user/role/tenant).
  Future<FastResponse<FastSetting>> setSetting(FastSetting setting);

  /// Delete a setting by id/key (optionally for user/role/tenant).
  Future<FastResponse<bool>> deleteSetting(String id,
      {String? userId, String? roleId, String? tenantId});

  /// List all settings (optionally filter by user/role/tenant).
  Future<FastResponse<List<FastSetting>>> listSettings(
      {String? userId, String? roleId, String? tenantId});
}
