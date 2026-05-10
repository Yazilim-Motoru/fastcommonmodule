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

  // Example 4: Dependency Injection
  await diExample();

  // Example 5: Device & App Info
  await deviceExample();

  // Example 6: FastLogger
  await loggerExample();

  // Example 7: FastCircuitBreaker
  await circuitBreakerExample();

  // Example 8: FastEventBus
  await eventBusExample();
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
}

/// Example of Dependency Injection (Service Locator)
Future<void> diExample() async {
  print('=== Dependency Injection (DI) Example ===');

  // Register a singleton (e.g., API client)
  final apiClient = FastApiClient(baseUrl: 'https://api.example.com');
  FastLocator.instance.registerSingleton<FastApiClient>(apiClient);

  // Register a factory (e.g., creating a new object every time)
  FastLocator.instance.registerFactory<FastUser>(() {
    return FastUser(
      id: 'dynamic-1',
      username: 'dynamicUser',
      email: 'test@test.com',
      roles: [],
    );
  });

  // Access registered dependencies from anywhere
  final resolvedClient = locate<FastApiClient>();
  print('Resolved API Client: ${resolvedClient.baseUrl}');

  final resolvedUser1 = locate<FastUser>();
  final resolvedUser2 = locate<FastUser>();

  // They are different instances because FastUser is registered as a factory
  print('User 1 Hash: ${resolvedUser1.hashCode}');
  print('User 2 Hash: ${resolvedUser2.hashCode}');
  print('Are they same instance? ${identical(resolvedUser1, resolvedUser2)}');

  // Clear DI container
  FastLocator.instance.reset();

  print('');
}

/// Example of Device & App Info
Future<void> deviceExample() async {
  print('=== Device & App Info Example ===');

  final deviceService = FastDeviceService();

  // Optionally initialize with app info
  deviceService.initialize(
    appInfo: const FastAppInfo(
      appName: 'Demo App',
      packageName: 'com.example.demo',
      version: '1.0.0',
      buildNumber: '100',
    ),
  );

  final device = deviceService.getDeviceInfo();
  final app = deviceService.getAppInfo();

  print('Device OS: ${device.os} ${device.osVersion}');
  print('Processors: ${device.processorCount}');
  print('Language: ${device.language}');
  print('Is Web: ${device.isWeb}');
  print('Device ID: ${device.deviceId}');
  print('App Name: ${app.appName} (v${app.version}+${app.buildNumber})');

  print('');
}

/// Example of FastLogger usage
Future<void> loggerExample() async {
  print('=== FastLogger Example ===');

  // Configure global callback (e.g. for Crashlytics)
  FastLogger.onLog = (logMessage) {
    if (logMessage.level == FastLogLevel.error ||
        logMessage.level == FastLogLevel.wtf) {
      // Send to Crashlytics
      // FirebaseCrashlytics.instance.recordError(logMessage.error, logMessage.stackTrace);
    }
  };

  FastLogger.d('This is a debug message', tag: 'Auth');
  FastLogger.i('User successfully logged in', tag: 'Auth');
  FastLogger.w('API request took longer than expected', tag: 'Network');

  try {
    throw Exception('Connection Refused');
  } catch (e, st) {
    FastLogger.e('Failed to load user profile',
        error: e, stackTrace: st, tag: 'Profile');
  }

  print('');
}

/// Example of FastCircuitBreaker usage
Future<void> circuitBreakerExample() async {
  print('=== FastCircuitBreaker Example ===');

  final circuitBreaker = FastCircuitBreaker(
    config: const FastCircuitBreakerConfig(
      failureThreshold: 2, // Open after 2 failures
      resetTimeout: Duration(seconds: 2), // Try half-open after 2 seconds
    ),
    onStateChanged: (from, to) {
      FastLogger.w('Circuit State Changed: ${from.name} -> ${to.name}',
          tag: 'Circuit');
    },
  );

  // A simulated API call that always fails initially
  Future<String> failingApiCall() async {
    await Future.delayed(const Duration(milliseconds: 100));
    throw Exception('Server Timeout');
  }

  // A simulated API call that succeeds
  Future<String> successfulApiCall() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 'Server Data';
  }

  // 1. Try failing requests
  for (int i = 1; i <= 3; i++) {
    try {
      print('Attempt $i...');
      await circuitBreaker.execute(failingApiCall);
    } catch (e) {
      print('Caught: $e');
    }
  }

  // 2. Wait for reset timeout
  print('Waiting 3 seconds for circuit to transition to half-open...');
  await Future.delayed(const Duration(seconds: 3));

  // 3. Try successful request (Circuit should transition halfOpen -> closed)
  try {
    print('Attempting successful call...');
    final result = await circuitBreaker.execute(successfulApiCall);
    print('Result: $result');
  } catch (e) {
    print('Caught: $e');
  }

  print('');
}

/// A simple event class for demonstration
class UserLoggedInEvent {
  final String username;
  UserLoggedInEvent(this.username);
}

/// Example of FastEventBus usage
Future<void> eventBusExample() async {
  print('=== FastEventBus Example ===');

  // 1. Subscribe to an event (usually done in a widget's initState or a controller)
  final subscription =
      FastEventBus.instance.on<UserLoggedInEvent>().listen((event) {
    FastLogger.i('Event Received! Welcome, \${event.username}',
        tag: 'EventBus');
  });

  // 2. Fire the event from anywhere else in the app
  print('Firing UserLoggedInEvent...');
  FastEventBus.instance.fire(UserLoggedInEvent('yazilimmotoru'));

  // Wait a moment for the async stream to process the event
  await Future.delayed(const Duration(milliseconds: 100));

  // 3. Clean up the subscription (usually done in dispose)
  await subscription.cancel();

  print('');
  print('=== FastCommonModule Demo Complete ===');
}
