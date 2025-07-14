import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async'; // Required for StreamSubscription and ChangeNotifier
import 'package:provider/provider.dart'; // Import for state management
import 'package:flutter/foundation.dart'; // For debugPrint

// Local imports for core project components
import 'package:bliindaidating/app_constants.dart'; // Import app_constants for theme
import 'package:bliindaidating/theme/app_theme.dart'; // IMPORTANT: Import AppTheme from its dedicated file
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
          // ProfileService uses its parameterless constructor
          ChangeNotifierProvider(create: (context) => ProfileService()),
          // This line is correct, assuming AuthService constructor is `AuthService(ProfileService profileService)`
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

    // Initialize the profile service on app start.
    // This will fetch the profile if a user is already logged in from a previous session.
    _profileService.initializeProfile();

    // Listen to authentication state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      debugPrint('Auth State Change Event: $event');

      if (event == AuthChangeEvent.signedIn && session != null) {
        // When signed in, trigger a profile load.
        // The `initializeProfile` might have already handled `initialSession`,
        // but this ensures it's loaded on explicit `signedIn` events too.
        _profileService.fetchUserProfile(session.user!.id);
      } else if (event == AuthChangeEvent.signedOut) {
        // Clear the user profile in the service when signed out
        _profileService.clearProfile();
      }
      // `_profileService` is part of `Listenable.merge` below, so its `notifyListeners()`
      // calls will trigger router refresh. No explicit `_router.refresh()` needed here.
    });


    _router = GoRouter(
      initialLocation: '/',
      // Combine refresh listenables for both authentication and profile changes
      refreshListenable: Listenable.merge([
        GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
        _profileService, // Now GoRouter also listens to ProfileService changes
      ]),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LandingPage()),
        GoRoute(path: '/portal_hub', builder: (context, state) => const PortalPage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),

        // Main Dashboard and Profile Setup Routes
        GoRoute(path: '/home', builder: (context, state) => const MainDashboardScreen()),
        GoRoute(path: '/profile_setup', builder: (context, state) => const ProfileSetupScreen()), // Phase 1 setup
        GoRoute(path: '/questionnaire-phase2', builder: (context, state) => const Phase2SetupScreen()), // Phase 2 setup
        GoRoute(path: '/my-profile', builder: (context, state) => const MyProfileScreen()), // Current user's profile view/edit

        // Profile Editing/Setup Sub-screens (assuming these are used within ProfileTabsScreen or similar)
        GoRoute(path: '/edit_profile', builder: (context, state) => const ProfileTabsScreen()),
        GoRoute(path: '/about_me', builder: (context, state) => const AboutMeScreen()),
        GoRoute(path: '/availability', builder: (context, state) => const AvailabilityScreen()),
        GoRoute(path: '/interests', builder: (context, state) => const InterestsScreen()),

        // Friends & Events
        GoRoute(path: '/events', builder: (context, state) => const LocalEventsScreen(events: [])),

        // Matching & Penalties
        GoRoute(path: '/penalties', builder: (context, state) => const PenaltyDisplayScreen()),

        // Discovery Routes
        GoRoute(path: '/discovery', builder: (context, state) => const DiscoveryScreen()),

        // Matches Routes
        GoRoute(path: '/matches', builder: (context, state) => const MatchesListScreen()),

        // Settings, Feedback, Admin, Notifications
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/feedback', builder: (context, state) => const FeedbackScreen()),
        GoRoute(path: '/report', builder: (context, state) => const ReportScreen()),
        GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),

        // Dynamic Profile View
        GoRoute(
          path: '/profile/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId'];
            if (userId == null) return const NotFoundScreen();
            return ProfileViewScreen(userId: userId);
          },
        ),

        // Public Info Screens (Privacy Policy, Terms, About Us) - always visible
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

        // Define public info paths that don't require login or profile completion
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
        debugPrint('  Is Profile Service Loaded: ${profileService.isProfileLoaded}');


        // 1. ALLOW PUBLIC INFO PATHS WITHOUT REDIRECTION, REGARDLESS OF LOGIN OR PROFILE COMPLETION
        if (isOnPublicInfoPath) {
          debugPrint('  Redirect decision: On public info path. Allowing navigation.');
          return null;
        }

        // 2. If ProfileService hasn't finished its initial load, wait.
        // This prevents redirects based on stale or uninitialized profile data.
        if (!profileService.isProfileLoaded) {
          debugPrint('  Redirect decision: Profile service not loaded yet. Waiting...');
          return state.matchedLocation; // Stay on the current path until loaded
        }

        // 3. If not logged in, redirect to landing or auth pages (unless already there)
        if (!loggedIn) {
          if (!isAuthPath && !isOnPublicInitialPage) {
            debugPrint('  Redirect decision: Not logged in and on protected page. Redirecting to /');
            return '/';
          }
          debugPrint('  Redirect decision: Not logged in but on auth/public path. Allowing navigation.');
          return null;
        }

        // --- User is logged in from here ---

        // At this point, `profileService.userProfile` should be populated
        // if `initializeProfile` was called successfully after sign-in.
        final bool isPhase1Complete = profileService.userProfile?.isPhase1Complete ?? false;
        final bool isPhase2Complete = profileService.userProfile?.isPhase2Complete ?? false;
        debugPrint('  Is Phase 1 Complete: $isPhase1Complete');
        debugPrint('  Is Phase 2 Complete: $isPhase2Complete');

        // 4. If logged in but Phase 1 is NOT complete, redirect to /profile_setup
        if (!isPhase1Complete) {
          // If we are already going to profile_setup, allow it. Otherwise, redirect.
          if (!goingToProfileSetup) {
            debugPrint('  Redirect decision: Logged in, Phase 1 NOT complete. Redirecting to /profile_setup');
            return '/profile_setup';
          }
          debugPrint('  Redirect decision: Logged in, Phase 1 NOT complete, on /profile_setup. Allowing.');
          return null;
        }

        // --- User is logged in AND Phase 1 is complete from here ---

        // 5. If Phase 2 is NOT complete:
        //    If trying to access auth paths, initial public pages, or phase1 setup, send to /home.
        //    The /home screen (MainDashboardScreen) should then guide the user to Phase 2.
        if (!isPhase2Complete) {
          if (isAuthPath || isOnPublicInitialPage || goingToProfileSetup) {
            debugPrint('  Redirect decision: Logged in, Phase 1 complete, Phase 2 NOT complete, on auth/public/phase1 page. Redirecting to /home.');
            return '/home';
          }
          // If already on /home or /questionnaire-phase2, allow it.
          if (goingToDashboard || goingToPhase2Setup) {
             debugPrint('  Redirect decision: Logged in, Phase 1 complete, Phase 2 NOT complete, on /home or /questionnaire-phase2. Allowing.');
             return null;
          }
          // For any other authenticated but not specific setup/dashboard page (e.g., /settings, /matches),
          // we allow it. It's assumed these pages might show a banner or warning about incomplete profile.
          debugPrint('  Redirect decision: Logged in, Phase 1 complete, Phase 2 NOT complete, on other protected page. Allowing (but expect UI guidance).');
          return null;
        }

        // --- User is logged in AND BOTH phases are complete from here ---

        // 6. If logged in AND both phases are complete:
        //    Redirect from auth/public/setup pages to /home (dashboard)
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
    // No explicit stream subscription to cancel here as it's handled by GoRouterRefreshStream
    // and Provider disposes ChangeNotifiers when no longer needed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ProfileService for changes (e.g., when profile is loaded)
    final profileService = Provider.of<ProfileService>(context);
    final themeController = Provider.of<ThemeController>(context); // Access ThemeController

    // Show a loading indicator until the initial profile load is complete
    // This prevents GoRouter from trying to redirect based on an uninitialized profile state
    if (!profileService.isProfileLoaded) {
      debugPrint('MyApp: Profile service not loaded, showing loading indicator.');
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: themeController.isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor,
            ),
          ),
        ),
      );
    }

    // Once profile is loaded, use GoRouter for navigation
    debugPrint('MyApp: Profile service loaded, building MaterialApp.router.');
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
    notifyListeners(); // Notify immediately with current state
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