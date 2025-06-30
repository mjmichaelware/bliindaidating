import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// IMPORTANT: Import your NEW, reimagined LandingPage from its correct, dedicated path.
import 'package:bliindaidating/landing_page/landing_page.dart';

// IMPORTANT: Import your EXISTING PortalPage (which is your login/signup hub).
import 'package:bliindaidating/screens/portal/portal_page.dart';

// Import your other core screens as they exist in your project.
import 'package:bliindaidating/auth/login_screen.dart';
import 'package:bliindaidating/auth/signup_screen.dart';
import 'package:bliindaidating/screens/main/home_screen.dart';
import 'package:bliindaidating/profile/profile_setup_screen.dart'; // NEW: Import your profile setup screen


void main() {
  // Ensure Flutter binding is initialized before using platform channels (not strictly needed without Firebase, but good practice)
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BlindAIDatingApp());
}

class BlindAIDatingApp extends StatelessWidget {
  const BlindAIDatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define your GoRouter configuration for app navigation
    // The app will now always start at the LandingPage as there's no Firebase auth to check.
    final GoRouter _router = GoRouter(
      initialLocation: '/', // The app will always start at the LandingPage
      routes: [
        GoRoute(
          path: '/',
          // This is the primary entry point, linking to your new, visually rich LandingPage.
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: '/portal_hub', // A NEW, DISTINCT route for your EXISTING PortalPage (login/signup hub).
          // The new LandingPage will navigate to this route.
          builder: (context, state) => const PortalPage(),
        ),
        GoRoute(
          path: '/login', // Your existing login screen route.
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup', // Your existing signup screen route.
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/home', // Your existing home screen route (e.g., post-authentication, now accessed via PortalPage buttons).
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/profile_setup', // NEW: Route for the profile setup screen
          builder: (context, state) => const ProfileSetupScreen(),
        ),
        // Add any other top-level routes here as they exist in your app's structure.
      ],
    );

    return MaterialApp.router(
      title: 'Blind AI Dating', // Corrected spelling for your app title.
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        // Base dark theme for the overall app, ensuring consistency.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // Ensures a true black background for the cosmic theme on the landing page.
        scaffoldBackgroundColor: Colors.black,
      ),
      routerConfig: _router, // Apply the GoRouter configuration.
      debugShowCheckedModeBanner: false, // Hide the debug banner in debug mode.
    );
  }
}
