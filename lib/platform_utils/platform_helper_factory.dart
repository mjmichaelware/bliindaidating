// lib/platform_utils/platform_helper_factory.dart

import 'package:bliindaidating/platform_utils/abstract_platform_helpers.dart';

// Conditional import to select the correct platform helper implementation file.
// - If `dart.library.html` is available (when building for web), it imports
//   'platform_html_helpers.dart'.
// - Otherwise (when `dart.library.io` is available for desktop/mobile), it imports
//   'platform_io_helpers.dart'.
// Both imported files are expected to expose a function named `createPlatformSpecificHelper()`.
import 'platform_html_helpers.dart'
    if (dart.library.io) 'platform_io_helpers.dart';

/// Provides the correct platform-specific helper implementation instance.
///
/// This function acts as the single entry point for accessing platform-dependent
/// functionalities. It uses Dart's conditional imports to ensure that only
/// the relevant platform-specific code is compiled and used.
AbstractPlatformHelpers getPlatformHelpers() {
  // Calls the `createPlatformSpecificHelper` function from the conditionally
  // imported file (either `platform_html_helpers.dart` or `platform_io_helpers.dart`).
  return createPlatformSpecificHelper();
}