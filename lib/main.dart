import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Local Imports
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/theme/app_theme.dart';

// Service Imports
import 'package:bliindaidating/services/ai_logic_service.dart';
import 'package:bliindaidating/services/auth_service.dart';
import 'package:bliindaidating/services/matches_service.dart';
import 'package:bliindaidating/services/newsfeed_service.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/services/questionnaire_service.dart';

// Screen Imports
import 'package:bliindaidating/auth/login_screen.dart';
import 'package:bliindaidating/auth/signup_screen.dart';
import 'package:bliindaidating/landing_page/landing_page.dart';
import 'package:bliindaidating/screens/auth/forgot_password_screen.dart';
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart'; // Correctly import your dashboard screen
import 'package:bliindaidating/screens/profile_setup/profile_setup_screen.dart';
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart';
import 'package:bliindaidating/screens/utility/loading_screen.dart';

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
        // AiLogicService should be provided first since other services depend on it
        Provider<AiLogicService>(
          create: (context) => AiLogicService(),
        ),
        // NewsfeedService and MatchesService now directly create an instance of AiLogicService
        ChangeNotifierProvider<NewsfeedService>(
          create: (context) => NewsfeedService(aiLogicService: context.read<AiLogicService>()),
        ),
        ChangeNotifierProvider<MatchesService>(
          create: (context) => MatchesService(aiLogicService: context.read<AiLogicService>()),
        ),
        ChangeNotifierProvider<QuestionnaireService>(
          create: (context) => QuestionnaireService(),
        ),
      ],
      child: const BlindAIDatingApp(),
    ),
  );
}

// Key for the root Navigator
final _rootNavigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: _rootNavigatorKey,
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

        if (!isLoggedIn) {
          debugPrint('Redirect Logic: User NOT logged in.');
          return isAuthPath ? null : '/login';
        }

        debugPrint('Redirect Logic: User IS logged in.');
        
        if (!isProfileLoaded) {
          debugPrint('Redirect Logic: Profile data not yet loaded. Redirecting to /loading.');
          return isUtilityPath ? null : '/loading';
        }

        final UserProfile? userProfile = profileService.userProfile;

        if (userProfile != null) {
            if (!userProfile.isPhase1Complete) {
                debugPrint('Redirect Logic: Profile exists but Phase 1 is incomplete. Redirecting to profile setup.');
                return currentPath == '/profile_setup' ? null : '/profile_setup';
            }

            debugPrint('Redirect Logic: Profile Phase 1 complete. Redirecting to main dashboard.');
            if (isAuthPath || isUtilityPath || currentPath == '/profile_setup') {
              return '/dashboard'; // Corrected redirect to the new dashboard route
            }
            return null; // Don't redirect if already in a dashboard route
        }

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
        
        // This is the new, single route for the main dashboard screen
        GoRoute(
          path: '/dashboard',
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

// The MainDashboardShell widget is now removed as it is no longer needed.
// The MainDashboardScreen will handle all content display internally.