// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'dart:async';

// Local Imports
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/services/auth_service.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/controllers/theme_controller.dart'; // Corrected import
import 'package:bliindaidating/theme/app_theme.dart'; // Corrected package name: bliindaidating

// Screen Imports (categorized for clarity)
// Authentication
import 'package:bliindaidating/auth/login_screen.dart';
import 'package:bliindaidating/auth/signup_screen.dart';
import 'package:bliindaidating/screens/auth/forgot_password_screen.dart';

// Onboarding & Setup
import 'package:bliindaidating/landing_page/landing_page.dart';
import 'package:bliindaidating/profile/profile_setup_screen.dart'; // Phase 1
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart'; // Phase 2 (AI Questionnaire completion)

// Main Dashboard Shell
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart';

// Dashboard Content Screens (used within MainDashboardScreen via switcher)
import 'package:bliindaidating/screens/dashboard/dashboard_overview_screen.dart'; // New Dashboard Overview
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart';
import 'package:bliindaidating/screens/matches/matches_list_screen.dart';
import 'package:bliindaidating/screens/discovery/discover_people_screen.dart';
import 'package:bliindaidating/screens/questionnaire/questionnaire_screen.dart';
import 'package:bliindaidating/screens/profile/my_profile_screen.dart';
import 'package:bliindaidating/screens/daily/daily_prompts_screen.dart';
import 'package:bliindaidating/screens/notifications/notifications_screen.dart';
import 'package:bliindaidating/screens/favorites/favorites_list_screen.dart';

// Matching & AI specific screens
import 'package:bliindaidating/screens/dashboard/compatibility_results_screen.dart';
import 'package:bliindaidating/screens/dashboard/daily_personality_question_screen.dart';
import 'package:bliindaidating/screens/quiz/personality_quiz_screen.dart';
import 'package:bliindaidating/matching/match_display_screen.dart';
import 'package:bliindaidating/matching/date_proposal_screen.dart';

// Date Management Screens
import 'package:bliindaidating/screens/date/scheduled_dates_list_screen.dart';
import 'package:bliindaidating/screens/date/scheduled_date_details_screen.dart';
import 'package:bliindaidating/screens/date/post_date_feedback_screen.dart';
import 'package:bliindaidating/screens/info/date_ideas_screen.dart';

// Social/Community Screens
import 'package:bliindaidating/friends/friends_match_screen.dart';
import 'package:bliindaidating/friends/local_events_screen.dart';
import 'package:bliindaidating/friends/event_details_screen.dart';

// Info & Support Screens
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

// Settings & Admin
import 'package:bliindaidating/screens/settings/app_settings_screen.dart';
import 'package:bliindaidating/screens/admin/admin_dashboard_screen.dart';
import 'package:bliindaidating/screens/premium/referral_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(
    MultiProvider(
      providers: [
        // ThemeController as a ChangeNotifierProvider
        ChangeNotifierProvider(
          create: (context) => ThemeController(),
        ),
        // ProfileService as a singleton (lazy-loaded if possible, or eager if needed immediately)
        // Ensure ProfileService is created BEFORE AuthService if AuthService depends on it
        Provider<ProfileService>(
          create: (context) => ProfileService(Supabase.instance.client),
        ),
        // AuthService depends on ProfileService, so it should be created after it
        Provider<AuthService>(
          create: (context) => AuthService(
            Provider.of<ProfileService>(context, listen: false), // Pass ProfileService instance
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
  final GoRouter _router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Enable for debugging route changes
    refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    redirect: (BuildContext context, GoRouterState state) async {
      final AuthService authService = Provider.of<AuthService>(context, listen: false);
      final ProfileService profileService = Provider.of<ProfileService>(context, listen: false);
      final bool isLoggedIn = authService.currentUser != null;

      debugPrint('Redirect Logic: Current path: ${state.fullPath}');
      debugPrint('Redirect Logic: User logged in: $isLoggedIn');
      debugPrint('Redirect Logic: Is Phase 1 Complete: ${profileService.userProfile?.isPhase1Complete}');
      debugPrint('Redirect Logic: Is Phase 2 Complete: ${profileService.userProfile?.isPhase2Complete}');
      debugPrint('Profile User ID (from Service): ${profileService.userProfile?.id ?? 'N/A'}'); // Corrected .id access

      final bool isGoingToAuth = state.fullPath == '/login' ||
          state.fullPath == '/signup' ||
          state.fullPath == '/forgot-password';
      final bool isGoingToLanding = state.fullPath == '/';
      final bool isGoingToProfileSetup = state.fullPath == '/profile_setup';
      final bool isGoingToPhase2Setup = state.fullPath == '/questionnaire-phase2';
      final bool isGoingToDashboardOrAuthRelated = state.fullPath?.startsWith('/dashboard') == true ||
          state.fullPath == '/newsfeed' ||
          state.fullPath == '/matches' ||
          state.fullPath == '/discovery' ||
          state.fullPath == '/my-profile' ||
          state.fullPath == '/questionnaire' ||
          state.fullPath == '/daily-prompts' ||
          state.fullPath == '/notifications' ||
          state.fullPath == '/favorites';


      // Scenario 1: User is not logged in
      if (!isLoggedIn) {
        if (isGoingToAuth || isGoingToLanding) {
          debugPrint('Redirect: Not logged in, staying on auth/landing page.');
          return null; // Stay on login/signup/landing page
        }
        debugPrint('Redirect: Not logged in, redirecting to login.');
        return '/login'; // Redirect to login for any other path
      }

      // Scenario 2: User is logged in
      // Try to load profile if not already loaded (especially on app start)
      if (profileService.userProfile == null) {
        await profileService.fetchUserProfile(id: authService.currentUser!.id);
        debugPrint('Redirect Logic: Fetched profile after login check: ${profileService.userProfile != null}');
      }

      // After potentially fetching profile, check completion status
      final bool phase1Complete = profileService.userProfile?.isPhase1Complete ?? false;
      final bool phase2Complete = profileService.userProfile?.isPhase2Complete ?? false;


      // If user is logged in, but profile Phase 1 is not complete
      if (isLoggedIn && !phase1Complete) {
        if (isGoingToProfileSetup) {
          debugPrint('Redirect: Logged in, Phase 1 incomplete, staying on profile setup.');
          return null; // Stay on profile setup page
        }
        debugPrint('Redirect: Logged in, Phase 1 incomplete, redirecting to profile setup.');
        return '/profile_setup'; // Redirect to profile setup
      }

      // If user is logged in, Phase 1 is complete, but Phase 2 is not complete
      if (isLoggedIn && phase1Complete && !phase2Complete) {
        if (isGoingToPhase2Setup) {
          debugPrint('Redirect: Logged in, Phase 1 complete, Phase 2 incomplete, staying on Phase 2 setup.');
          return null; // Stay on Phase 2 setup
        }
        debugPrint('Redirect: Logged in, Phase 1 complete, Phase 2 incomplete, redirecting to Phase 2 setup.');
        return '/questionnaire-phase2'; // Redirect to Phase 2 setup
      }


      // If user is logged in and both phases are complete
      if (isLoggedIn && phase1Complete && phase2Complete) {
        // If trying to go to auth or initial setup screens, redirect to dashboard
        if (isGoingToAuth || isGoingToLanding || isGoingToProfileSetup || isGoingToPhase2Setup) {
          debugPrint('Redirect: Logged in, profile complete, redirecting from auth/setup to dashboard.');
          return '/dashboard-overview'; // Redirect to main dashboard
        }
        debugPrint('Redirect: Logged in, profile complete, staying on current dashboard-related path.');
        return null; // Stay on the current path (since it's a valid dashboard path)
      }

      // Default: Should not be reached if logic covers all cases
      debugPrint('Redirect: Fallback, no specific redirect. Current path: ${state.fullPath}');
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
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
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile_setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/questionnaire-phase2', // Specific route for phase 2 setup
        builder: (context, state) => const Phase2SetupScreen(),
      ),

      // Main Dashboard Routes (MainDashboardScreen will manage internal tab switching)
      GoRoute(
        path: '/dashboard-overview',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/newsfeed',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/matches',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/discovery',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/my-profile',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/questionnaire', // Main AI Questionnaire (could be used for general questionnaire access)
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/daily-prompts',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const MainDashboardScreen(),
      ),

      // Additional routes that may or may not be directly tied to main tabs,
      // but are accessible within the authenticated part of the app.
      GoRoute(
        path: '/compatibility-results',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/daily-personality-question',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/personality-quiz',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/match-display/:id', // Example with dynamic parameter
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/date-proposal',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/scheduled-dates-list',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/scheduled-date-details/:id', // Example with dynamic parameter
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/post-date-feedback',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/date-ideas',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/friends-match',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/event-details/:id', // Example with dynamic parameter
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/app-settings',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/about-us',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/safety-tips',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/referral',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/activity-feed',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/blocked-users',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/guided-tour',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: '/user-progress',
        builder: (context, state) => const MainDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );

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

// Custom refresh stream for GoRouter to listen to Supabase auth changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners(); // Notify immediately on creation
    _subscription = stream.asBroadcastStream().listen(
          (event) => notifyListeners(),
        );
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}