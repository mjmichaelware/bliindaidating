// lib/app_router.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/landing_page/landing_page.dart';
import 'package:bliindaidating/auth/login_screen.dart';
import 'package:bliindaidating/auth/signup_screen.dart';

// Define route names as constants
class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  // Add other routes here: main dashboard, profile setup, etc.
  static const String mainDashboard = '/dashboard';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.landing:
        return MaterialPageRoute(builder: (_) => const LandingPage());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      // TODO: Add cases for other routes as you implement them
      // case AppRoutes.mainDashboard:
      //   return MaterialPageRoute(builder: (_) => const MainDashboardScreen());
      default:
        // Fallback for unknown routes
        return MaterialPageRoute(
            builder: (_) => const Text('Error: Unknown route'));
    }
  }
}
