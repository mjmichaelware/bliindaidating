// lib/platform_utils/platform_io_helpers.dart
import 'dart:io'; // Needed for Platform and File
import 'dart:typed_data'; // Needed for Uint8List
import 'package:bliindaidating/platform_utils/abstract_platform_helpers.dart';

/// Concrete implementation of [AbstractPlatformHelpers] for IO-based platforms (e.g., desktop, mobile).
class ConcretePlatformIOHelpers implements AbstractPlatformHelpers {
  @override
  void doSomethingPlatformSpecific() {
    print('Executing IO specific logic on ${Platform.operatingSystem} (${Platform.version})');
  }

  @override
  String getPlatformType() {
    return 'IO_Platform (${Platform.operatingSystem})';
  }

  @override
  Future<Uint8List?> readFileAsBytes(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error reading file as bytes on IO: $e');
      return null;
    }
  }
}

/// Provides a concrete instance of [AbstractPlatformHelpers] for IO-based platforms.
AbstractPlatformHelpers createPlatformSpecificHelper() {
  return ConcretePlatformIOHelpers();
}