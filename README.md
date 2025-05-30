# FastCommonModule

FastCommonModule is a Flutter module designed to provide essential services for role permission authentication, base abstract classes, and support for a microservices architecture. This module is intended for use in multiple projects and includes multilingual support.

## Features

- **Role Permission Authentication**: Manage user roles and permissions with ease.
- **Base Abstract Classes**: Provides foundational classes for entities, repositories, and services.
- **Microservices Architecture**: Facilitates communication and service management in a microservices environment.
- **Multilingual Support**: Easily localize your application with built-in localization services.

## Installation

To use FastCommonModule in your Flutter project, add the following dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  fast_common_module:
    path: /path/to/FastCommonModule/lib
```

## Usage

### Role Permission Service

To use the role permission service, import the `role_permission_service.dart` file:

```dart
import 'package:fast_common_module/src/auth/role_permission_service.dart';

final rolePermissionService = RolePermissionService();
```

### Authentication Service

For authentication functionalities, import the `auth_service.dart` file:

```dart
import 'package:fast_common_module/src/auth/auth_service.dart';

final authService = AuthService();
```

### Localization

To implement multilingual support, use the `localization_service.dart`:

```dart
import 'package:fast_common_module/src/localization/localization_service.dart';

final localizationService = LocalizationService();
```

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## Contact

For any inquiries, please contact the maintainer at [your-email@example.com].