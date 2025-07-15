// lib/platform_utils/abstract_platform_helpers.dart

import 'dart:typed_data'; // Add this import for Uint8List

/// An abstract interface for platform-specific helper functions.
///
/// Both IO (e.g., desktop, mobile) and HTML (web) implementations
/// will implement this interface to provide a unified API.
abstract class AbstractPlatformHelpers {
  /// Executes a platform-specific operation.
  void doSomethingPlatformSpecific();

  /// Returns a string identifying the current platform type.
  String getPlatformType();

  /// Reads a file from the given path as bytes.
  /// This method is primarily intended for IO platforms where a file path is meaningful.
  /// On web, it should handle cases where a file path isn't directly readable
  /// (e.g., return null or throw an error indicating it's not applicable for local paths).
  Future<Uint8List?> readFileAsBytes(String path); // KEPT this method
}