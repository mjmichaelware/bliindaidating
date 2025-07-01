// lib/dashboard_menu_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For ThemeController
import 'package:bliindaidating/app_constants.dart'; // For AppConstants colors and text
import 'package:bliindaidating/controllers/theme_controller.dart'; // For ThemeController

/// A basic navigation drawer for the application dashboard.
///
/// This widget provides a sidebar menu with a header and navigation items.
/// It dynamically adjusts its colors based on the current theme (light/dark mode).
class DashboardMenuDrawer extends StatelessWidget {
  const DashboardMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    // Determine colors based on current theme
    // Note: headerColor, textColor, textHighEmphasis, surfaceColor still use AppConstants
    // as these have not caused issues and are correctly defined.
    final Color headerColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color textHighEmphasis = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color surfaceColor = isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;

    return Drawer(
      backgroundColor: surfaceColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // THIS IS THE CRITICAL FIX: Using direct Colors to bypass the AppConstants.accentColor issue
                colors: [
                  isDarkMode ? Colors.deepPurple.shade700 : Colors.blue.shade300,
                  isDarkMode ? Colors.blueAccent.shade700 : Colors.purple.shade300,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              AppConstants.appName,
              style: TextStyle(
                fontFamily: 'Inter',
                color: textHighEmphasis,
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: textColor),
            title: Text(
              'Home',
              style: TextStyle(fontFamily: 'Inter', color: textColor),
            ),
            onTap: () {
              // TODO: Implement navigation to home screen
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: textColor),
            title: Text(
              'Profile',
              style: TextStyle(fontFamily: 'Inter', color: textColor),
            ),
            onTap: () {
              // TODO: Implement navigation to profile screen
              Navigator.pop(context); // Close the drawer
            },
          ),
          // Add more ListTiles for other navigation items as needed
          Divider(color: textColor.withOpacity(0.2)),
          ListTile(
            leading: Icon(Icons.settings, color: textColor),
            title: Text(
              'Settings',
              style: TextStyle(fontFamily: 'Inter', color: textColor),
            ),
            onTap: () {
              // TODO: Implement navigation to settings screen
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: textColor),
            title: Text(
              'About',
              style: TextStyle(fontFamily: 'Inter', color: textColor),
            ),
            onTap: () {
              // TODO: Implement navigation to about screen
              Navigator.pop(context); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}
