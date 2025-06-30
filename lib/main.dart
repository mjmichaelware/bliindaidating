import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase import

// Import your screens.
import 'package:bliindaidating/landing_page/landing_page.dart';
import 'package:bliindaidating/screens/portal/portal_page.dart';
import 'package:bliindaidating/auth/login_screen.dart';
import 'package:bliindaidating/auth/signup_screen.dart';
import 'package:bliindaidating/screens/main/home_screen.dart';
import 'package:bliindaidating/profile/profile_setup_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Client
  // IMPORTANT: Replace 'YOUR_SUPABASE_URL' and 'YOUR_SUPABASE_ANON_KEY'
  // with your actual Supabase project details from your Supabase Dashboard -> Settings -> API.
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL', // e.g., 'https://abcde12345.supabase.co'
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // e.g., 'eyJhbGciOiJIUzI1NiI...'
    // authFlowType: AuthFlowType.pkce, // REMOVED: This parameter is not available in resolved supabase_flutter version
  );

  runApp(const BlindAIDatingApp());
}

class BlindAIDatingApp extends StatelessWidget {
  const BlindAIDatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: '/portal_hub',
          builder: (context, state) => const PortalPage(),
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
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/profile_setup',
          builder: (context, state) => const ProfileSetupScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Blind AI Dating',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.black,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
