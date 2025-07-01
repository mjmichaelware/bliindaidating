// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bliindaidating/utils/supabase_config.dart';

import 'package:bliindaidating/landing_page/landing_page.dart';
import 'package:bliindaidating/screens/portal/portal_page.dart';
import 'package:bliindaidating/auth/login_screen.dart';
import 'package:bliindaidating/auth/signup_screen.dart';
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart';

import 'package:bliindaidating/profile/profile_setup_screen.dart';
import 'package:bliindaidating/profile/profile_tabs_screen.dart'; // Assuming this is for '/edit_profile'
import 'package:bliindaidating/profile/about_me_screen.dart';
import 'package:bliindaidating/profile/availability_screen.dart';
import 'package:bliindaidating/profile/interests_screen.dart';

import 'package:bliindaidating/friends/local_events_screen.dart';
import 'package:bliindaidating/matching/penalty_display_screen.dart';

// Import for the Info Screens
import 'package:bliindaidating/screens/info/about_us_screen.dart';
import 'package:bliindaidating/screens/info/privacy_screen.dart';
import 'package:bliindaidating/screens/info/terms_screen.dart';

// Imports for other screens accessed via GoRouter
import 'package:bliindaidating/screens/discovery/discovery_screen.dart';
import 'package:bliindaidating/screens/matches/matches_list_screen.dart';
import 'package:bliindaidating/screens/settings/settings_screen.dart';
import 'package:bliindaidating/screens/feedback_report/feedback_screen.dart';
import 'package:bliindaidating/screens/feedback_report/report_screen.dart';
import 'package:bliindaidating/screens/admin/admin_dashboard_screen.dart';
// If you have a PremiumUpsellScreen and want a route for it:
// import 'package:bliindaidating/screens/premium/premium_upsell_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const BlindAIDatingApp());
}

class BlindAIDatingApp extends StatelessWidget {
  const BlindAIDatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: '/portal_hub',
          builder: (context, state) => const PortalPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const MainDashboardScreen(
            totalDatesAttended: 0,
            currentMatches: 0,
            penaltyCount: 0,
          ),
        ),
        GoRoute(
          path: '/profile_setup',
          builder: (context, state) => const ProfileSetupScreen(),
        ),
        GoRoute(
          path: '/edit_profile',
          builder: (context, state) => const ProfileTabsScreen(),
        ),
        GoRoute(
          path: '/about_me',
          builder: (context, state) => const AboutMeScreen(),
        ),
        GoRoute(
          path: '/availability',
          builder: (context, state) => const AvailabilityScreen(),
        ),
        GoRoute(
          path: '/interests',
          builder: (context, state) => const InterestsScreen(),
        ),
        GoRoute(
          path: '/events',
          // Assuming LocalEventsScreen can handle an empty list initially,
          // or you will pass dynamic data here.
          builder: (context, state) => const LocalEventsScreen(events: []),
        ),
        GoRoute(
          path: '/penalties',
          builder: (context, state) => const PenaltyDisplayScreen(),
        ),
        GoRoute(
          path: '/about-us',
          builder: (context, state) => const AboutUsScreen(),
        ),
        GoRoute(
          path: '/privacy',
          builder: (context, state) => const PrivacyScreen(),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const TermsScreen(),
        ),
        GoRoute(
          path: '/discovery',
          builder: (context, state) => const DiscoveryScreen(),
        ),
        GoRoute(
          path: '/matches',
          builder: (context, state) => const MatchesListScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/feedback',
          builder: (context, state) => const FeedbackScreen(),
        ),
        GoRoute(
          path: '/report',
          builder: (context, state) => const ReportScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        // If you need a premium route:
        // GoRoute(
        //   path: '/premium',
        //   builder: (context, state) => const PremiumUpsellScreen(),
        // ),
      ],
      errorBuilder: (context, state) => const NotFoundScreen(),
    );

    return MaterialApp.router(
      title: 'Blind AI Dating',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.black,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          '404 - Page Not Found',
          style: TextStyle(color: Colors.white70, fontSize: 24),
        ),
      ),
    );
  }
}