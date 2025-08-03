import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier and debugPrint
import 'dart:ui'; // Import for ImageFilter

// Local imports for core project components
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/services/newsfeed_service.dart';

// NEW: Dashboard Shell Component Imports
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_app_bar.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_side_menu.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_footer.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_content_switcher.dart';

// NEW: Tab Content Screen Imports
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart';
import 'package:bliindaidating/screens/profile/my_profile_screen.dart';
import 'package:bliindaidating/screens/discovery/discover_people_screen.dart';
import 'package:bliindaidating/screens/questionnaire/questionnaire_screen.dart';
import 'package:bliindaidating/screens/matches/matches_list_screen.dart';
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart';

// Import the new Dashboard Overview Screen
import 'package:bliindaidating/screens/dashboard/dashboard_overview_screen.dart';


class DummyDashboardScreen extends StatelessWidget {
  const DummyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dummy Dashboard'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You have successfully navigated to the dummy dashboard.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              'The login and routing are working as expected.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
