// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'dart:async'; // Required for StreamSubscription and ChangeNotifier
import 'package:bliindaidating/utils/supabase_config.dart';

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


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseConfig.init();
    runApp(const BlindAIDatingApp());
  } catch (e) {
    debugPrint('Fatal Error: Supabase initialization failed: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Initialization Error')),
          body: Center(
            child: Text('Failed to start app: ${e.toString()}', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}

class BlindAIDatingApp extends StatefulWidget { // Changed to StatefulWidget
  const BlindAIDatingApp({super.key});

  @override
  State<BlindAIDatingApp> createState() => _BlindAIDatingAppState();
}

class _BlindAIDatingAppState extends State<BlindAIDatingApp> {
  // GoRouter instance, now managed within the state
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Initialize GoRouter in initState
    _router = GoRouter(
      initialLocation: '/',
      // Listen to authentication state changes from Supabase
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
      ],
      // Redirect logic based on authentication state
      redirect: (context, state) {
        final bool loggedIn = Supabase.instance.client.auth.currentUser != null;
        final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
        final bool onPublicInitialPage = state.matchedLocation == '/' || state.matchedLocation == '/portal_hub';

        // If user is not logged in and not on a login/signup/initial public page, redirect to login
        if (!loggedIn && !loggingIn && !onPublicInitialPage) {
          return '/login';
        }

        // If user is logged in and trying to access login/signup/initial public page, redirect to home
        if (loggedIn && (loggingIn || onPublicInitialPage)) {
          return '/home';
        }

        // No redirection needed
        return null;
      },
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Blind AI Dating',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.black,
      ),
      routerConfig: _router, // Use the _router instance
      debugShowCheckedModeBanner: false,
    );
  }
}

// Helper class for GoRouter to listen to a stream (Supabase auth changes)
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners(); // Initial notification
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