import '../../common/model/fast_response.dart';
import '../model/fast_tenant.dart';

/// Abstract service for managing tenants in a multi-tenant system.
abstract class FastTenantService {
  /// Returns all tenants in the system.
  Future<FastResponse<List<FastTenant>>> getAllTenants();

  /// Returns a tenant by id.
  Future<FastResponse<FastTenant>> getTenantById(String id);

  /// Adds a new tenant.
  Future<FastResponse<FastTenant>> addTenant(FastTenant tenant);

  /// Updates an existing tenant.
  Future<FastResponse<FastTenant>> updateTenant(FastTenant tenant);

  /// Removes a tenant by id.
  Future<FastResponse> removeTenant(String id);

  /// Assigns a user to a tenant.
  Future<FastResponse> assignUserToTenant(
      {required String userId, required String tenantId});

  /// Removes a user from a tenant.
  Future<FastResponse> removeUserFromTenant(
      {required String userId, required String tenantId});
}
