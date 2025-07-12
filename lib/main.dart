// lib/main.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async'; // Required for StreamSubscription and ChangeNotifier
import 'package:provider/provider.dart'; // Import for state management

// Local imports - Ensure these files exist in your project structure
import 'package:bliindaidating/app_constants.dart'; // Import AppConstants from its dedicated file
import 'package:bliindaidating/theme/app_theme.dart'; // Import AppTheme from its dedicated file
import 'package:bliindaidating/controllers/theme_controller.dart'; // Import ThemeController
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile for redirect logic
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService for redirect logic
import 'package:bliindaidating/services/auth_service.dart'; // Import AuthService for redirect logic

// Screens imports - Ensure all these paths are correct and these files exist.
import 'package:bliindaidating/landing_page/landing_page.dart';
import 'package:bliindaidating/screens/portal/portal_page.dart';
import 'package:bliindaidating/auth/login_screen.dart';
import 'package:bliindaidating/auth/signup_screen.dart';
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart'; // Ensure this is the correct path

// Existing profile setup screens from your tree
import 'package:bliindaidating/profile/profile_setup_screen.dart'; // This is Phase 1 setup
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

// Existing NEW IMPORTS for screens (ENSURE THESE ARE CORRECT)
import 'package:bliindaidating/screens/notifications/notifications_screen.dart';
import 'package:bliindaidating/screens/profile/profile_view_screen.dart'; // For /profile/:userId dynamic route
import 'package:bliindaidating/screens/profile/my_profile_screen.dart'; // ADDED: For /my-profile static route
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart'; // ADDED: For /questionnaire-phase2 route


// Define the environment variables at the top level using const String.fromEnvironment
const String _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);
const String _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '',
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

  debugPrint('>>> Build Mode: ${const bool.fromEnvironment('dart.vm.product') ? 'RELEASE' : 'DEBUG'}');
  debugPrint('>>> Supabase URL from env: $_supabaseUrl');
  debugPrint('>>> Supabase Anon Key from env: $_supabaseAnonKey');

  try {
    if (const bool.fromEnvironment('dart.vm.product')) {
      if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
        throw Exception('Supabase credentials (URL or Anon Key) are missing in RELEASE build. '
                         'Ensure --dart-define or --dart-define-from-file are used.');
      }
    }

    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
      debug: !const bool.fromEnvironment('dart.vm.product'),
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeController()),
          ChangeNotifierProvider(create: (context) => ProfileService()),
          ChangeNotifierProvider(create: (context) => AuthService(context.read<ProfileService>())),
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
              textAlign: TextAlign.center,
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
  late final AuthService _authService;
  late final ProfileService _profileService;


  @override
  void initState() {
    super.initState();
    _authService = context.read<AuthService>();
    _profileService = context.read<ProfileService>();

    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: Listenable.merge([
        GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
        _profileService,
      ]),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LandingPage()),
        GoRoute(path: '/portal_hub', builder: (context, state) => const PortalPage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),

        // MainDashboardScreen should be const and doesn't need a parameter here
        GoRoute(path: '/home', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/profile_setup', builder: (context, state) => const ProfileSetupScreen()),
        GoRoute(path: '/questionnaire-phase2', builder: (context, state) => const Phase2SetupScreen()),
        GoRoute(path: '/my-profile', builder: (context, state) => const MyProfileScreen()),

        GoRoute(path: '/edit_profile', builder: (context, state) => const ProfileTabsScreen()),
        GoRoute(path: '/about_me', builder: (context, state) => const AboutMeScreen()),
        GoRoute(path: '/availability', builder: (context, state) => const AvailabilityScreen()),
        GoRoute(path: '/interests', builder: (context, state) => const InterestsScreen()),

        GoRoute(path: '/events', builder: (context, state) => const LocalEventsScreen(events: [])),

        GoRoute(path: '/penalties', builder: (context, state) => const PenaltyDisplayScreen()),

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

        GoRoute(path: '/about-us', builder: (context, state) => const AboutUsScreen()),
        GoRoute(path: '/privacy', builder: (context, state) => const PrivacyScreen()),
        GoRoute(path: '/terms', builder: (context, state) => const TermsScreen()),
      ],
      redirect: (context, state) async {
        final authService = context.read<AuthService>();
        final profileService = context.read<ProfileService>();

        final User? currentUser = authService.currentUser;
        final bool loggedIn = currentUser != null;
        final String currentPath = state.matchedLocation;

        final bool isAuthPath = currentPath == '/login' || currentPath == '/signup';
        final bool isOnPublicInitialPage = currentPath == '/' || currentPath == '/portal_hub';

        final bool goingToProfileSetup = currentPath == '/profile_setup';
        final bool goingToPhase2Setup = currentPath == '/questionnaire-phase2';
        final bool goingToDashboard = currentPath == '/home';

        final List<String> publicInfoPaths = [
          '/about-us',
          '/privacy',
          '/terms',
        ];
        final bool isOnPublicInfoPath = publicInfoPaths.contains(currentPath);

        debugPrint('GoRouter Redirect Status:');
        debugPrint('  Current Path: $currentPath');
        debugPrint('  Logged In: $loggedIn');
        debugPrint('  Is Auth Path: $isAuthPath');
        debugPrint('  Is On Public Initial Page: $isOnPublicInitialPage');
        debugPrint('  Is On Public Info Path: $isOnPublicInfoPath');


        if (isOnPublicInfoPath) {
          debugPrint('  Redirect decision: On public info path. Allowing navigation.');
          return null;
        }

        if (!loggedIn) {
          if (!isAuthPath && !isOnPublicInitialPage) {
            debugPrint('  Redirect decision: Not logged in and on protected page. Redirecting to /');
            return '/';
          }
          debugPrint('  Redirect decision: Not logged in but on auth/public path. Allowing navigation.');
          return null;
        }

        final bool isPhase1Complete = profileService.userProfile?.isPhase1Complete ?? false;
        final bool isPhase2Complete = profileService.userProfile?.isPhase2Complete ?? false;
        debugPrint('  Is Phase 1 Complete: $isPhase1Complete');
        debugPrint('  Is Phase 2 Complete: $isPhase2Complete');

        if (!isPhase1Complete) {
          if (!goingToProfileSetup) {
            debugPrint('  Redirect decision: Logged in, Phase 1 NOT complete. Redirecting to /profile_setup');
            return '/profile_setup';
          }
          debugPrint('  Redirect decision: Logged in, Phase 1 NOT complete, on /profile_setup. Allowing.');
          return null;
        }

        if (!isPhase2Complete) {
          if (isAuthPath || isOnPublicInitialPage || goingToProfileSetup) {
            debugPrint('  Redirect decision: Logged in, Phase 1 complete, Phase 2 NOT complete, on auth/public/phase1 page. Redirecting to /home.');
            return '/home';
          }
          if (goingToDashboard || goingToPhase2Setup) {
             debugPrint('  Redirect decision: Logged in, Phase 1 complete, Phase 2 NOT complete, on /home or /questionnaire-phase2. Allowing.');
             return null;
          }
          debugPrint('  Redirect decision: Logged in, Phase 1 complete, Phase 2 NOT complete, on other protected page. Allowing (but expect UI guidance).');
          return null;
        }

        if (isAuthPath || isOnPublicInitialPage || goingToProfileSetup || goingToPhase2Setup) {
          debugPrint('  Redirect decision: Logged in, BOTH phases complete, on auth/public/setup page. Redirecting to /home');
          return '/home';
        }

        debugPrint('  Redirect decision: No specific redirection needed. Allowing current path.');
        return null;
      },
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: themeController.isDarkMode ? AppTheme.galaxyTheme : AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
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
