// lib/controllers/theme_controller.dart

import 'package:flutter/material.dart';

/// A controller class that manages the application's theme state.
/// This class extends [ChangeNotifier] to automatically notify listeners
/// whenever the theme changes, allowing the UI to rebuild accordingly.
class ThemeController with ChangeNotifier {
  // Initialize to true to make dark mode the default theme.
  bool _isDarkMode = true;

  /// Gets the current theme mode state.
  bool get isDarkMode => _isDarkMode;

  /// Toggles the application's theme between light and dark mode.
  /// When called, it updates the [_isDarkMode] state and calls
  /// [notifyListeners()] to inform all widgets that are listening
  /// for changes to this controller.
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
