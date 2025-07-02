// lib/screens/settings/widgets/privacy_data_settings.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'dart:convert'; // For JSON encoding
import 'dart:html' as html; // For web-specific file download

class PrivacyDataSettings extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const PrivacyDataSettings({super.key, required this.formKey});

  // Function to simulate fetching user data and trigger download
  void _viewAndDownloadUserData(BuildContext context, bool isDarkMode) {
    // TODO: In a real implementation, this would fetch comprehensive user data from Supabase
    // (e.g., from profiles table, user_settings table, interests, etc.)
    // and compile it into a complete JSON object.
    final mockUserData = {
      "user_id": "mock_user_id_12345",
      "profile": {
        "display_name": "CosmicSeeker",
        "email": "user@example.com",
        "age": 30,
        "gender": "Non-binary",
        "location_zip": "90210",
        "bio": "Mock bio: Passionate about space and meaningful connections.",
        "interests": ["Astrophysics", "Stargazing", "Sci-Fi Movies"],
        "looking_for": "Long-term relationship",
        "sexual_orientation": "Pansexual",
        "height_cm": 175,
        // ... include all other profile fields you collect
      },
      "settings": {
        "preferred_gender": "Any",
        "age_range": [25, 40],
        "max_distance_miles": 50,
        "visibility": {
          "show_age": true,
          "show_bio": true,
          "show_interests": true,
          // ... all other visibility toggles
        },
        "notifications": {
          "new_matches": true,
          "messages": true,
          // ... other notification settings
        }
      },
      "matches_summary": [
        {"match_id": "match_001", "date": "2025-06-01", "status": "connected"},
        {"match_id": "match_002", "date": "2025-06-15", "status": "pending"}
      ],
      "activity_log": [
        {"action": "profile_view", "timestamp": "2025-06-20T10:00:00Z"},
        {"action": "message_sent", "timestamp": "2025-06-21T11:30:00Z"},
      ]
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(mockUserData);
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "bliindaidating_user_data.json")
      ..click(); // Simulate a click to trigger download
    html.Url.revokeObjectUrl(url); // Clean up the URL

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Your data is downloading!', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
    );
    debugPrint('User data download triggered for web.');
  }


  void _requestDataDeletion(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Data Deletion'),
          content: Text(
            'Are you absolutely sure you want to request permanent deletion of your account and all associated data? This action is irreversible and cannot be undone.',
            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
          ),
          backgroundColor: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
          titleTextStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 20, color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor),
          contentTextStyle: TextStyle(fontFamily: 'Inter', color: isDarkMode ? AppConstants.textColor.withOpacity(0.8) : AppConstants.lightTextColor.withOpacity(0.8)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // TODO: Implement actual backend API call to trigger data deletion process
                debugPrint('Data Deletion Request confirmed. Backend call needed.');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Your data deletion request has been submitted. We will process it shortly.', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              child: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color secondaryColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;


    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy & Data',
              style: textTheme.headlineSmall?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: Text('View Your Data', style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: textColor)),
              subtitle: Text('Download a copy of your personal data collected by the app.', style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.7))),
              trailing: Icon(Icons.download, color: iconColor),
              onTap: () => _viewAndDownloadUserData(context, isDarkMode), // Call the download function
            ),
            ListTile(
              title: Text('Data Deletion Request', style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: textColor)),
              subtitle: Text('Request permanent deletion of all your data.', style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.7))),
              trailing: Icon(Icons.delete_sweep, color: iconColor),
              onTap: () => _requestDataDeletion(context, isDarkMode), // Call the deletion request function
            ),
            const SizedBox(height: 24),
            Text(
              'We take your privacy seriously. For more information, please review our Privacy Policy.',
              style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', fontStyle: FontStyle.italic, color: textColor.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to Privacy Policy screen (ensure route exists in app_router.dart)
                  debugPrint('Privacy Policy link clicked');
                },
                child: Text('Read Privacy Policy', style: textTheme.labelLarge?.copyWith(fontFamily: 'Inter', color: secondaryColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}