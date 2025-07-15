// lib/utils/html_stub.dart

// Dummy classes/functions for non-web platforms
// These mimic the types used from dart:html so the code compiles.

class FileUploadInputElement {
  void click() {}
  Stream<dynamic> get onChange => const Stream.empty();
  List<dynamic>? get files => [];
  set accept(String value) {}
}

class FileReader {
  int get readyState => DONE;
  static const int DONE = 2; // Mimic FileReader.DONE
  Stream<dynamic> get onLoadEnd => const Stream.empty();
  dynamic get result => null;
  void readAsArrayBuffer(dynamic file) {}
}

// Global variable that will be used instead of the actual dart:html
// When building for non-web, this will be used.
final _html = _HtmlStub();

class _HtmlStub {
  FileUploadInputElement FileUploadInputElement() => FileUploadInputElement();
  FileReader FileReader() => FileReader();
}