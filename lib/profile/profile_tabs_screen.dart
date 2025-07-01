// lib/profile/profile_tabs_screen.dart
import 'package:flutter/material.dart';
import 'package:bliindaidating/profile/about_me_screen.dart'; // Ensure correct path
import 'package:bliindaidating/profile/availability_screen.dart'; // Ensure correct path
import 'package:bliindaidating/profile/interests_screen.dart'; // Ensure correct path

class ProfileTabsScreen extends StatelessWidget {
  const ProfileTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.deepPurple.shade900,
          elevation: 0,
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontFamily: 'Inter', // Assuming Inter font is declared
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.redAccent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'About Me'),
              Tab(text: 'Availability'),
              Tab(text: 'Interests'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AboutMeScreen(),
            AvailabilityScreen(),
            InterestsScreen(),
          ],
        ),
      ),
    );
  }
}
