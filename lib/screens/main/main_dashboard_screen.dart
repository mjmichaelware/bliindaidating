// lib/screens/main/main_dashboard_screen.dart

import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
import 'package:bliindaidating/services/date_service.dart';
import 'package:bliindaidating/services/profile_service.dart';

// Import the new dedicated screens
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart';

// This is the dedicated banner widget.
class ProfileSetupBanner extends StatelessWidget {
  const ProfileSetupBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Please complete your profile setup to unlock all features.',
              style: TextStyle(
                color: Colors.white, // Ensure text is visible
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Redirect to the Phase 2 setup screen
              GoRouter.of(context).go('/questionnaire-phase2');
            },
            child: Text(
              'Complete Now',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  void _onMenuItemSelected(int index, bool isProfileComplete) {
    // Only allow navigation to non-core features if the profile is incomplete.
    // Core features (index > 0) are disabled.
    if (!isProfileComplete && index > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your profile to access all features.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    setState(() {
      _selectedTabIndex = index;
    });
    if (MediaQuery.of(context).size.width < 768) {
      _onToggleCollapse();
    }
  }

  late final List<Widget> _screens = [
    const Center(child: Text('Dashboard Overview')),
    const Center(child: Text('My Matches Screen')),
    const Center(child: Text('Discovery Screen')),
    const NewsfeedScreen(),
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
    return Consumer<ProfileService>(
      builder: (context, profileService, child) {
        final isProfileComplete = profileService.userProfile?.isPhase2Complete ?? false;
        final userProfile = profileService.userProfile;
        final isMobile = MediaQuery.of(context).size.width < 768;

        // The main layout is a Scaffold.
        return Scaffold(
          key: _scaffoldKey,
          appBar: isMobile
              ? DashboardAppBar(
                  onMenuPressed: _onToggleCollapse,
                )
              : null,
          body: Column(
            children: [
              // Display the banner at the top if the profile is NOT complete.
              if (!isProfileComplete) const ProfileSetupBanner(),
              // The rest of the dashboard UI.
              Expanded(
                child: Stack(
                  children: [
                    Row(
                      children: [
                        DashboardSideMenu(
                          isCollapsed: _isCollapsed,
                          expandAnimation: _sideMenuExpandAnimation,
                          onToggleCollapse: _onToggleCollapse,
                          profileHeader: SideMenuProfileHeader(
                            userProfile: userProfile,
                            profilePictureUrl: userProfile?.profilePictureUrl,
                            isCollapsed: _isCollapsed,
                            expandAnimation: _sideMenuExpandAnimation,
                          ),
                          children: [
                            SideMenuItem(
                              title: _screenTitles[0],
                              icon: Icons.dashboard_rounded,
                              onTap: () => _onMenuItemSelected(0, isProfileComplete),
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
                                  onTap: () => _onMenuItemSelected(1, isProfileComplete),
                                  isCollapsed: _isCollapsed,
                                ),
                                SideMenuItem(
                                  title: _screenTitles[2],
                                  icon: Icons.search_rounded,
                                  onTap: () => _onMenuItemSelected(2, isProfileComplete),
                                  isCollapsed: _isCollapsed,
                                ),
                                SideMenuItem(
                                  title: _screenTitles[3],
                                  icon: Icons.article_rounded,
                                  onTap: () => _onMenuItemSelected(3, isProfileComplete),
                                  isCollapsed: _isCollapsed,
                                ),
                                SideMenuItem(
                                  title: _screenTitles[4],
                                  icon: Icons.calendar_today_rounded,
                                  onTap: () => _onMenuItemSelected(4, isProfileComplete),
                                  isCollapsed: _isCollapsed,
                                ),
                              ],
                            ),
                            // ... rest of your side menu items
                          ],
                        ),
                        // This is the main content area.
                        Expanded(
                          child: DashboardContentSwitcher(
                            selectedTabIndex: _selectedTabIndex,
                            screens: _screens,
                          ),
                        ),
                      ],
                    ),
                    // NEW: Apply a blur effect over the entire dashboard content if profile is not complete
                    if (!isProfileComplete)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}