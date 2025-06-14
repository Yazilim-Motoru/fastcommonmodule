# FastCommonModule

A modular, enterprise-ready Flutter common module for microservice architectures, multilingual support, and robust role/permission/user/tenant management.

## Features

### 🏗️ **Architecture & Structure**
- **Modular Design:** All models, services, repositories, and mappers are separated by domain
- **Enterprise-Ready:** Built for microservice architectures and scalable applications
- **Developer Friendly:** All code is documented in English and IDE-friendly

### 👥 **User & Access Management** 
- **User Management:** Flexible and extensible FastUser model with comprehensive user data
- **Role & Permission System:** Supports both static (enum) and dynamic (database/UI) permissions
- **Permission-based UI:** FastPermissionBuilder widget for conditional UI rendering
- **Multi-Tenancy:** FastTenant model and services for multi-organization/customer support
- **Authentication Infrastructure:** Ready-to-extend token/JWT service and auth framework

### 🌍 **Advanced Localization**
- **Runtime Language Switching:** Change language without app restart
- **Dynamic Translation Loading:** Add/update translations at runtime  
- **User Preference Management:** Automatic save/restore of language choice
- **Pluralization Support:** Handle plural forms for different languages
- **RTL Support:** Automatic text direction handling for Arabic, Hebrew, etc.
- **Fallback Translations:** Graceful handling of missing translations
- **Rich UI Components:** Language selector, dropdown, and popup menu widgets

### 📡 **API & Data Management**
- **Unified Response Model:** All operations use FastResponse<T> for standardized success/error/meta handling
- **Exception Handling:** FastException for detailed error management with codes and metadata
- **API Client:** FastApiClient for REST API calls with built-in error handling
- **Generic Repository:** Base repository pattern for consistent data access
- **Pagination & Filtering:** FastPage and FastFilter models for data pagination

### 🔧 **Utilities & Services**
- **High-Performance Caching:** FastCacheService with memory/disk storage, automatic expiration, and multiple eviction policies
- **Rate Limiting & Throttling:** FastRateLimitService with brute-force protection, multiple algorithms, and progressive penalties
- **Validation & Forms:** FastValidator with comprehensive validation rules
- **Audit & Logging:** FastAuditLog for tracking user actions and system events
- **Notification System:** FastNotification service for in-app messaging
- **File & Media Management:** FastFileMeta service for file upload/download operations
- **Session Management:** FastSession service for user activity tracking
- **Settings & Configuration:** FastSetting service for app configuration management

## Folder Structure
```
lib/
  fast_common_module.dart
  src/
    auth/           # Authentication and token services
    cache/          # High-performance caching with memory/disk storage
    common/         # Shared models, response, exception, base repository
    localization/   # Localization files and service
    permission/     # Permission models, services
    rate_limit/     # Rate limiting and throttling services
    role/           # Role models, services
    tenant/         # Tenant models, services
    user/           # User models, services
    utils/          # Helper functions
```

## Quick Start
```dart
import 'package:fast_common_module/fast_common_module.dart';
```

## Core Models
- `FastUser`, `FastRole`, `FastPermission`, `FastDynamicPermission`, `FastTenant`, `FastResponse<T>`, `FastException`
- `FastCacheItem<T>`, `FastCacheConfig`, `FastCacheStatistics`
- `FastRateLimitConfig`, `FastRateLimitEntry`, `FastRateLimitResult`, `FastRateLimitStatistics`

## Core Services
- `BaseAuthService`, `FastUserService`, `FastRolePermissionService`, `FastTenantService`, `FastTokenService`
- `BaseCacheService`, `FastCacheService`
- `BaseRateLimitService`, `FastRateLimitService`

## Development
- Follow code style and documentation guidelines.
- Add new models/services in their own domain folders.
- Run `flutter analyze` after each change to check for issues.
- Keep this README up to date.

## Contribution
Pull requests and issues are welcome.

## Usage Example

Here is a basic example of how to use FastCommonModule in your Flutter project:

```dart
import 'package:fast_common_module/fast_common_module.dart';

void main() async {
  // Example: Creating a user
  final user = FastUser(
    id: '1',
    username: 'yazilimmotoru',
    email: 'info@yazilimmotoru.com',
    roles: [FastRole.admin],
  );
  print('User: \\${user.toJson()}');

  // Example: Creating a response
  final response = FastResponse.success(user);
  if (response.success) {
    print('Success: \\${response.data?.username}');
  }

  // Example: Handling exception
  try {
    throw FastException('Something went wrong', code: 'ERR001');
  } catch (e) {
    print(e);
  }

  // Example: Writing an audit log
  final log = FastAuditLog(
    id: 'log-1',
    userId: 'user-1',
    action: 'login',
    timestamp: DateTime.now().toUtc(),
    meta: {'ip': '127.0.0.1'},
  );
  await auditLogService.writeLog(log);
}
```

## High-Performance Caching Example

You can use `FastCacheService` for high-performance caching with memory and disk storage:

```dart
import 'package:fast_common_module/fast_common_module.dart';

// Configure cache service
final cacheConfig = FastCacheConfig(
  maxMemoryItems: 1000,
  maxMemorySize: 50 * 1024 * 1024, // 50MB
  maxDiskItems: 5000,
  maxDiskSize: 100 * 1024 * 1024, // 100MB
  defaultTtlMs: 30 * 60 * 1000, // 30 minutes
  enableMemoryCache: true,
  enableDiskCache: true,
  enableAutoCleanup: true,
  evictionPolicy: FastCacheEvictionPolicy.lru,
);

// Initialize cache service
final cacheService = FastCacheService(config: cacheConfig);
await cacheService.initialize();

// Cache user data
final user = FastUser(id: '1', username: 'john', email: 'john@example.com');
await cacheService.put('user:1', user, ttl: Duration(hours: 1));

// Get cached data
final cachedUser = await cacheService.get<FastUser>('user:1');
if (cachedUser != null) {
  print('Cache hit: ${cachedUser.username}');
} else {
  print('Cache miss - loading from database...');
}

// Cache permissions for quick access
final permissions = [FastPermission.read, FastPermission.edit];
await cacheService.put('user:1:permissions', permissions);

// Check cache statistics
final stats = cacheService.getStatistics();
print('Cache hit ratio: ${stats.hitRatioPercentage.toStringAsFixed(1)}%');
print('Memory items: ${stats.memoryItems}');
print('Disk items: ${stats.diskItems}');

// Manual cleanup
final removedCount = await cacheService.cleanupExpired();
print('Removed $removedCount expired items');

// Clear all cache
await cacheService.clear();
```

### Caching Features:
- **Memory & Disk Storage**: Ultra-fast memory cache with persistent disk storage
- **Automatic Expiration**: TTL-based expiration with background cleanup
- **Multiple Eviction Policies**: LRU, LFU, FIFO, TTL, and Random eviction strategies
- **Cache Statistics**: Detailed performance metrics and hit/miss ratios
- **Generic Type Support**: Type-safe caching for any data type
- **Configurable Limits**: Memory and disk size limits with automatic eviction
- **Background Cleanup**: Automatic removal of expired items

## Rate Limiting & Throttling Example

You can use `FastRateLimitService` for API protection and brute-force attack prevention:

```dart
import 'package:fast_common_module/fast_common_module.dart';

// Configure rate limiting
final rateLimitConfig = FastRateLimitConfig(
  maxRequests: 100, // 100 requests
  windowMs: 60 * 1000, // per minute
  blockDurationMs: 15 * 60 * 1000, // 15 minutes block
  algorithm: FastRateLimitAlgorithm.slidingWindow,
  enableProgressivePenalties: true,
  penaltyMultiplier: 2.0,
  whitelist: ['trusted-api-key'], // Bypass rate limiting
  blacklist: ['blocked-ip'], // Permanently blocked
);

// Initialize rate limiting service
final rateLimitService = FastRateLimitService(config: rateLimitConfig);
await rateLimitService.initialize();

// Check request before processing
String clientId = 'user123'; // or IP address, API key, etc.
final result = await rateLimitService.checkRequest(clientId);

if (result.isAllowed) {
  print('Request allowed - ${result.remainingRequests} remaining');
  // Process the request
} else {
  print('Request blocked: ${result.blockReason}');
  if (result.retryAfter != null) {
    print('Retry after: ${result.retryAfterFormatted}');
  }
  // Return 429 Too Many Requests
}

// Manual blocking for suspicious activity
await rateLimitService.blockIdentifier('suspicious-user', 
    blockDuration: Duration(hours: 24));

// Whitelist trusted clients
await rateLimitService.addToWhitelist('premium-api-key');

// Blacklist abusive clients
await rateLimitService.addToBlacklist('malicious-ip');

// Monitor rate limiting statistics
final stats = rateLimitService.getStatistics();
print('Total requests: ${stats.totalRequests}');
print('Block ratio: ${stats.blockRatioPercentage.toStringAsFixed(1)}%');
print('Currently blocked: ${stats.currentlyBlocked}');

// HTTP headers for client information
final headers = result.toHttpHeaders();
// X-RateLimit-Limit, X-RateLimit-Remaining, Retry-After, etc.
```

### Rate Limiting Features:
- **Multiple Algorithms**: Sliding window, fixed window, token bucket, leaky bucket
- **Brute-Force Protection**: Progressive penalties and automatic blocking
- **Whitelist/Blacklist**: Bypass or permanently block specific identifiers
- **Flexible Identification**: Support for IP, user ID, API key, or custom identifiers
- **Detailed Statistics**: Request patterns, violation tracking, and monitoring
- **HTTP Standard Headers**: RFC-compliant rate limit headers for APIs
- **Auto-Cleanup**: Automatic removal of expired entries and blocks

## Error/Response Middleware System Example

FastCommonModule includes a powerful middleware system for intercepting and handling requests, responses, and errors globally. This provides centralized logging, error handling, retry logic, timeout management, and more.

```dart
import 'package:fast_common_module/fast_common_module.dart';

// Create API client with middleware support
final apiClient = FastApiClient(baseUrl: 'https://api.example.com');

// Add error handling middleware
apiClient.addMiddleware(ErrorHandlingMiddleware(
  includeStackTrace: false,
  logErrors: true,
  onErrorLogged: (error, context) {
    print('Error in $context: ${error.code} - ${error.message}');
  },
));

// Add logging middleware for debugging
apiClient.addMiddleware(LoggingMiddleware(
  logRequests: true,
  logResponses: true,
  logResponseData: false, // Don't log sensitive data
  logRequestData: false,
));

// Add timeout middleware with different timeouts per method
apiClient.addMiddleware(TimeoutMiddleware.create(
  defaultTimeout: Duration(seconds: 30),
  getTimeout: Duration(seconds: 10),
  postTimeout: Duration(seconds: 60),
  uploadTimeout: Duration(minutes: 5),
));

// Add retry middleware with exponential backoff
apiClient.addMiddleware(RetryMiddleware(
  maxRetries: 3,
  retryDelay: Duration(milliseconds: 1000),
  useExponentialBackoff: true,
  shouldRetry: (error, attemptCount) {
    // Custom retry logic
    return attemptCount < 3 && 
           error.toString().contains('timeout');
  },
));

// Use the API client - middleware will be applied automatically
final response = await apiClient.get<Map<String, dynamic>>('/users');
```

### Creating Custom Middleware

```dart
class CustomAuthMiddleware extends BaseMiddleware {
  final String apiKey;
  
  CustomAuthMiddleware(this.apiKey);
  
  @override
  int get priority => 50; // Execute early
  
  @override
  Future<FastResponse<T>?> onRequest<T>(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  ) async {
    // Add auth header to all requests
    final authHeaders = Map<String, String>.from(headers ?? {});
    authHeaders['X-API-Key'] = apiKey;
    
    return null; // Continue with modified headers
  }
  
  @override
  Future<FastResponse<T>> onResponse<T>(
    FastResponse<T> response,
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    // Log successful API calls
    if (response.success) {
      print('✅ $method $endpoint succeeded');
    }
    return response;
  }
  
  @override
  Future<FastResponse<T>> onError<T>(
    Exception error,
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    // Handle auth errors specifically
    if (error.toString().contains('401')) {
      return FastResponse<T>.failure(
        errorCode: 'AUTH_REQUIRED',
        errorMessage: 'Authentication required',
      );
    }
    throw error; // Re-throw other errors
  }
}

// Add custom middleware
apiClient.addMiddleware(CustomAuthMiddleware('your-api-key'));
```

### Middleware Features:
- **Global Error Handling**: Centralized error processing and formatting
- **Request/Response Logging**: Configurable logging with sensitive data protection
- **Automatic Retries**: Smart retry logic with exponential backoff
- **Timeout Management**: Per-method and per-endpoint timeout configuration
- **Middleware Chain**: Priority-based execution order
- **Custom Middleware**: Easy to create domain-specific middleware
- **Error Transformation**: Convert raw exceptions to structured error responses

---

## API Reference

### Core Models
- **FastUser**: User model with id, username, email, roles, phone, profileImageUrl, extra fields.
- **FastRole**: Enum for user roles (admin, editor, viewer, guest).
- **FastPermission**: Enum for static permissions (view, read, edit, delete).
- **FastDynamicPermission**: Fine-grained, dynamic permission model for UI/action-level control.
- **FastTenant**: Tenant (organization/customer) model for multi-tenancy.
- **FastResponse<T>**: Generic response wrapper for all service/repository operations.
- **FastException**: Custom exception for error handling with code, message, details, path, className, method.
- **FastAuditLog**: Model for tracking user and system actions. Fields: id, userId, action, targetId, targetType, timestamp, meta.
- **FastFileMeta**: Model for file/media metadata, access permissions (now List<FastPermission>), and extensible meta.
- **FastNotification**: Model for all notification/message types with type, read status, target user, etc.
- **FastSession**: Model for user session management with device info and security features.
- **FastSetting**: Model for application settings and configuration management.
- **FastPage<T>**: Generic pagination model with items, total count, and pagination metadata.
- **FastFilter**: Generic filtering model with query, pagination, sorting, and custom filters.

### Cache Models
- **FastCacheItem<T>**: Cache item model with data, expiration, access tracking and metadata.
- **FastCacheConfig**: Cache configuration with memory/disk limits, TTL, cleanup policies.
- **FastCacheStatistics**: Cache performance metrics with hit/miss ratios and usage statistics.

### Rate Limiting Models
- **FastRateLimitConfig**: Rate limiting configuration with algorithms, penalties, whitelist/blacklist.
- **FastRateLimitEntry**: Rate limiting entry tracking request history and violations for identifiers.
- **FastRateLimitResult**: Rate limiting check result with allow/block status and retry information.
- **FastRateLimitStatistics**: Rate limiting performance metrics and violation tracking.

### Services & Interfaces
- **BaseAuthService**: Abstract authentication service (login, register, logout, isLoggedIn).
- **FastTokenService**: JWT/token management interface.
- **FastUserService**: User management service interface.
- **FastUserPermissionService**: User-permission management interface.
- **FastUserRepository**: User repository interface.
- **FastUserMapper**: User model mapping utilities.
- **BaseRoleService**: Abstract role management service.
- **FastRolePermissionService**: Role-permission management (static & dynamic permissions).
- **RolePermissionMapper**: Role-permission mapping utilities.
- **BasePermissionService**: Abstract permission management service.
- **FastTenantService**: Tenant management service interface.
- **FastApiClient**: REST API client with middleware support, auth handling, and comprehensive HTTP methods.
- **FastAuditLogService**: Interface for audit log service. Methods: writeLog, getLogs, getLogById.
- **FastFileService**: Abstract service for upload, download, delete, and file listing.
- **FastNotificationService**: Abstract service for sending, listing, marking as read notifications.
- **FastSessionService**: Session management service for authentication and security.
- **FastSettingsService**: Application settings and configuration management service.

### Cache Services
- **BaseCacheService**: Abstract cache service interface.
- **FastCacheService**: High-performance caching with memory/disk storage, automatic expiration, and statistics.

### Rate Limiting Services
- **BaseRateLimitService**: Abstract rate limiting service interface.
- **FastRateLimitService**: Rate limiting and throttling with multiple algorithms, brute-force protection, and progressive penalties.

### Middleware System
- **BaseMiddleware**: Abstract middleware interface for request/response interception.
- **FastMiddlewareManager**: Priority-based middleware chain execution manager.
- **ErrorHandlingMiddleware**: Global error handling, logging, and response formatting.
- **LoggingMiddleware**: Configurable request/response logging with sensitivity controls.
- **RetryMiddleware**: Automatic retry logic with exponential backoff and custom strategies.
- **TimeoutMiddleware**: Request timeout handling with method/endpoint-specific configurations.

### Localization
- **LocalizationService**: Loads and provides localized strings from JSON/ARB files.
- **FastLocalization**: Core localization functionality with runtime language switching.
- **FastLocalizationController**: Localization state management and user preference handling.
- **FastLanguage**: Language model with code, name, flag, and RTL support.
- **FastTranslation**: Translation model with key-value pairs and pluralization.
- **FastLanguageSelector**: Widget for language selection with beautiful UI.

### Utilities
- **BaseRepository**: Generic repository interface for CRUD operations.
- **FastValidator**: Static utility class for common field validation (email, password, phone, etc.).
- **Helpers**: Utility functions in `utils/helpers.dart`.
- **FastPermissionBuilder**: Widget for conditional UI rendering based on permissions.

### Enums
- **FastFileType**: File type enumeration (image, video, audio, document, archive, other).
- **FastNotificationType**: Notification type enumeration (info, warning, error, success).

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you find this package useful, please give it a ⭐ on GitHub!

For questions and support, please open an issue on the [GitHub repository](https://github.com/fmustaficc/fast_common_module).

---

**FastCommonModule** - Enterprise-ready Flutter common module for rapid development 🚀