// lib/screens/dashboard/dashboard_overview_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class DashboardOverviewScreen extends StatelessWidget {
  const DashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('DashboardOverviewScreen: build START.');
    // If you add any other complex widgets or logic here later, add more debugPrints
    return const Center(
      child: Text(
        'Welcome to your Dashboard Overview!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
    // debugPrint('DashboardOverviewScreen: build END.'); // Cannot place after return
  }
}