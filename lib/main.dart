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
import 'package:bliindaidating/profile/profile_setup_screen.dart';

// Service Imports
import 'package:bliindaidating/services/newsfeed_service.dart';
import 'package:bliindaidating/services/questionnaire_service.dart';
import 'package:bliindaidating/services/ai_logic_service.dart';
import 'package:bliindaidating/services/matches_service.dart';

// Screen Imports
import 'package:bliindaidating/auth/login_screen.dart';
import 'package:bliindaidating/auth/signup_screen.dart';
import 'package:bliindaidating/screens/auth/forgot_password_screen.dart';
import 'package:bliindaidating/landing_page/landing_page.dart';
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart';
import 'package:bliindaidating/screens/utility/loading_screen.dart';
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('main: WidgetsFlutterBinding ensured initialized.');

  String supabaseUrl;
  String supabaseAnonKey;
  String geminiApiKey;

  if (kReleaseMode) {
    supabaseUrl = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    debugPrint('main: Running in Release Mode. Variables from --dart-define.');
  } else {
    try {
      await dotenv.load(fileName: ".env");
      supabaseUrl = dotenv.env['SUPABASE_URL']!;
      supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
      geminiApiKey = dotenv.env['GEMINI_API_KEY']!;
      debugPrint('main: Running in Debug Mode. .env file loaded successfully!');
    } catch (e) {
      debugPrint('main: Error loading .env file in Debug Mode: $e');
      throw Exception('Missing .env file for local debug or keys not found: $e');
    }
  }

  debugPrint('--- Environment Variable Verification ---');
  debugPrint('Supabase URL (after load): "$supabaseUrl"');
  debugPrint('Supabase Anon Key (after load): ${supabaseAnonKey.isNotEmpty ? '*** (loaded)' : 'NOT LOADED / EMPTY'}');
  debugPrint('Gemini API Key (after load): ${geminiApiKey.isNotEmpty ? '*** (loaded)' : 'NOT LOADED / EMPTY'}');
  debugPrint('-----------------------------------------');

  try {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty || supabaseUrl == 'YOUR_SUPABASE_URL' || supabaseAnonKey == 'YOUR_SUPABASE_ANON_KEY') {
      debugPrint('main: Supabase URL or Anon Key not found or are default placeholders! Throwing exception. (Values were: URL="$supabaseUrl", Key="${supabaseAnonKey.isNotEmpty ? '***' : 'empty'}")');
      throw Exception('Missing Supabase environment variables. Please ensure they are correctly set for the current build mode (via .env for debug, or --dart-define for release).');
    }

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
        Provider<AiLogicService>(
          create: (context) => AiLogicService(),
        ),
        ChangeNotifierProvider<NewsfeedService>(
          create: (context) => NewsfeedService(context.read<AiLogicService>()),
        ),
        ChangeNotifierProvider<QuestionnaireService>(
          create: (context) => QuestionnaireService(),
        ),
        Provider<MatchesService>(
          create: (context) => MatchesService(),
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
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    debugPrint('BlindAIDatingApp: initState called.');
    final profileService = Provider.of<ProfileService>(context, listen: false);

    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.signedOut) {
        debugPrint('Auth state changed: $event. Triggering profileService.initializeProfile().');
        profileService.initializeProfile();
      }
    });

    _router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode,
      refreshListenable: Listenable.merge([
        Provider.of<AuthService>(context, listen: false),
        profileService,
      ]),
      redirect: (BuildContext context, GoRouterState state) {
        final AuthService authService = context.read<AuthService>();
        final ProfileService profileService = context.read<ProfileService>();

        final bool isLoggedIn = authService.isLoggedIn;
        final bool isProfileLoaded = profileService.isProfileLoaded;
        
        final String currentPath = state.fullPath ?? '/';

        final bool isAuthPath = ['/login', '/signup', '/forgot-password', '/'].contains(currentPath);
        final bool isUtilityPath = currentPath == '/loading';

        debugPrint('--- GoRouter Redirect Evaluation ---');
        debugPrint('Current Path: $currentPath');
        debugPrint('Is Logged In: $isLoggedIn');
        debugPrint('Is Profile Loaded: $isProfileLoaded');

        // SCENARIO 1: User is NOT logged in.
        if (!isLoggedIn) {
          debugPrint('Redirect Logic: User NOT logged in.');
          return isAuthPath ? null : '/login';
        }

        // SCENARIO 2: User IS logged in.
        debugPrint('Redirect Logic: User IS logged in.');
        
        // If the profile data hasn't finished its initial load, show a loading screen.
        if (!isProfileLoaded) {
          debugPrint('Redirect Logic: Profile data not yet loaded. Redirecting to /loading.');
          return isUtilityPath ? null : '/loading';
        }

        // --- UPDATED LOGIC: CHECK PHASE 1 COMPLETION ---
        final UserProfile? userProfile = profileService.userProfile;

        // At this point, the user is logged in, and profile data is loaded.
        if (userProfile != null) {
            // If Phase 1 is NOT complete, redirect to the profile setup screen.
            if (!userProfile.isPhase1Complete) {
                debugPrint('Redirect Logic: Profile exists but Phase 1 is incomplete. Redirecting to profile setup.');
                // Only redirect if not already on the profile setup screen.
                return currentPath == '/profile_setup' ? null : '/profile_setup';
            }

            // If Phase 1 IS complete, redirect to the main dashboard.
            debugPrint('Redirect Logic: Profile Phase 1 complete. Redirecting to main dashboard.');
            return (isAuthPath || isUtilityPath || currentPath == '/profile_setup') ? '/dashboard-overview' : null;
        }

        // If the profile data is unexpectedly null after being "loaded", something is wrong.
        // As a fallback, redirect to the profile setup screen.
        debugPrint('Redirect Logic: Unexpected state - user is logged in but profile is null. Redirecting to setup.');
        return currentPath == '/profile_setup' ? null : '/profile_setup';
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LandingPage()),
        GoRoute(path: '/loading', builder: (context, state) => const LoadingScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
        GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
        GoRoute(path: '/profile_setup', builder: (context, state) => const ProfileSetupScreen()),
        GoRoute(path: '/questionnaire-phase2', builder: (context, state) => const Phase2SetupScreen()),
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
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
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
