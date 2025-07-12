// lib/main.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async'; // Required for StreamSubscription and ChangeNotifier
import 'package:provider/provider.dart'; // Import for state management

// Local imports - Ensure these files exist in your project structure
import 'package:bliindaidating/app_constants.dart'; // Import app_constants for theme
import 'package:bliindaidating/controllers/theme_controller.dart'; // Import ThemeController
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile for redirect logic
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService for redirect logic
import 'package:bliindaidating/services/auth_service.dart'; // Import AuthService for redirect logic

// Screens imports - Ensure all these paths are correct and these files exist.
import 'package:bliindaidating/landing_page/landing_page.dart';
import 'package:bliindaidating/screens/portal/portal_page.dart';
import 'package:bliindaidating/auth/login_screen.dart';
import 'package:bliindaidating/auth/signup_screen.dart';
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart';

// Corrected import paths for profile setup screens based on your tree
import 'package:bliindaidating/profile/profile_setup_screen.dart'; // This is Phase 1 setup
// These screens are imported because they are used in GoRouter routes,
// even if they don't have const constructors yet.
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

// NEW IMPORTS for screens (ENSURE THESE ARE CORRECT)
import 'package:bliindaidating/screens/notifications/notifications_screen.dart';
import 'package:bliindaidating/screens/profile/profile_view_screen.dart'; // For /profile/:userId dynamic route
import 'package:bliindaidating/screens/profile/my_profile_screen.dart'; // ADDED: For /my-profile static route
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart'; // ADDED: For /questionnaire-phase2 route


// Define the environment variables at the top level using const String.fromEnvironment
// These values will be set at compile time by the --dart-define or --dart-define-from-file flags.
// Provide empty strings as default values, then assert their presence for release builds.
const String _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '', // Important: Provide a default empty string
);
const String _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '', // Important: Provide a default empty string
);

// A simple Not Found screen for GoRouter's errorBuilder
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

  // --- Add these debug prints to verify the values at startup ---
  debugPrint('>>> Build Mode: ${const bool.fromEnvironment('dart.vm.product') ? 'RELEASE' : 'DEBUG'}');
  debugPrint('>>> Supabase URL from env: $_supabaseUrl');
  debugPrint('>>> Supabase Anon Key from env: $_supabaseAnonKey');
  // -----------------------------------------------------------

  try {
    // Check if in product (release) mode and if keys are missing
    if (const bool.fromEnvironment('dart.vm.product')) {
      if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
        throw Exception('Supabase credentials (URL or Anon Key) are missing in RELEASE build. '
                         'Ensure --dart-define or --dart-define-from-file are used.');
      }
    }

    // Initialize Supabase directly here using the constants
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
      // Turn off debug logging for Supabase in release builds automatically
      debug: !const bool.fromEnvironment('dart.vm.product'),
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeController()),
          ChangeNotifierProvider(create: (context) => AuthService()), // AuthService now extends ChangeNotifier
          ChangeNotifierProvider(create: (context) => ProfileService()), // ProfileService now extends ChangeNotifier
        ],
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

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LandingPage()),
        GoRoute(path: '/portal_hub', builder: (context, state) => const PortalPage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
        GoRoute(path: '/home', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/profile_setup', builder: (context, state) => const ProfileSetupScreen()), // Phase 1 setup
        GoRoute(path: '/questionnaire-phase2', builder: (context, state) => const Phase2SetupScreen()), // NEW: Phase 2 setup
        GoRoute(path: '/my-profile', builder: (context, state) => const MyProfileScreen()), // NEW: Direct route to current user's profile
        // Removed 'const' from these constructors as they likely don't have them
        GoRoute(path: '/edit_profile', builder: (context, state) => ProfileTabsScreen()),
        GoRoute(path: '/about_me', builder: (context, state) => AboutMeScreen()),
        GoRoute(path: '/availability', builder: (context, state) => AvailabilityScreen()),
        GoRoute(path: '/interests', builder: (context, state) => InterestsScreen()),
        GoRoute(path: '/events', builder: (context, state) => const LocalEventsScreen(events: [])),
        GoRoute(path: '/penalties', builder: (context, state) => const PenaltyDisplayScreen()),
        GoRoute(path: '/about-us', builder: (context, state) => const AboutUsScreen()),
        GoRoute(path: '/privacy', builder: (context, state) => const PrivacyScreen()),
        GoRoute(path: '/terms', builder: (context, state) => const TermsScreen()),
        GoRoute(path: '/discovery', builder: (context, state) => const DiscoveryScreen()),
        GoRoute(path: '/matches', builder: (context, state) => const MatchesListScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/feedback', builder: (context, state) => const FeedbackScreen()),
        GoRoute(path: '/report', builder: (context, state) => const ReportScreen()),
        GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
        GoRoute(
          path: '/profile/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId'];
            if (userId == null) return const NotFoundScreen();
            return ProfileViewScreen(userId: userId);
          },
        ),
      ],
      // Redirect logic - RE-ENABLED AND CORRECTED
      redirect: (context, state) async {
        // Access services via Provider
        final authService = Provider.of<AuthService>(context, listen: false);
        final profileService = Provider.of<ProfileService>(context, listen: false);

        final User? currentUser = authService.currentUser; // Use AuthService's getter
        final bool loggedIn = currentUser != null;
        final String currentPath = state.matchedLocation;

        final bool isAuthPath = currentPath == '/login' || currentPath == '/signup';
        final bool isOnPublicInitialPage = currentPath == '/' || currentPath == '/portal_hub';
        final bool goingToProfileSetup = currentPath == '/profile_setup';
        final bool goingToPhase2Setup = currentPath == '/questionnaire-phase2';
        final bool goingToMyProfile = currentPath == '/my-profile';
        final bool goingToDashboard = currentPath == '/home';

        debugPrint('GoRouter Redirect:');
        debugPrint('  Current Path: $currentPath');
        debugPrint('  Logged In: $loggedIn');

        // 1. If not logged in, redirect to landing or auth pages
        if (!loggedIn) {
          if (!isAuthPath && !isOnPublicInitialPage) {
            debugPrint('  Redirect decision: Not logged in and on protected page. Redirecting to /');
            return '/';
          }
          debugPrint('  Redirect decision: Not logged in but on auth/public path. Allowing navigation.');
          return null; // Allow navigation to login/signup/landing/portal_hub
        }

        // 2. If logged in, fetch profile if not already loaded (or if it's stale/different user)
        // Ensure profileService.userProfile is up-to-date for the current user.
        if (profileService.userProfile == null || profileService.userProfile!.userId != currentUser.id) {
          debugPrint('  Fetching user profile for redirect logic...');
          await profileService.fetchUserProfile(currentUser.id);
        }

        final bool isPhase1Complete = profileService.userProfile?.isPhase1Complete ?? false;
        final bool isPhase2Complete = profileService.userProfile?.isPhase2Complete ?? false;
        debugPrint('  Is Phase 1 Complete: $isPhase1Complete');
        debugPrint('  Is Phase 2 Complete: $isPhase2Complete');

        // 3. If logged in but Phase 1 is not complete, redirect to /profile_setup
        if (!isPhase1Complete) {
          if (!goingToProfileSetup) {
            debugPrint('  Redirect decision: Logged in, Phase 1 NOT complete. Redirecting to /profile_setup');
            return '/profile_setup';
          }
          debugPrint('  Redirect decision: Logged in, Phase 1 NOT complete, on /profile_setup. Allowing.');
          return null; // Allow navigation to /profile_setup
        }

        // 4. If logged in, Phase 1 complete, but Phase 2 is not complete, redirect to /questionnaire-phase2
        if (isPhase1Complete && !isPhase2Complete) {
          if (!goingToPhase2Setup && !goingToDashboard) { // Allow dashboard to show banner
            debugPrint('  Redirect decision: Logged in, Phase 1 complete, Phase 2 NOT complete. Redirecting to /questionnaire-phase2');
            return '/questionnaire-phase2';
          }
          debugPrint('  Redirect decision: Logged in, Phase 1 complete, Phase 2 NOT complete, on /questionnaire-phase2 or /home. Allowing.');
          return null; // Allow navigation to /questionnaire-phase2 or /home
        }

        // 5. If logged in AND both phases are complete:
        //    Redirect from auth/public/setup pages to /home (dashboard)
        if (loggedIn && isPhase1Complete && isPhase2Complete) {
          if (isAuthPath || isOnPublicInitialPage || goingToProfileSetup || goingToPhase2Setup) {
            debugPrint('  Redirect decision: Logged in, BOTH phases complete, on auth/public/setup page. Redirecting to /home');
            return '/home';
          }
        }

        debugPrint('  Redirect decision: No specific redirection needed. Allowing current path.');
        return null; // Allow navigation to any other path
      },
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }

  @override
  void dispose() {
    // Services are managed by Provider, no manual dispose here.
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: themeController.currentTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners(); // Notify immediately to check initial state
    _subscription = stream.asBroadcastStream().listen(
          (AuthState event) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}