// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode; // Import kDebugMode
import 'dart:async'; // Required for Future, etc.

// Local Imports
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/services/auth_service.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/theme/app_theme.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Ensure UserProfile is imported for type hints

// NEW IMPORT for platform utilities
import 'package:bliindaidating/platform_utils/platform_helper_factory.dart';

// Screen Imports
import 'package:bliindaidating/auth/login_screen.dart';
import 'package:bliindaidating/auth/signup_screen.dart';
import 'package:bliindaidating/screens/auth/forgot_password_screen.dart';
import 'package:bliindaidating/landing_page/landing_page.dart';
import 'package:bliindaidating/profile/profile_setup_screen.dart'; // Phase 1
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart'; // Phase 2
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart';
import 'package:bliindaidating/screens/utility/loading_screen.dart'; // Import the new LoadingScreen

// Remaining screen imports (keep these as they are, just for completeness)
import 'package:bliindaidating/screens/dashboard/dashboard_overview_screen.dart';
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart';
import 'package:bliindaidating/screens/matches/matches_list_screen.dart';
import 'package:bliindaidating/screens/discovery/discover_people_screen.dart';
import 'package:bliindaidating/screens/questionnaire/questionnaire_screen.dart';
import 'package:bliindaidating/screens/profile/my_profile_screen.dart';
import 'package:bliindaidating/screens/daily/daily_prompts_screen.dart';
import 'package:bliindaidating/screens/notifications/notifications_screen.dart';
import 'package:bliindaidating/screens/favorites/favorites_list_screen.dart';
import 'package:bliindaidating/screens/dashboard/compatibility_results_screen.dart';
import 'package:bliindaidating/screens/dashboard/daily_personality_question_screen.dart';
import 'package:bliindaidating/screens/quiz/personality_quiz_screen.dart';
import 'package:bliindaidating/matching/match_display_screen.dart';
import 'package:bliindaidating/matching/date_proposal_screen.dart';
import 'package:bliindaidating/screens/date/scheduled_dates_list_screen.dart';
import 'package:bliindaidating/screens/date/scheduled_date_details_screen.dart';
import 'package:bliindaidating/screens/date/post_date_feedback_screen.dart';
import 'package:bliindaidating/screens/info/date_ideas_screen.dart';
import 'package:bliindaidating/friends/friends_match_screen.dart';
import 'package:bliindaidating/friends/local_events_screen.dart';
import 'package:bliindaidating/friends/event_details_screen.dart';
import 'package:bliindaidating/screens/info/about_us_screen.dart';
import 'package:bliindaidating/screens/info/privacy_screen.dart';
import 'package:bliindaidating/screens/info/safety_tips_screen.dart';
import 'package:bliindaidating/screens/info/terms_screen.dart';
import 'package:bliindaidating/screens/feedback_report/feedback_screen.dart';
import 'package:bliindaidating/screens/feedback_report/report_screen.dart';
import 'package:bliindaidating/screens/info/activity_feed_screen.dart';
import 'package:bliindaidating/screens/info/blocked_users_screen.dart';
import 'package:bliindaidating/screens/info/guided_tour_screen.dart';
import 'package:bliindaidating/screens/info/user_progress_screen.dart';
import 'package:bliindaidating/screens/settings/app_settings_screen.dart';
import 'package:bliindaidating/screens/admin/admin_dashboard_screen.dart';
import 'package:bliindaidating/screens/premium/referral_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('main: WidgetsFlutterBinding ensured initialized.');

  // --- Start of NEW PLATFORM UTILS INTEGRATION ---
  final platformHelper = getPlatformHelpers();
  debugPrint('main: Current platform type: ${platformHelper.getPlatformType()}');
  platformHelper.doSomethingPlatformSpecific();
  // --- End of NEW PLATFORM UTILS INTEGRATION ---

  // Initialize Supabase FIRST and ensure it completes robustly.
  try {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
    debugPrint('main: Supabase initialized successfully!');
  } catch (e) {
    debugPrint('main: Error initializing Supabase: $e');
    // You might want to show an error dialog or a persistent error screen here
    // as the app cannot function without Supabase. For now, rethrow to crash early.
    rethrow;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeController(),
        ),
        // ProfileService must be created before AuthService as AuthService depends on it
        ChangeNotifierProvider<ProfileService>(
          create: (context) => ProfileService(Supabase.instance.client),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(
            // Use listen: false here as AuthService itself doesn't need to rebuild when ProfileService changes
            Provider.of<ProfileService>(context, listen: false),
          ),
        ),
      ],
      child: const BlindAIDatingApp(),
    ),
  );
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
    debugPrint('BlindAIDatingApp: initState called.');

    // Access providers using listen: false for initial setup in initState
    final ProfileService profileService = Provider.of<ProfileService>(context, listen: false);

    // Initiate the profile loading. This is fire-and-forget here,
    // as ProfileService manages its own internal state and notifies.
    // The GoRouter redirect will react to profileService.isProfileLoaded.
    profileService.initializeProfile();
    debugPrint('BlindAIDatingApp: profileService.initializeProfile() called.');


    _router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode, // Use kDebugMode for conditional logging
      // refreshListenable will trigger redirect when either AuthService or ProfileService notifies listeners
      refreshListenable: Listenable.merge([
        Provider.of<AuthService>(context, listen: false),
        Provider.of<ProfileService>(context, listen: false),
      ]),
      redirect: (BuildContext context, GoRouterState state) {
        // IMPORTANT: Do NOT await network calls here.
        // All necessary data (auth state, profile data, loading status) should be
        // available synchronously from the Providers.
        final AuthService authService = Provider.of<AuthService>(context, listen: false);
        final ProfileService profileService = Provider.of<ProfileService>(context, listen: false);

        final bool isLoggedIn = authService.isLoggedIn;
        final bool isProfileLoaded = profileService.isProfileLoaded; // Indicates if initial load attempt is done
        final UserProfile? userProfile = profileService.userProfile;

        // Use these to check phase completion
        final bool phase1Complete = userProfile?.isPhase1Complete ?? false;
        final bool phase2Complete = userProfile?.isPhase2Complete ?? false;

        final String currentPath = state.fullPath ?? '/';

        // Paths that don't require login/profile completion
        final bool isAuthPath = currentPath == '/login' ||
            currentPath == '/signup' ||
            currentPath == '/forgot-password';
        final bool isLandingPath = currentPath == '/';
        final bool isUtilityPath = currentPath == '/loading'; // New loading screen path

        debugPrint('--- GoRouter Redirect Evaluation ---');
        debugPrint('Current Path: $currentPath');
        debugPrint('Is Logged In: $isLoggedIn');
        debugPrint('Is Profile Loaded (initial attempt done): $isProfileLoaded');
        debugPrint('User Profile Exists: ${userProfile != null}');
        debugPrint('Phase 1 Complete: $phase1Complete');
        debugPrint('Phase 2 Complete: $phase2Complete');


        // SCENARIO 1: User is NOT logged in
        if (!isLoggedIn) {
          debugPrint('Redirect Logic: User NOT logged in.');
          if (isAuthPath || isLandingPath) {
            debugPrint('Redirect Logic: Allowed on public/landing path.');
            return null; // Stay on current page
          }
          debugPrint('Redirect Logic: Not logged in and not on public/landing path, redirecting to /login.');
          return '/login'; // Redirect to login for any other path
        }

        // SCENARIO 2: User IS logged in
        debugPrint('Redirect Logic: User IS logged in.');

        // If logged in, but profile data is still being initially loaded
        // This handles the gap between login and profile data being ready.
        if (!isProfileLoaded) {
          debugPrint('Redirect Logic: Profile data not yet initially loaded. Current path: $currentPath');
          // Ensure we don't redirect to /loading if we are already there to prevent a loop
          return currentPath == '/loading' ? null : '/loading';
        }

        // At this point, the user is logged in, and profile data initial load is complete (`isProfileLoaded` is true).

        // If the user is on a public/auth/loading page, but is now logged in and profile is loaded,
        // redirect them to the appropriate onboarding or dashboard screen.
        if (isAuthPath || isLandingPath || isUtilityPath) {
          debugPrint('Redirect Logic: Logged in & profile loaded, currently on auth/landing/loading page.');
          if (!phase1Complete) {
            debugPrint('Redirect Logic: Redirecting from public/landing/loading to /profile_setup (Phase 1 incomplete).');
            return '/profile_setup';
          }
          if (!phase2Complete) {
            debugPrint('Redirect Logic: Redirecting from public/landing/loading to /questionnaire-phase2 (Phase 2 incomplete).');
            return '/questionnaire-phase2';
          }
          debugPrint('Redirect Logic: Redirecting from public/landing/loading to /dashboard-overview (all phases complete).');
          return '/dashboard-overview';
        }

        // If logged in, profile loaded, and on an authenticated path:
        // Enforce completion of profile setup phases.
        if (!phase1Complete) {
          debugPrint('Redirect Logic: Logged in, profile loaded, Phase 1 incomplete. Current path: $currentPath');
          return currentPath == '/profile_setup' ? null : '/profile_setup';
        }

        if (!phase2Complete) {
          debugPrint('Redirect Logic: Logged in, Phase 1 complete, Phase 2 incomplete. Current path: $currentPath');
          return currentPath == '/questionnaire-phase2' ? null : '/questionnaire-phase2';
        }

        // If user is logged in, and both phases are complete, they can access any authenticated route.
        debugPrint('Redirect Logic: Logged in, and all profile phases complete. Allowing current path: $currentPath');
        return null; // Allow access to the requested path
      },
      routes: [
        // Standard Routes
        GoRoute(path: '/', builder: (context, state) => const LandingPage()),
        GoRoute(path: '/loading', builder: (context, state) => const LoadingScreen()), // Define loading route
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
        GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
        GoRoute(path: '/profile_setup', builder: (context, state) => const ProfileSetupScreen()),
        GoRoute(path: '/questionnaire-phase2', builder: (context, state) => const Phase2SetupScreen()),

        // All dashboard-related routes now point to MainDashboardScreen.
        // The MainDashboardScreen will then use its internal switcher
        // based on the sub-path or an internal state if a specific tab is desired.
        // For simplicity, we are sending all of them to MainDashboardScreen.
        // You'll need to pass the *intended initial tab* to MainDashboardScreen
        // if the path like '/newsfeed' should pre-select the newsfeed tab.
        // This is usually done with an extra parameter or by reading the current path.
        GoRoute(path: '/dashboard-overview', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/newsfeed', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/matches', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/discovery', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/my-profile', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/questionnaire', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/daily-prompts', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/favorites', builder: (context, state) => const MainDashboardScreen()),

        // Continue with your other routes similarly pointing to MainDashboardScreen if they should be shell-contained
        GoRoute(path: '/compatibility-results', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/daily-personality-question', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/personality-quiz', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/match-display/:id', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/date-proposal', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/scheduled-dates-list', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/scheduled-date-details/:id', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/post-date-feedback', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/date-ideas', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/friends-match', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/events', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/event-details/:id', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/app-settings', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/about-us', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/privacy', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/safety-tips', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/terms', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/feedback', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/report', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/admin', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/referral', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/activity-feed', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/blocked-users', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/guided-tour', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/user-progress', builder: (context, state) => const MainDashboardScreen()),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Page not found: ${state.error}'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: themeController.isDarkMode ? AppTheme.galaxyTheme : AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}