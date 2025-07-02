// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async'; // Required for StreamSubscription and ChangeNotifier
import 'package:provider/provider.dart'; // Import for state management

// Local imports - Ensure these files exist in your project structure
import 'package:bliindaidating/utils/supabase_config.dart';
import 'package:bliindaidating/app_constants.dart'; // Import app_constants for theme
import 'package:bliindaidating/controllers/theme_controller.dart'; // Import ThemeController
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile for redirect logic
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService for redirect logic

// Screens imports - Ensure all these paths are correct and these files exist.
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
    // Access theme colors dynamically using Provider
    final theme = Provider.of<ThemeController>(context);
    return Scaffold(
      backgroundColor: theme.isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      body: Center(
        child: Text(
          '404 - Page Not Found',
          style: TextStyle(
            color: theme.isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
            fontSize: AppConstants.fontSizeLarge,
            fontFamily: 'Inter',
          ),
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
    runApp(
      // Provide ThemeController to the widget tree
      ChangeNotifierProvider(
        create: (context) => ThemeController(),
        child: const BlindAIDatingApp(),
      ),
    );
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
  final ProfileService _profileService = ProfileService(); // Instantiate ProfileService

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
            penaltyCount: 0,      // TODO: Fetch from Supabase after authentication
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
      redirect: (context, state) async { // Made async to allow fetching profile
        final User? currentUser = Supabase.instance.client.auth.currentUser;
        final bool loggedIn = currentUser != null;
        final String currentPath = state.matchedLocation;

        final bool isAuthPath = currentPath == '/login' || currentPath == '/signup';
        final bool isOnPublicInitialPage = currentPath == '/' || currentPath == '/portal_hub';

        debugPrint('GoRouter Redirect:');
        debugPrint('  Current Path: $currentPath');
        debugPrint('  Logged In: $loggedIn');
        debugPrint('  Is Auth Path: $isAuthPath');
        debugPrint('  On Public Initial Page: $isOnPublicInitialPage');


        // If user is not logged in:
        if (!loggedIn) {
          // Allow navigation to auth paths or public initial pages
          if (isAuthPath || isOnPublicInitialPage) {
            debugPrint('  Redirect decision: Not logged in but on auth/public path. Allowing navigation.');
            return null;
          }
          // If trying to access any other page, redirect to login
          debugPrint('  Redirect decision: Not logged in and on protected page. Redirecting to /login');
          return '/login';
        }

        // If user is logged in:
        if (loggedIn) {
          // Fetch user profile to check completion status
          UserProfile? userProfile;
          try {
            userProfile = await _profileService.fetchUserProfile(currentUser.id);
          } catch (e) {
            debugPrint('Error fetching user profile in redirect: $e');
            // If profile fetch fails, treat as incomplete or redirect to login
            // Consider logging out or showing an error page here for robust error handling
            // For now, assume profile fetch failure implies incomplete or issue.
          }

          final bool isProfileComplete = userProfile?.isProfileComplete ?? false;

          debugPrint('  Is Profile Complete: $isProfileComplete');

          // If profile setup is required (not complete) and user is not on the profile setup screen, redirect to it.
          if (!isProfileComplete && currentPath != '/profile_setup') {
            debugPrint('  Redirect decision: Logged in, profile NOT complete. Redirecting to /profile_setup');
            return '/profile_setup';
          }
          // If profile setup is NOT required (complete) AND user is trying to access login/signup/public pages,
          // or is on the profile setup page but doesn't need to be, redirect to home.
          if (isProfileComplete && (isAuthPath || isOnPublicInitialPage || currentPath == '/profile_setup')) {
            debugPrint('  Redirect decision: Logged in, profile IS complete. Redirecting to /home');
            return '/home';
          }
        }

        // No redirection needed, allow navigation to the requested path
        debugPrint('  Redirect decision: No specific redirection needed. Allowing current path.');
        return null;
      },
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consume the ThemeController to get the current theme
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp.router(
      title: AppConstants.appName, // Use app name from constants
      // Apply theme dynamically from ThemeController
      theme: themeController.currentTheme,
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