# FastCommonModule

A modular, enterprise-ready Flutter common module for microservice architectures, multilingual support, and robust role/permission/user/tenant management.

## Features
- **Modular structure:** All models, services, repositories, and mappers are separated by domain.
- **Role & Permission Management:** Supports both static (enum) and dynamic (database/UI) permissions.
- **User Management:** Flexible and extensible FastUser model.
- **Multi-Tenancy:** FastTenant model and services for multi-organization/customer support.
- **Unified Response Model:** All service/repository operations use FastResponse<T> for standardized success/error/meta handling.
- **Exception Handling:** FastException for detailed error management.
- **Multilingual Support:** JSON/ARB-based localization infrastructure.
- **Token/JWT Service:** Ready-to-extend authentication infrastructure.
- **Developer Friendly:** All code is documented in English and IDE-friendly.

## Folder Structure
```
lib/
  fast_common_module.dart
  src/
    auth/           # Authentication and token services
    common/         # Shared models, response, exception, base repository
    localization/   # Localization files and service
    permission/     # Permission models, services
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

## Core Services
- `BaseAuthService`, `FastUserService`, `FastRolePermissionService`, `FastTenantService`, `FastTokenService`

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

---

## API Reference

### Models
- **FastUser**: User model with id, username, email, roles, phone, profileImageUrl, extra fields.
- **FastRole**: Enum for user roles (admin, editor, viewer, guest).
- **FastPermission**: Enum for static permissions (view, read, edit, delete).
- **FastDynamicPermission**: Fine-grained, dynamic permission model for UI/action-level control.
- **FastTenant**: Tenant (organization/customer) model for multi-tenancy.
- **FastResponse<T>**: Generic response wrapper for all service/repository operations.
- **FastException**: Custom exception for error handling with code, message, details, path, className, method.
- **FastAuditLog**: Model for tracking user and system actions. Fields: id, userId, action, targetId, targetType, timestamp, meta.
- **FastFileMeta**: Model for file/media metadata, access permissions (now List<FastPermission>), and extensible meta.

### Services & Interfaces
- **BaseAuthService**: Abstract authentication service (login, register, logout, isLoggedIn).
- **FastUserService**: User management service interface.
- **FastUserPermissionService**: User-permission management interface.
- **FastUserRepository**: User repository interface.
- **FastUserMapper**: User model mapping utilities.
- **BaseRoleService**: Abstract role management service.
- **FastRolePermissionService**: Role-permission management (static & dynamic permissions).
- **RolePermissionMapper**: Role-permission mapping utilities.
- **BasePermissionService**: Abstract permission management service.
- **FastTenantService**: Tenant management service interface.
- **BaseRepository**: Generic repository interface for CRUD operations.
- **FastTokenService**: JWT/token management interface.
- **LocalizationService**: Loads and provides localized strings from JSON/ARB files.
- **Helpers**: Utility functions in `utils/helpers.dart`.
- **FastAuditLogService**: Interface for audit log service. Methods: writeLog, getLogs, getLogById.
- **FastFileService**: Abstract service for upload, download, delete, and file listing.

### Localization
- Add your translations to `lib/src/localization/l10n/en.json`, `tr.json`, etc.
- Use `LocalizationService` to load and access translations.

## Validation & Form Utilities

### FastValidator
- Static utility class for common field validation.
- Methods:
  - `isEmail(String?)`: Validates email address format.
  - `isPassword(String?)`: Validates password (min 8 chars, at least 1 letter and 1 number).
  - `isPhone(String?)`: Validates international phone number format.
  - `isNotEmpty(String?)`: Checks if a field is not empty.
  - `isUsername(String?)`: Validates username (alphanumeric, 3-32 chars).

#### Example
```dart
FastValidator.isEmail('test@example.com'); // true
FastValidator.isPassword('abc12345'); // true
FastValidator.isPhone('+905551112233'); // true
FastValidator.isNotEmpty('hello'); // true
FastValidator.isUsername('user_01'); // true
```

## Pagination & Filtering Example

You can use `FastPage<T>` and `FastFilter` for generic, type-safe pagination and filtering in your list services:

```dart
import 'package:fast_common_module/fast_common_module.dart';

// Example: Listing users with pagination and filtering
Future<FastPage<FastUser>> listUsers(FastFilter filter) async {
  // This is a mock example. Replace with your repository/service call.
  final allUsers = [
    FastUser(id: '1', username: 'alice', email: 'alice@example.com', roles: [FastRole.admin]),
    FastUser(id: '2', username: 'bob', email: 'bob@example.com', roles: [FastRole.editor]),
    // ... more users ...
  ];
  // Simple filter by query (username contains)
  final filtered = filter.query == null
      ? allUsers
      : allUsers.where((u) => u.username.contains(filter.query!)).toList();
  final start = filter.pageIndex * filter.pageSize;
  final end = (start + filter.pageSize).clamp(0, filtered.length);
  final pageItems = filtered.sublist(start, end);
  return FastPage<FastUser>(
    items: pageItems,
    totalCount: filtered.length,
    pageIndex: filter.pageIndex,
    pageSize: filter.pageSize,
  );
}

void main() async {
  final filter = FastFilter(pageIndex: 0, pageSize: 10, query: 'ali');
  final page = await listUsers(filter);
  print('Total users: \\${page.totalCount}');
  for (final user in page.items) {
    print(user.username);
  }
}
```

- `FastPage<T>`: Holds paged data and meta (totalCount, pageIndex, pageSize).
- `FastFilter`: Standardizes pagination, search, and custom filter params for all list endpoints.

## Permission-based UI Example

You can use `FastPermissionBuilder` to show/hide widgets based on user permissions:

```dart
import 'package:fast_common_module/fast_common_module.dart';

// Assume you have a currentUser with permissions:
final currentUser = FastUser(
  id: '1',
  username: 'admin',
  email: 'admin@example.com',
  roles: [FastRole.admin],
  permissions: [FastPermission.view, FastPermission.edit],
);

// In your widget tree:
FastPermissionBuilder(
  permissions: [FastPermission.edit],
  userPermissions: currentUser.permissions,
  builder: (context) => ElevatedButton(
    onPressed: () {},
    child: Text('Edit'),
  ),
  noAccessBuilder: (context) => SizedBox.shrink(), // Optional
)
```

- `permissions`: List of required permissions for the widget.
- `userPermissions`: The current user's permissions.
- `requireAll`: If true, all permissions are required (default: false, any is enough).
- `noAccessBuilder`: Optional widget if permission check fails (default: empty).

## API Client Example

You can use `FastApiClient` for generic, type-safe REST API calls:

```dart
import 'package:fast_common_module/fast_common_module.dart';

final api = FastApiClient(baseUrl: 'https://api.example.com');

// GET request
final usersResponse = await api.get<List<dynamic>>('/users');
if (usersResponse.success) {
  print(usersResponse.data);
}

// POST request with body
final createResponse = await api.post<Map<String, dynamic>>(
  '/users',
  body: {'username': 'test', 'email': 'test@example.com'},
);
if (createResponse.success) {
  print(createResponse.data);
}

// Custom model mapping
final userResponse = await api.get<FastUser>(
  '/users/1',
  fromJson: (json) => FastUser.fromJson(json),
);
if (userResponse.success) {
  print(userResponse.data?.username);
}
```

- Supports GET, POST, PUT, DELETE.
- Returns `FastResponse<T>` for unified error/success handling.
- Use `fromJson` for custom model deserialization.
- Supports dynamic auth token/header via `getAuthToken` param.

## Notification/Message Service Example

You can use `FastNotification` and `FastNotificationService` for in-app/system/email/SMS notifications:

```dart
import 'package:fast_common_module/fast_common_module.dart';

// Example notification model
final notification = FastNotification(
  id: 'notif-1',
  type: FastNotificationType.info,
  title: 'Welcome',
  message: 'Welcome to the system!',
  targetUserId: 'user-1',
  isRead: false,
  createdAt: DateTime.now(),
);

// Example service usage (abstract, implement for your backend)
class MyNotificationService extends FastNotificationService {
  @override
  Future<FastResponse<bool>> send(FastNotification notification) async {
    // Call your API or notification backend here
    return FastResponse.success(true);
  }
  // ...implement other methods...
}

// Usage
final service = MyNotificationService();
await service.send(notification);
```

- `FastNotification`: Model for all notification/message types (in-app, email, SMS, push, etc).
- `FastNotificationService`: Abstract service for sending, listing, marking as read, and deleting notifications.
- Supports notification type, read/unread, target user, meta, etc.

## File/Media Management Example

You can use `FastFileMeta` and `FastFileService` for file upload, download, delete, and permission management:

```dart
import 'package:fast_common_module/fast_common_module.dart';

// Example file metadata
final fileMeta = FastFileMeta(
  id: 'file-1',
  name: 'document.pdf',
  type: FastFileType.document,
  size: 102400,
  mimeType: 'application/pdf',
  url: 'https://cdn.example.com/files/document.pdf',
  uploadedBy: 'user-1',
  uploadedAt: DateTime.now(),
  access: [FastPermission.view, FastPermission.edit],
);

// Example service usage (abstract, implement for your backend)
class MyFileService extends FastFileService {
  @override
  Future<FastResponse<FastFileMeta>> upload({
    required List<int> bytes,
    required String name,
    required String mimeType,
    FastFileType type = FastFileType.other,
    List<FastPermission>? access,
    Map<String, dynamic>? meta,
  }) async {
    // Call your API or storage backend here
    return FastResponse.success(fileMeta);
  }
  // ...implement other methods...
}

// Usage
final fileService = MyFileService();
await fileService.upload(bytes: [], name: 'test.txt', mimeType: 'text/plain');
```

- `FastFileMeta`: Model for file/media metadata, access permissions (now List<FastPermission>), and extensible meta.
- `FastFileService`: Abstract service for upload, download, delete, and file listing.
- `FastFileType`: Enum for file/media types (image, video, document, etc).
- `access`: List of FastPermission for file-level access control.

## User Activity/Session Management Example

You can use `FastSession` and `FastSessionService` for managing active sessions, last login/activity, and session termination:

```dart
import 'package:fast_common_module/fast_common_module.dart';

// Example session model
final session = FastSession(
  id: 'sess-1',
  userId: 'user-1',
  createdAt: DateTime.now().subtract(Duration(hours: 2)),
  lastActiveAt: DateTime.now(),
  deviceInfo: 'Chrome on macOS',
  ip: '192.168.1.10',
  isActive: true,
);

// Example service usage (abstract, implement for your backend)
class MySessionService extends FastSessionService {
  @override
  Future<FastResponse<List<FastSession>>> listUserSessions(String userId) async {
    // Call your API or session backend here
    return FastResponse.success([session]);
  }
  // ...implement other methods...
}

// Usage
final sessionService = MySessionService();
await sessionService.listUserSessions('user-1');
```

- `FastSession`: Model for user session/activity (id, userId, createdAt, lastActiveAt, deviceInfo, ip, isActive, meta).
- `FastSessionService`: Abstract service for listing, getting, terminating, and updating sessions.
- Suitable for session termination, tracking last login/activity time, and multi-device support.

## Settings/Config Service Example

You can use `FastSetting` and `FastSettingsService` for dynamic, user/role/tenant-based application settings:

```dart
import 'package:fast_common_module/fast_common_module.dart';

// Example setting model
final setting = FastSetting(
  id: 'theme',
  value: 'dark',
  userId: 'user-1',
  description: 'User theme preference',
);

// Example service usage (abstract, implement for your backend)
class MySettingsService extends FastSettingsService {
  @override
  Future<FastResponse<FastSetting>> getSetting(String id, {String? userId, String? roleId, String? tenantId}) async {
    // Call your API or config backend here
    return FastResponse.success(setting);
  }
  // ...implement other methods...
}

// Usage
final settingsService = MySettingsService();
await settingsService.getSetting('theme', userId: 'user-1');
```

- `FastSetting`: Model for dynamic application settings/config (id, value, userId, roleId, tenantId, description, meta).
- `FastSettingsService`: Abstract service for getting, setting, deleting, and listing settings.
- Suitable for customizable settings per user, role, or tenant.

---

> Last updated: 2025-05-31
