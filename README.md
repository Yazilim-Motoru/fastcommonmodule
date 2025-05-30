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

---

> Last updated: 2025-05-30
