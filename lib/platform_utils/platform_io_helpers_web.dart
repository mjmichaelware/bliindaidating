// lib/platform_utils/platform_io_helpers_web.dart

import 'dart:typed_data';
import 'package:bliindaidating/platform_utils/platform_io_helpers.dart'; // Import the interface

// Stub implementation for web
class PlatformIOHelpersWebStub implements PlatformIOHelpers {
  @override
  Future<Uint8List?> readFileAsBytes(String path) async {
    print('Warning: readFileAsBytes called on web - direct file system access not supported.');
    return null; // Or throw UnsupportedError('File system access not supported on web');
  }
}

// Provide the stub implementation for the external getter.
PlatformIOHelpers getPlatformIOHelpers() => PlatformIOHelpersWebStub();