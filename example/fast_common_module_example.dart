/// Example usage of FastCommonModule
///
/// This example demonstrates various features including:
/// - User management and roles
/// - Middleware system with API client
/// - Basic models and services
import 'package:fast_common_module/fast_common_module.dart';

void main() async {
  // Example 1: User Management
  await userManagementExample();

  // Example 2: Middleware System with API Client
  await middlewareExample();

  // Example 3: Basic Models Demo
  await modelsExample();
}

/// Example of user management with roles and permissions
Future<void> userManagementExample() async {
  print('=== User Management Example ===');

  final user = FastUser(
    id: '1',
    username: 'alice',
    email: 'alice@example.com',
    roles: [FastRole.admin],
    phone: '+1234567890',
    profileImageUrl: 'https://example.com/avatar.jpg',
  );

  final response = FastResponse.success(user);
  // ignore: avoid_print
  print('User: ${response.data?.toJson()}');
  print('User has admin role: ${user.roles.contains(FastRole.admin)}');
  print('Response successful: ${response.success}');
  print('');
}

/// Example of middleware system with API client
Future<void> middlewareExample() async {
  print('=== Middleware System Example ===');

  // Create API client with middleware
  final apiClient =
      FastApiClient(baseUrl: 'https://jsonplaceholder.typicode.com');

  // Add error handling middleware
  apiClient.addMiddleware(ErrorHandlingMiddleware(
    includeStackTrace: false,
    logErrors: true,
    onErrorLogged: (error, context) {
      print('🔴 Error logged in $context: ${error.code} - ${error.message}');
    },
  ));

  // Add logging middleware
  apiClient.addMiddleware(LoggingMiddleware(
    logRequests: true,
    logResponses: true,
    logResponseData: false,
    logRequestData: false,
  ));

  // Add timeout middleware
  apiClient.addMiddleware(TimeoutMiddleware.create(
    defaultTimeout: Duration(seconds: 30),
    getTimeout: Duration(seconds: 10),
  ));

  // Add retry middleware
  apiClient.addMiddleware(RetryMiddleware(
    maxRetries: 2,
    retryDelay: Duration(milliseconds: 500),
    useExponentialBackoff: true,
  ));

  print('Registered middlewares: ${apiClient.middlewares.length}');
  print('Middleware types:');
  for (final middleware in apiClient.middlewares) {
    print('  - ${middleware.runtimeType} (priority: ${middleware.priority})');
  }

  // Demonstrate middleware removal
  apiClient.removeMiddlewareOfType<LoggingMiddleware>();
  print(
      'After removing LoggingMiddleware: ${apiClient.middlewares.length} middlewares');

  print('');
}

/// Example of basic models and their usage
Future<void> modelsExample() async {
  print('=== Models Example ===');

  // FastException example
  final exception = FastException(
    'User not found',
    code: 'USER_NOT_FOUND',
    details: {'userId': '123'},
    path: '/api/users/123',
    className: 'UserService',
    method: 'getUserById',
  );

  print('Exception: ${exception.message}');
  print('Exception code: ${exception.code}');
  print('Exception details: ${exception.details}');

  // FastResponse failure example
  final failureResponse = FastResponse<String>.failure(
    errorCode: exception.code,
    errorMessage: exception.message,
    meta: exception.details,
  );

  print('Failure response: success=${failureResponse.success}');
  print('Error message: ${failureResponse.errorMessage}');

  // FastFilter example
  final filter = FastFilter(
    query: 'alice',
    pageIndex: 0,
    pageSize: 10,
    filters: {'role': 'admin'},
  );

  print(
      'Filter: query="${filter.query}", page=${filter.pageIndex}, size=${filter.pageSize}');
  print('Additional filters: ${filter.filters}');

  // FastAuditLog example
  final auditLog = FastAuditLog(
    id: 'audit-1',
    userId: 'user-123',
    action: 'USER_LOGIN',
    targetId: 'user-123',
    targetType: 'User',
    timestamp: DateTime.now(),
    meta: {'ip': '192.168.1.1', 'userAgent': 'Mobile App'},
  );

  print('Audit log: ${auditLog.action} by ${auditLog.userId}');
  print('Target: ${auditLog.targetType}#${auditLog.targetId}');

  // FastNotification example
  final notification = FastNotification(
    id: 'notif-1',
    type: FastNotificationType.info,
    title: 'Welcome',
    message: 'Welcome to the system!',
    targetUserId: 'user-1',
    isRead: false,
    createdAt: DateTime.now(),
  );

  print('Notification: ${notification.title} - ${notification.message}');
  print('Type: ${notification.type}, Read: ${notification.isRead}');

  print('');
  print('=== FastCommonModule Demo Complete ===');
}
