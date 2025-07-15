// lib/platform_utils/platform_html_helpers_web.dart

import 'dart:html' as html; // Only import dart:html here!
import 'dart:typed_data';
import 'dart:async';
import 'package:bliindaidating/platform_utils/platform_html_helpers.dart';

// Web-specific implementation using dart:html
class PlatformHTMLHelpersWebImpl implements PlatformHTMLHelpers {
  @override
  Future<Uint8List?> pickFileForWeb() async {
    try {
      final html.FileUploadInputElement input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();

      await input.onChange.first;
      if (input.files!.isEmpty) {
        print('No file selected (Web HTML Helper).');
        return null;
      }

      final html.File file = input.files![0];
      final html.FileReader reader = html.FileReader();
      final completer = Completer<Uint8List>();

      reader.onLoadEnd.listen((e) {
        if (reader.readyState == html.FileReader.DONE) {
          completer.complete(reader.result as Uint8List);
        }
      });
      reader.readAsArrayBuffer(file);
      return completer.future;
    } catch (e) {
      print('Error picking file via dart:html: $e');
      return null;
    }
  }
}

// Provide the specific implementation for the external getter.
PlatformHTMLHelpers getPlatformHTMLHelpers() => PlatformHTMLHelpersWebImpl();