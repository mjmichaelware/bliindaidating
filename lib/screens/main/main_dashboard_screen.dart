// lib/screens/main/main_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_app_bar.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_content_switcher.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_side_menu.dart';

// Import all the services we are now using
import 'package:bliindaidating/services/ai_logic_service.dart';
import 'package:bliindaidating/services/newsfeed_service.dart';
import 'package:bliindaidating/services/matches_service.dart';
import 'package:bliindaidating/services/date_service.dart'; // The new service

// Import the new dedicated screens
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isCollapsed = false;
  late final AnimationController _sideMenuAnimationController;
  late final Animation<double> _sideMenuExpandAnimation;
  int _selectedTabIndex = 0;
  // Removed _isLoading state

  @override
  void initState() {
    super.initState();
    _sideMenuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _sideMenuExpandAnimation = CurvedAnimation(
      parent: _sideMenuAnimationController,
      curve: Curves.easeInOut,
    );
    _sideMenuAnimationController.forward();
    // Removed the _fetchDashboardData() call from here
  }

  @override
  void dispose() {
    _sideMenuAnimationController.dispose();
    super.dispose();
  }

  // Removed _fetchDashboardData()
  
  void _onToggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
      if (_isCollapsed) {
        _sideMenuAnimationController.reverse();
      } else {
        _sideMenuAnimationController.forward();
      }
    });
  }

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    if (MediaQuery.of(context).size.width < 768) {
      _onToggleCollapse();
    }
  }

  // Moved all the screen widgets into the _screens list directly
  late final List<Widget> _screens = [
    // A simple dashboard overview screen with no data fetching
    const Center(child: Text('Dashboard Overview')),
    const Center(child: Text('My Matches Screen')),
    const Center(child: Text('Discovery Screen')),
    const NewsfeedScreen(), // Use the refactored NewsfeedScreen
    const Center(child: Text('Scheduled Dates Screen')),
    const Center(child: Text('My Profile Screen')),
    const Center(child: Text('Settings Screen')),
    const Center(child: Text('Feedback Screen')),
    const Center(child: Text('Report Screen')),
    const Center(child: Text('About Us Screen')),
  ];

  final List<String> _screenTitles = const [
    'Dashboard',
    'My Matches',
    'Discovery',
    'Newsfeed',
    'Scheduled Dates',
    'My Profile',
    'Settings',
    'Feedback',
    'Report',
    'About Us',
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final dummyUserProfile = UserProfile(
      id: 'dummy-id',
      email: 'dummy@example.com',
      fullLegalName: 'Starlight Seeker',
      profilePictureUrl: 'https://placehold.co/150x150/252f3f/FFFFFF?text=User',
      createdAt: DateTime.now(),
    );

    return Scaffold(
      appBar: isMobile
          ? DashboardAppBar(
              onMenuPressed: _onToggleCollapse,
            )
          : null,
      body: Row(
        children: [
          DashboardSideMenu(
            isCollapsed: _isCollapsed,
            expandAnimation: _sideMenuExpandAnimation,
            onToggleCollapse: _onToggleCollapse,
            profileHeader: SideMenuProfileHeader(
              userProfile: dummyUserProfile,
              profilePictureUrl: dummyUserProfile.profilePictureUrl,
              isCollapsed: _isCollapsed,
              expandAnimation: _sideMenuExpandAnimation,
            ),
            children: [
              SideMenuItem(
                title: _screenTitles[0],
                icon: Icons.dashboard_rounded,
                onTap: () => _onMenuItemSelected(0),
                isCollapsed: _isCollapsed,
              ),
              SideMenuCategoryItem(
                title: 'Core Features',
                icon: Icons.favorite_rounded,
                isCollapsed: _isCollapsed,
                expandAnimation: _sideMenuExpandAnimation,
                children: [
                  SideMenuItem(
                    title: _screenTitles[1],
                    icon: Icons.people_rounded,
                    onTap: () => _onMenuItemSelected(1),
                    isCollapsed: _isCollapsed,
                  ),
                  SideMenuItem(
                    title: _screenTitles[2],
                    icon: Icons.search_rounded,
                    onTap: () => _onMenuItemSelected(2),
                    isCollapsed: _isCollapsed,
                  ),
                  SideMenuItem(
                    title: _screenTitles[3],
                    icon: Icons.article_rounded,
                    onTap: () => _onMenuItemSelected(3),
                    isCollapsed: _isCollapsed,
                  ),
                  SideMenuItem(
                    title: _screenTitles[4],
                    icon: Icons.calendar_today_rounded,
                    onTap: () => _onMenuItemSelected(4),
                    isCollapsed: _isCollapsed,
                  ),
                ],
              ),
              SideMenuCategoryItem(
                title: 'User Management',
                icon: Icons.settings_rounded,
                isCollapsed: _isCollapsed,
                expandAnimation: _sideMenuExpandAnimation,
                children: [
                  SideMenuItem(
                    title: _screenTitles[5],
                    icon: Icons.person_rounded,
                    onTap: () => _onMenuItemSelected(5),
                    isCollapsed: _isCollapsed,
                  ),
                  SideMenuItem(
                    title: _screenTitles[6],
                    icon: Icons.tune_rounded,
                    onTap: () => _onMenuItemSelected(6),
                    isCollapsed: _isCollapsed,
                  ),
                ],
              ),
              SideMenuCategoryItem(
                title: 'Help & Support',
                icon: Icons.help_rounded,
                isCollapsed: _isCollapsed,
                expandAnimation: _sideMenuExpandAnimation,
                children: [
                  SideMenuItem(
                    title: _screenTitles[7],
                    icon: Icons.feedback_rounded,
                    onTap: () => _onMenuItemSelected(7),
                    isCollapsed: _isCollapsed,
                  ),
                  SideMenuItem(
                    title: _screenTitles[8],
                    icon: Icons.report_rounded,
                    onTap: () => _onMenuItemSelected(8),
                    isCollapsed: _isCollapsed,
                  ),
                  SideMenuItem(
                    title: _screenTitles[9],
                    icon: Icons.info_rounded,
                    onTap: () => _onMenuItemSelected(9),
                    isCollapsed: _isCollapsed,
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                if (!isMobile)
                  DashboardAppBar(
                    onMenuPressed: _onToggleCollapse,
                  ),
                Expanded(
                  child: DashboardContentSwitcher(
                    selectedTabIndex: _selectedTabIndex,
                    screens: _screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}