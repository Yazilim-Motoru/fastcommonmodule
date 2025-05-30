import '../model/fast_audit_log.dart';
import '../model/fast_response.dart';

/// Abstract service for audit logging of user and system actions.
abstract class FastAuditLogService {
  /// Writes a new audit log entry.
  Future<FastResponse<FastAuditLog>> writeLog(FastAuditLog log);

  /// Returns all audit logs, optionally filtered by user, action, or date range.
  Future<FastResponse<List<FastAuditLog>>> getLogs({
    String? userId,
    String? action,
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  });

  /// Returns a single audit log entry by id.
  Future<FastResponse<FastAuditLog>> getLogById(String id);
}
