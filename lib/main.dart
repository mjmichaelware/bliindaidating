// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async'; // Required for StreamSubscription and ChangeNotifier

// Local imports - Ensure these files exist in your project structure
import 'package:bliindaidating/utils/supabase_config.dart';
import 'package:bliindaidating/app_constants.dart'; // Import app_constants for theme

// Screens imports - Ensure all these paths are correct and these files exist.
// If any are missing, you will need to create them.
import 'package:bliindaidating/landing_page/landing_page.dart';
import 'package:bliindaidating/screens/portal/portal_page.dart';
import 'package:bliindaidating/auth/login_screen.dart';
import 'package:bliindaidating/auth/signup_screen.dart';
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart';

import 'package:bliindaidating/profile/profile_setup_screen.dart';
import 'package:bliindaidating/profile/profile_tabs_screen.dart';
import 'package:bliindaidating/profile/about_me_screen.dart';
import 'package:bliindaidating/profile/availability_screen.dart';
import 'package:bliindaidating/profile/interests_screen.dart';

import 'package:bliindaidating/friends/local_events_screen.dart';
import 'package:bliindaidating/matching/penalty_display_screen.dart';

import 'package:bliindaidating/screens/info/about_us_screen.dart';
import 'package:bliindaidating/screens/info/privacy_screen.dart';
import 'package:bliindaidating/screens/info/terms_screen.dart';

import 'package:bliindaidating/screens/discovery/discovery_screen.dart';
import 'package:bliindaidating/screens/matches/matches_list_screen.dart';
import 'package:bliindaidating/screens/settings/settings_screen.dart';
import 'package:bliindaidating/screens/feedback_report/feedback_screen.dart';
import 'package:bliindaidating/screens/feedback_report/report_screen.dart';
import 'package:bliindaidating/screens/admin/admin_dashboard_screen.dart';


// A simple Not Found screen for GoRouter's errorBuilder
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppConstants.backgroundColor, // Use constant for consistency
      body: Center(
        child: Text(
          '404 - Page Not Found',
          style: TextStyle(color: AppConstants.textColor, fontSize: 24, fontFamily: 'Inter'),
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Supabase using the centralized SupabaseConfig
    await SupabaseConfig.init();
    runApp(const BlindAIDatingApp());
  } catch (e) {
    debugPrint('Fatal Error: Supabase initialization failed: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Initialization Error')),
          body: Center(
            child: Text(
              'Failed to start app: ${e.toString()}',
              style: const TextStyle(color: Colors.red, fontFamily: 'Inter'),
            ),
          ),
        ),
      ),
    );
  }
}

class BlindAIDatingApp extends StatefulWidget {
  const BlindAIDatingApp({super.key});

  @override
  State<BlindAIDatingApp> createState() => _BlindAIDatingAppState();
}

class _BlindAIDatingAppState extends State<BlindAIDatingApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      // Listen to authentication state changes from Supabase to trigger route refreshes
      refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
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
            totalDatesAttended: 0, // TODO: Fetch from Supabase after authentication
            currentMatches: 0,     // TODO: Fetch from Supabase after authentication
            penaltyCount: 0,       // TODO: Fetch from Supabase after authentication
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
          builder: (context, state) => const LocalEventsScreen(events: []), // TODO: Fetch events from Supabase
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
      ],
      // Redirection logic based on authentication state and profile setup
      redirect: (context, state) {
        final bool loggedIn = Supabase.instance.client.auth.currentUser != null;
        final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
        final bool onPublicInitialPage = state.matchedLocation == '/' || state.matchedLocation == '/portal_hub';
        // TODO: Implement actual logic to check if profile setup is required.
        // This might involve checking a flag in the user's Supabase profile table.
        final bool isProfileSetupRequired = false; // Placeholder: Assume false for now

        // If user is not logged in and trying to access a protected page, redirect to login
        if (!loggedIn && !loggingIn && !onPublicInitialPage) {
          return '/login';
        }

        // If user is logged in:
        if (loggedIn) {
          // If profile setup is required and user is not on the profile setup screen, redirect to it.
          if (isProfileSetupRequired && state.matchedLocation != '/profile_setup') {
            return '/profile_setup';
          }
          // If profile setup is not required AND user is trying to access login/signup/public pages, redirect to home.
          // Also redirect if they are on the profile setup page but don't need to be.
          if (!isProfileSetupRequired && (loggingIn || onPublicInitialPage || state.matchedLocation == '/profile_setup')) {
            return '/home';
          }
        }

        // No redirection needed, allow navigation to the requested path
        return null;
      },
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName, // Use app name from constants
      // Apply theme using AppConstants for consistency and Material 3
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Inter', // Apply Inter font globally
          bodyColor: AppConstants.textColor,
          displayColor: AppConstants.textColor,
        ),
        // Define other theme properties using AppConstants for consistency
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.surfaceColor,
          foregroundColor: AppConstants.textHighEmphasis,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.textHighEmphasis,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: AppConstants.textHighEmphasis,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge, vertical: AppConstants.spacingMedium),
            textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // Add more theme components (text input, card, dialog, etc.) as needed
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Helper class for GoRouter to listen to a stream (Supabase auth changes)
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners(); // Initial notification to set initial state
    _subscription = stream.asBroadcastStream().listen(
          (AuthState event) => notifyListeners(), // Notify listeners on each auth state change
        );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel the subscription when no longer needed
    super.dispose();
  }
}