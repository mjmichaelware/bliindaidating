// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kReleaseMode;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Local Imports
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/services/auth_service.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/theme/app_theme.dart';
import 'package:bliindaidating/models/user_profile.dart';

// Service Imports
import 'package:bliindaidating/services/newsfeed_service.dart';
import 'package:bliindaidating/services/questionnaire_service.dart';

// Platform utilities
import 'package:bliindaidating/platform_utils/platform_helper_factory.dart';

// Screen Imports
import 'package:bliindaidating/auth/login_screen.dart';
import 'package:bliindaidating/auth/signup_screen.dart';
import 'package:bliindaidating/screens/auth/forgot_password_screen.dart';
import 'package:bliindaidating/landing_page/landing_page.dart';
import 'package:bliindaidating/profile/profile_setup_screen.dart';
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart';
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart';
import 'package:bliindaidating/screens/utility/loading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('main: WidgetsFlutterBinding ensured initialized.');

  String supabaseUrl;
  String supabaseAnonKey;
  String geminiApiKey;

  // --- CONDITIONAL LOGIC FOR ENVIRONMENT VARIABLES ---
  if (kReleaseMode) {
    supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
    geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY');
    debugPrint('main: Running in Release Mode. Variables from --dart-define.');
  } else {
    try {
      await dotenv.load(fileName: ".env");
      supabaseUrl = dotenv.env['SUPABASE_URL']!;
      supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
      geminiApiKey = dotenv.env['GEMINI_API_KEY']!;
      debugPrint('main: Running in Debug Mode. .env file loaded successfully!');
      debugPrint('main: Loaded env variables in debug: ${dotenv.env}');
    } catch (e) {
      debugPrint('main: Error loading .env file in Debug Mode: $e');
      throw Exception('Missing .env file for local debug or keys not found: $e');
    }
  }
  // --- END CONDITIONAL LOGIC ---

  // --- Environment Variable Verification Prints ---
  debugPrint('--- Environment Variable Verification ---');
  debugPrint('Supabase URL (after load): "$supabaseUrl"');
  debugPrint('Supabase Anon Key (after load): ${supabaseAnonKey.isNotEmpty ? '*** (loaded)' : 'NOT LOADED / EMPTY'}');
  debugPrint('Gemini API Key (after load): ${geminiApiKey.isNotEmpty ? '*** (loaded)' : 'NOT LOADED / EMPTY'}');
  debugPrint('-----------------------------------------');

  // --- Start of NEW PLATFORM UTILS INTEGRATION ---
  final platformHelper = getPlatformHelpers();
  debugPrint('main: Current platform type: ${platformHelper.getPlatformType()}');
  platformHelper.doSomethingPlatformSpecific();
  // --- End of NEW PLATFORM UTILS INTEGRATION ---

  // --- Initialize Supabase using the determined environment variables ---
  try {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty || supabaseUrl == 'SUPABASE_URL' || supabaseAnonKey == 'SUPABASE_ANON_KEY') {
      debugPrint('main: Supabase URL or Anon Key not found! Throwing exception. (Values were: URL="$supabaseUrl", Key="${supabaseAnonKey.isNotEmpty ? '***' : 'empty'}")');
      throw Exception('Missing Supabase environment variables. Please ensure they are correctly set for the current build mode (via .env for debug, or --dart-define for release).');
    }

    // Set Gemini API Key in AppConstants
    AppConstants.geminiApiKey = geminiApiKey;

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint('main: Supabase initialized successfully!');
  } catch (e) {
    debugPrint('main: Error initializing Supabase: $e');
    rethrow;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeController(),
        ),
        ChangeNotifierProvider<ProfileService>(
          create: (context) => ProfileService(Supabase.instance.client),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(
            Provider.of<ProfileService>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<NewsfeedService>(
          create: (context) => NewsfeedService(),
        ),
        ChangeNotifierProvider<QuestionnaireService>(
          create: (context) => QuestionnaireService(),
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

    final ProfileService profileService = Provider.of<ProfileService>(context, listen: false);
    
    // FIX: Schedule initializeProfile to run after the current frame is built
    // This prevents calling notifyListeners during the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileService.initializeProfile();
      debugPrint('BlindAIDatingApp: profileService.initializeProfile() scheduled via postFrameCallback.');
    });

    _router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode,
      refreshListenable: Listenable.merge([
        Provider.of<AuthService>(context, listen: false),
        Provider.of<ProfileService>(context, listen: false),
      ]),
      redirect: (BuildContext context, GoRouterState state) {
        final AuthService authService = Provider.of<AuthService>(context, listen: false);
        final ProfileService profileService = Provider.of<ProfileService>(context, listen: false);

        final bool isLoggedIn = authService.isLoggedIn;
        final bool isProfileLoaded = profileService.isProfileLoaded;
        final UserProfile? userProfile = profileService.userProfile;

        final bool phase1Complete = userProfile?.isPhase1Complete ?? false;
        final bool phase2Complete = userProfile?.isPhase2Complete ?? false;

        final String currentPath = state.fullPath ?? '/';

        final bool isAuthPath = currentPath == '/login' ||
            currentPath == '/signup' ||
            currentPath == '/forgot-password';
        final bool isLandingPath = currentPath == '/';
        final bool isUtilityPath = currentPath == '/loading';

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
        if (!isProfileLoaded) {
          debugPrint('Redirect Logic: Profile data not yet initially loaded. Current path: $currentPath');
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
            debugPrint('Redirect Logic: Redirecting from public/landing/loading to /dashboard-overview (Phase 2 incomplete, show banner).');
            return '/dashboard-overview';
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
          debugPrint('Redirect Logic: Logged in, Phase 1 complete, Phase 2 incomplete. Redirecting to /dashboard-overview to show banner.');
          return currentPath == '/dashboard-overview' ? null : '/dashboard-overview';
        }

        // If user is logged in, and both phases are complete, they can access any authenticated route.
        debugPrint('Redirect Logic: Logged in, and all profile phases complete. Allowing current path: $currentPath');
        return null; // Allow access to the requested path
      },
      routes: [
        // Standard Routes
        GoRoute(path: '/', builder: (context, state) => const LandingPage()),
        GoRoute(path: '/loading', builder: (context, state) => const LoadingScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
        GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
        GoRoute(path: '/profile_setup', builder: (context, state) => const ProfileSetupScreen()),
        GoRoute(path: '/questionnaire-phase2', builder: (context, state) => const Phase2SetupScreen()),

        // All dashboard-related routes point to MainDashboardScreen.
        GoRoute(path: '/dashboard-overview', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/newsfeed', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/matches', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/discovery', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/my-profile', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/questionnaire', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/daily-prompts', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/favorites', builder: (context, state) => const MainDashboardScreen()),

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