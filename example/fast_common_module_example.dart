/// Example usage of FastCommonModule
///
/// This example demonstrates how to create a user and use the FastResponse model.
import 'package:fast_common_module/fast_common_module.dart';
import 'package:fast_common_module/src/common/model/fast_response.dart';

void main() {
  final user = FastUser(
    id: '1',
    username: 'example',
    email: 'example@example.com',
    roles: [FastRole.admin],
  );
  final response = FastResponse.success(user);
  // ignore: avoid_print
  print('User: \\${response.data?.toJson()}');
}
