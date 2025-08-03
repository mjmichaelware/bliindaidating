// lib/screens/main/main_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Core imports
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart'; // User profile model
import 'package:bliindaidating/services/profile_service.dart'; // Profile service

// Dashboard Shell Imports
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_app_bar.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_side_menu.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_content_switcher.dart';
import 'package:bliindaidating/widgets/dashboard_shell/side_menu_category_item.dart';
import 'package:bliindaidating/widgets/dashboard_shell/side_menu_item.dart';
import 'package:bliindaidating/widgets/dashboard_shell/side_menu_profile_header.dart';
import 'package:bliindaidating/widgets/dashboard_shell/side_menu_background_painter.dart';

// Landing Page Widget Imports for background theme
import 'package:bliindaidating/landing_page/landing_page.dart'; // We'll use the background painters from here

// Content Screen Imports for the Side Menu
import 'package:bliindaidating/screens/dashboard/dashboard_overview_screen.dart';
import 'package:bliindaidating/screens/matches/matches_list_screen.dart';
import 'package:bliindaidating/screens/discovery/discovery_screen.dart';
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart';
import 'package:bliindaidating/screens/date/scheduled_dates_list_screen.dart';
import 'package:bliindaidating/screens/friends/friends_match_screen.dart';
import 'package:bliindaidating/screens/profile/my_profile_screen.dart';
import 'package:bliindaidating/screens/settings/settings_screen.dart';
import 'package:bliindaidating/screens/feedback_report/feedback_screen.dart';
import 'package:bliindaidating/screens/feedback_report/report_screen.dart';
import 'package:bliindaidating/screens/info/about_us_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundNebulaController;
  late Animation<double> _backgroundNebulaAnimation;
  late AnimationController _particleController;
  late Animation<double> _particleAnimation;

  // Track the current selected screen to show in the content area
  Widget _currentContent = const DashboardOverviewScreen();
  String _currentTitle = 'Dashboard';

  final List<Offset> _nebulaParticles = [];
  final List<Offset> _deepSpaceParticles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _backgroundNebulaController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _backgroundNebulaAnimation = CurvedAnimation(parent: _backgroundNebulaController, curve: Curves.linear);

    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 25))..repeat(reverse: true);
    _particleAnimation = CurvedAnimation(parent: _particleController, curve: Curves.linear);

    _generateParticles(100, _nebulaParticles);
    _generateParticles(80, _deepSpaceParticles);
  }

  void _generateParticles(int count, List<Offset> particleList) {
    for (int i = 0; i < count; i++) {
      particleList.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  @override
  void dispose() {
    _backgroundNebulaController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _onMenuItemSelected(String title, Widget content) {
    setState(() {
      _currentTitle = title;
      _currentContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final backgroundColor = isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor;

    return Scaffold(
      body: Stack(
        children: [
          // Background Nebula
          SizedBox.expand(
            child: CustomPaint(
              painter: NebulaBackgroundPainter(
                _backgroundNebulaAnimation,
                primaryColor,
                secondaryColor,
              ),
            ),
          ),
          // Deep Space Particle Field
          SizedBox.expand(
            child: CustomPaint(
              painter: ParticleFieldPainter(
                _deepSpaceParticles,
                _particleAnimation,
                1.5,
                textColor.withOpacity(0.5),
              ),
            ),
          ),
          
          // Main Dashboard Shell
          Row(
            children: [
              // Side Menu
              DashboardSideMenu(
                onMenuItemSelected: _onMenuItemSelected,
                children: [
                  SideMenuProfileHeader(
                    userProfile: UserProfile(id: '', name: 'Starlight Seeker', avatarUrl: null),
                  ),
                  SideMenuItem(
                    title: 'Dashboard',
                    icon: Icons.space_dashboard_rounded,
                    onTap: () => _onMenuItemSelected('Dashboard', const DashboardOverviewScreen()),
                    isActive: _currentTitle == 'Dashboard',
                  ),
                  const SideMenuCategoryItem(title: 'Journey'),
                  SideMenuItem(
                    title: 'My Matches',
                    icon: Icons.favorite_rounded,
                    onTap: () => _onMenuItemSelected('My Matches', const MatchesListScreen()),
                    isActive: _currentTitle == 'My Matches',
                  ),
                  SideMenuItem(
                    title: 'Discovery',
                    icon: Icons.hub_rounded,
                    onTap: () => _onMenuItemSelected('Discovery', const DiscoveryScreen()),
                    isActive: _currentTitle == 'Discovery',
                  ),
                  SideMenuItem(
                    title: 'Newsfeed',
                    icon: Icons.rss_feed_rounded,
                    onTap: () => _onMenuItemSelected('Newsfeed', const NewsfeedScreen()),
                    isActive: _currentTitle == 'Newsfeed',
                  ),
                  SideMenuItem(
                    title: 'Scheduled Dates',
                    icon: Icons.calendar_today_rounded,
                    onTap: () => _onMenuItemSelected('Scheduled Dates', const ScheduledDatesListScreen()),
                    isActive: _currentTitle == 'Scheduled Dates',
                  ),
                  SideMenuItem(
                    title: 'Friends',
                    icon: Icons.group_rounded,
                    onTap: () => _onMenuItemSelected('Friends', const FriendsMatchScreen()),
                    isActive: _currentTitle == 'Friends',
                  ),
                  const SideMenuCategoryItem(title: 'Profile'),
                  SideMenuItem(
                    title: 'My Profile',
                    icon: Icons.person_rounded,
                    onTap: () => _onMenuItemSelected('My Profile', const MyProfileScreen()),
                    isActive: _currentTitle == 'My Profile',
                  ),
                  SideMenuItem(
                    title: 'Settings',
                    icon: Icons.settings_rounded,
                    onTap: () => _onMenuItemSelected('Settings', const SettingsScreen()),
                    isActive: _currentTitle == 'Settings',
                  ),
                  const SideMenuCategoryItem(title: 'Support'),
                  SideMenuItem(
                    title: 'Feedback',
                    icon: Icons.chat_bubble_rounded,
                    onTap: () => _onMenuItemSelected('Feedback', const FeedbackScreen()),
                    isActive: _currentTitle == 'Feedback',
                  ),
                  SideMenuItem(
                    title: 'Report',
                    icon: Icons.report_rounded,
                    onTap: () => _onMenuItemSelected('Report', const ReportScreen()),
                    isActive: _currentTitle == 'Report',
                  ),
                  SideMenuItem(
                    title: 'About Us',
                    icon: Icons.info_rounded,
                    onTap: () => _onMenuItemSelected('About Us', const AboutUsScreen()),
                    isActive: _currentTitle == 'About Us',
                  ),
                ],
              ),
              
              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    DashboardAppBar(title: _currentTitle),
                    Expanded(
                      child: DashboardContentSwitcher(
                        content: _currentContent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}