// lib/platform_utils/platform_io_helpers_io.dart

import 'dart:io' as io; // Actual dart:io
import 'dart:typed_data';
import 'package:bliindaidating/platform_utils/platform_io_helpers.dart'; // Import the interface

// Implement the interface for non-web platforms
class PlatformIOHelpersImpl implements PlatformIOHelpers {
  @override
  Future<Uint8List?> readFileAsBytes(String path) async {
    try {
      final file = io.File(path);
      return await file.readAsBytes();
    } catch (e) {
      print('Error reading file via dart:io: $e');
      return null;
    }
  }
}

// Provide the specific implementation for the external getter.
PlatformIOHelpers getPlatformIOHelpers() => PlatformIOHelpersImpl();