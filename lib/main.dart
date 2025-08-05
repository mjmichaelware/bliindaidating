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
import 'package:bliindaidating/profile/profile_setup_screen.dart';

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
import 'package:bliindaidating/screens/daily/daily_prompts_screen.dart';
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart';
import 'package:bliindaidating/screens/matches/matches_list_screen.dart'; // FIX: Correct import
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart';
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart';
import 'package:bliindaidating/screens/utility/loading_screen.dart';
import 'package:bliindaidating/screens/profile/my_profile_screen.dart';

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
        // FIX: Corrected constructor calls for NewsfeedService
        ChangeNotifierProxyProvider<AiLogicService, NewsfeedService>(
          create: (context) => NewsfeedService(aiLogicService: context.read<AiLogicService>()),
          update: (context, aiLogicService, newsfeedService) => newsfeedService!..updateAiLogicService(aiLogicService),
        ),
        ChangeNotifierProvider<QuestionnaireService>(
          create: (context) => QuestionnaireService(),
        ),
        // FIX: Corrected constructor calls for MatchesService
        ChangeNotifierProxyProvider<AiLogicService, MatchesService>(
          create: (context) => MatchesService(aiLogicService: context.read<AiLogicService>()),
          update: (context, aiLogicService, matchesService) => matchesService!..updateAiLogicService(aiLogicService),
        ),
      ],
      child: const BlindAIDatingApp(),
    ),
  );
}

// Key for the ShellRoute Navigator
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

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
              return '/newsfeed'; // Redirect to a child of the shell
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
        
        // This is the ShellRoute for the main app navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            // The child is the content of the currently selected route
            return MainDashboardShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/newsfeed',
              builder: (context, state) => const NewsfeedScreen(),
            ),
            GoRoute(
              path: '/matches',
              builder: (context, state) => const MatchesListScreen(), // FIX: Correctly call the MatchesListScreen
            ),
            GoRoute(
              path: '/daily-prompts',
              builder: (context, state) => const DailyPromptsScreen(),
            ),
            GoRoute(
              path: '/my-profile',
              builder: (context, state) => const MyProfileScreen(),
            ),
            // NOTE: Add your other main dashboard routes here.
          ],
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

// A new widget to act as the shell for the main dashboard screens.
class MainDashboardShell extends StatelessWidget {
  const MainDashboardShell({required this.child, super.key});

  final Widget child;

  // This method maps the current location to the index of the nav bar
  int _calculateSelectedIndex(BuildContext context) {
    // FIX: Replaced GoRouter.of(context).location with GoRouterState.of(context).fullPath
    final String location = GoRouterState.of(context).fullPath ?? '/';
    if (location.startsWith('/newsfeed')) return 0;
    if (location.startsWith('/matches')) return 1;
    if (location.startsWith('/daily-prompts')) return 2;
    if (location.startsWith('/my-profile')) return 3;
    return 0;
  }

  // This method navigates to the selected route
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/newsfeed');
        break;
      case 1:
        GoRouter.of(context).go('/matches');
        break;
      case 2:
        GoRouter.of(context).go('/daily-prompts');
        break;
      case 3:
        GoRouter.of(context).go('/my-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child, // The child widget is the current screen of the ShellRoute
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Newsfeed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt),
            label: 'Prompts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}