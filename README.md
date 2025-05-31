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

---

> Last updated: 2025-05-30
