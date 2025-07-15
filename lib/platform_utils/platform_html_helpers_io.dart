// lib/platform_utils/platform_html_helpers_io.dart

import 'dart:typed_data';
import 'dart:async';
import 'package:bliindaidating/platform_utils/platform_html_helpers.dart';

// Stub implementation for non-web platforms
class PlatformHTMLHelpersIOStub implements PlatformHTMLHelpers {
  @override
  Future<Uint8List?> pickFileForWeb() async {
    print('Warning: pickFileForWeb called on non-web platform. Use image_picker instead.');
    return null;
  }
}

// Provide the stub implementation for the external getter.
PlatformHTMLHelpers getPlatformHTMLHelpers() => PlatformHTMLHelpersIOStub();