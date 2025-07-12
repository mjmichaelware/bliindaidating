// lib/widgets/dashboard_shell/dashboard_content_switcher.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class DashboardContentSwitcher extends StatelessWidget {
  final int selectedTabIndex;
  final List<Widget> screens;

  const DashboardContentSwitcher({
    super.key,
    required this.selectedTabIndex,
    required this.screens,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    if ((screens ?? []).isEmpty) {
      return Center(
        child: Text(
          'No content available for this tab.',
          style: TextStyle(
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
          ),
        ),
      );
    }

    return IndexedStack(
      index: selectedTabIndex,
      children: screens,
    );
  }
}