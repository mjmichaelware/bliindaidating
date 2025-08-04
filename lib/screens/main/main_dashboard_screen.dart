// lib/screens/main/main_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bliindaidating/models/user_profile.dart'; // UserProfile
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_app_bar.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_content_switcher.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_side_menu.dart';
import 'package:bliindaidating/widgets/dashboard_shell/side_menu_category_item.dart';

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

  // Define a list of all screens using simple placeholder widgets
  final List<Widget> _screens = const [
    Center(child: Text('Dashboard Overview Screen')),
    Center(child: Text('My Matches Screen')),
    Center(child: Text('Discovery Screen')),
    Center(child: Text('Newsfeed Screen')),
    Center(child: Text('Scheduled Dates Screen')),
    Center(child: Text('My Profile Screen')),
    Center(child: Text('Settings Screen')),
    Center(child: Text('Feedback Screen')),
    Center(child: Text('Report Screen')),
    Center(child: Text('About Us Screen')),
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
  }

  @override
  void dispose() {
    _sideMenuAnimationController.dispose();
    super.dispose();
  }

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
    // For smaller screens, collapse the menu after selection
    if (MediaQuery.of(context).size.width < 768) {
      _onToggleCollapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    // Use a dummy user profile with required fields and a valid DateTime
    final dummyUserProfile = UserProfile(
      id: 'dummy-id',
      email: 'dummy@example.com',
      fullLegalName: 'Starlight Seeker',
      profilePictureUrl: null,
      createdAt: DateTime.now(),
    );

    return Scaffold(
      appBar: isMobile
          ? DashboardAppBar(
              onMenuPressed: _onToggleCollapse,
            )
          : null, // Hide app bar on desktop
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
                if (!isMobile) // Show app bar on desktop
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
