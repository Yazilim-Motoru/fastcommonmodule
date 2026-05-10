export 'platform_device_helper_stub.dart'
    if (dart.library.io) 'platform_device_helper_io.dart'
    if (dart.library.html) 'platform_device_helper_web.dart'
    if (dart.library.js_interop) 'platform_device_helper_web.dart';
