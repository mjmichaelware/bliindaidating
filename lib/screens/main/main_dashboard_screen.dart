import 'package:bliindaidating/services/ai_logic_service.dart';
import 'package:bliindaidating/services/newsfeed_service.dart';
// lib/screens/main/main_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_app_bar.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_content_switcher.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_side_menu.dart';
import 'package:bliindaidating/services/ai_logic_service.dart'; // FIX: Missing import added

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

  List<String> _newsFeedItems = ['Loading news feed...'];
  List<Map<String, dynamic>> _matches = [];
  List<Map<String, dynamic>> _dates = [];
  bool _isLoading = true;

  final String _userProfileSummary = "A 25-year-old software engineer who enjoys hiking and playing guitar.";
  final List<Map<String, dynamic>> _recentActivity = [
    {'action': 'liked_profile', 'profile_name': 'Jane Doe'},
    {'action': 'sent_message', 'profile_name': 'John Smith'},
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
    _fetchDashboardData();
  }

  @override
  void dispose() {
    _sideMenuAnimationController.dispose();
    super.dispose();
  }

  // FIX: Corrected data fetching with JWT and Future.wait
  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    final session = Supabase.instance.client.auth.currentSession;
    final jwtToken = session?.accessToken;

    if (jwtToken == null) {
      debugPrint('User is not authenticated. Cannot fetch dashboard data.');
      setState(() {
        _isLoading = false;
        _newsFeedItems = ['Please sign in to see your personalized content.'];
      });
      return;
    }

    try {
    final aiLogicService = Provider.of<AiLogicService>(context, listen: false);

      // FIX: The argument to Future.wait must be an Iterable of Futures.
      // The old code was trying to pass a dynamic list which was incorrect.
      final results = await Future.wait<dynamic>([
        aiLogicService.generateNewsFeed(_userProfileSummary, _recentActivity, jwtToken),
        aiLogicService.getAiGeneratedMatches(_userProfileSummary, jwtToken),
        aiLogicService.getAiGeneratedDates(_userProfileSummary, jwtToken),
      ]);

      setState(() {
        _newsFeedItems = results[0] as List<String>? ?? ['Failed to load news feed.'];
        _matches = results[1] as List<Map<String, dynamic>>? ?? [];
        _dates = results[2] as List<Map<String, dynamic>>? ?? [];
        _isLoading = false;
      });

      debugPrint('Successfully fetched all dashboard data.');
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      setState(() {
        _newsFeedItems = ['Error fetching dashboard data. Please try again.'];
        _matches = [];
        _dates = [];
        _isLoading = false;
      });
    }
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
    if (MediaQuery.of(context).size.width < 768) {
      _onToggleCollapse();
    }
  }

  Widget _buildDashboardOverviewScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your AI-Generated News Feed', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              if (_newsFeedItems.isNotEmpty)
                Column(
                  children: _newsFeedItems.map((item) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.star_rounded, color: Colors.blueAccent),
                      title: Text(item),
                    ),
                  )).toList(),
                )
              else
                const Text('No news feed items available.'),
              const Divider(height: 32),
              Text('AI-Generated Matches for you', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              if (_matches.isNotEmpty)
                Column(
                  children: _matches.map((match) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                      title: Text('New match with ${match['profile_name']}'),
                      subtitle: Text('Reason: ${match['reason']}'),
                    ),
                  )).toList(),
                )
              else
                const Text('No new AI-generated matches.'),
              const Divider(height: 32),
              Text('Upcoming AI-Generated Dates', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              if (_dates.isNotEmpty)
                Column(
                  children: _dates.map((date) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today_rounded, color: Colors.green),
                      title: Text('Date with ${date['date_idea']}'),
                      subtitle: Text('Details: ${date['details']}'),
                    ),
                  )).toList(),
                )
              else
                const Text('No upcoming AI-generated dates.'),
            ],
          ),
        ),
      ),
    );
  }
  
  late final List<Widget> _screens = [
    _buildDashboardOverviewScreen(),
    const Center(child: Text('My Matches Screen')),
    const Center(child: Text('Discovery Screen')),
    const Center(child: Text('Newsfeed Screen')),
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
