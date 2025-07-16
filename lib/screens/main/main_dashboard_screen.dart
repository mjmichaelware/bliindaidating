// lib/screens/main/main_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'dart:ui'; // Import for ImageFilter
import 'dart:math' as math; // For math.Random and other math functions

// Local imports for core project components
import 'package:bliindaidating/app_constants.dart';
// CORRECTED: Added '.dart' and ';' to complete the import statement
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';

// OpenAI Integration Imports (assuming these are used within the screens or services)
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';
import 'package:bliindaidating/models/newsfeed/ai_engagement_prompt.dart'; // Assuming path adjustment

// NEW: Dashboard Shell Component Imports
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_app_bar.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_side_menu.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_footer.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_content_switcher.dart';

// NEW: Tab Content Screen Imports
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart';
import 'package:bliindaidating/screens/profile/my_profile_screen.dart';
import 'package:bliindaidating/screens/discovery/discover_people_screen.dart';
import 'package:bliindaidating/screens/questionnaire/questionnaire_screen.dart';
import 'package:bliindaidating/screens/matches/matches_list_screen.dart';
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart'; // This import is fine here as per analysis

// Import the new Dashboard Overview Screen
import 'package:bliindaidating/screens/dashboard/dashboard_overview_screen.dart';

// Re-importing the custom painters from landing_page for consistency
// RECOMMENDED: For better modularity, consider moving NebulaBackgroundPainter and ParticleFieldPainter
// into their own dedicated files (e.g., 'lib/painters/nebula_background_painter.dart') and
// importing them directly here.
import 'package:bliindaidating/landing_page/landing_page.dart'; // Contains NebulaBackgroundPainter, ParticleFieldPainter


class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  UserProfile? _userProfile;
  String? _profilePictureDisplayUrl;
  bool _isLoadingProfile = true;
  StreamSubscription<List<Map<String, dynamic>>>? _profileSubscription;
  int _selectedTabIndex = 0; // Default to Dashboard Overview (index 0)

  // State for the collapsible side menu
  bool _isSideMenuCollapsed = false;

  // Animation controllers for the cosmic background
  late AnimationController _backgroundNebulaController;
  late Animation<double> _backgroundNebulaAnimation;
  late AnimationController _particleFieldController;
  late Animation<double> _particleFieldAnimation;

  final List<Offset> _nebulaParticles = [];
  final List<Offset> _deepSpaceParticles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _loadUserProfileAndSubscribe();

    // Initialize background animation controllers
    _backgroundNebulaController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _backgroundNebulaAnimation = CurvedAnimation(parent: _backgroundNebulaController, curve: Curves.linear);

    _particleFieldController = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
    _particleFieldAnimation = CurvedAnimation(parent: _particleFieldController, curve: Curves.linear);

    _generateParticles(100, _nebulaParticles); // For the nebula painter
    _generateParticles(80, _deepSpaceParticles); // For the particle field painter
  }

  void _generateParticles(int count, List<Offset> particleList) {
    for (int i = 0; i < count; i++) {
      particleList.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  Future<void> _loadUserProfileAndSubscribe() async {
    final profileService = Provider.of<ProfileService>(context, listen: false);
    final User? currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) {
      setState(() { _isLoadingProfile = false; });
      debugPrint('MainDashboardScreen: No current user for profile load. Redirecting to login.');
      // The GoRouter redirect logic in main.dart should handle this.
      // Removed direct context.go('/login') here to avoid conflicts.
      return;
    }

    try {
      final UserProfile? fetchedProfile = await profileService.fetchUserProfile(id: currentUser.id);
      if (fetchedProfile != null) {
        setState(() {
          _userProfile = fetchedProfile;
          _isLoadingProfile = false;
        });
        if (fetchedProfile.profilePictureUrl != null) {
          setState(() {
            _profilePictureDisplayUrl = fetchedProfile.profilePictureUrl;
          });
        }
        // REMOVED: This redirect logic should primarily be handled by GoRouter's redirect logic in main.dart
        // This check here is a fallback/additional safety, but can be removed for cleaner routing if GoRouter is robust.
        // if (!fetchedProfile.isPhase1Complete) {
        //     debugPrint('MainDashboardScreen: Profile Phase 1 is not complete. Redirecting to setup.');
        //     if (mounted) context.go('/profile_setup');
        //     return;
        // }
      } else {
        setState(() { _isLoadingProfile = false; });
        debugPrint('MainDashboardScreen: User profile not found for ID: ${currentUser.id}. GoRouter will handle redirect.');
        // The GoRouter redirect logic in main.dart should handle this.
        // Removed direct context.go('/profile_setup') here to avoid conflicts.
      }

      _profileSubscription = Supabase.instance.client
          .from('user_profiles')
          .stream(primaryKey: ['id'])
          .eq('id', currentUser.id)
          .listen((List<Map<String, dynamic>> data) async {
        if (data.isNotEmpty) {
          final UserProfile updatedProfile = UserProfile.fromJson(data.first);
          setState(() {
            _userProfile = updatedProfile;
            if (updatedProfile.profilePictureUrl != null && updatedProfile.profilePictureUrl != _profilePictureDisplayUrl) {
              _profilePictureDisplayUrl = updatedProfile.profilePictureUrl;
            }
          });
          debugPrint('MainDashboardScreen: Realtime update for profile: ${updatedProfile.displayName ?? updatedProfile.fullLegalName ?? 'N/A'}');
        }
      });
    } on PostgrestException catch (e) {
      debugPrint('MainDashboardScreen: Supabase Postgrest Error loading profile or setting up Realtime: ${e.message}');
      setState(() { _isLoadingProfile = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('MainDashboardScreen: General Error loading profile or setting up Realtime: $e');
      setState(() { _isLoadingProfile = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
        );
      }
    }
  }


  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  // Callback to update collapsed state from side menu
  void _onSideMenuCollapseToggle(bool isCollapsed) {
    setState(() {
      _isSideMenuCollapsed = isCollapsed;
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _backgroundNebulaController.dispose();
    _particleFieldController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    final size = MediaQuery.of(context).size;

    // Responsive breakpoints
    final bool isSmallScreen = size.width < 600; // Mobile
    final bool isMediumScreen = size.width >= 600 && size.width < 1000; // Tablet
    // final bool isLargeScreen = size.width >= 1000; // Desktop - not explicitly used beyond default

    final profileService = Provider.of<ProfileService>(context);
    final bool isPhase2Complete = profileService.userProfile?.isPhase2Complete ?? false;

    // The blur effect remains, but we no longer use AbsorbPointer to block ALL interactions
    final bool showContentBlur = _isLoadingProfile || (!isPhase2Complete);

    final List<Widget> _dashboardScreens = const [
      DashboardOverviewScreen(), // Index 0
      NewsfeedScreen(), // Index 1
      MatchesListScreen(), // Index 2
      DiscoverPeopleScreen(), // Index 3
      QuestionnaireScreen(), // Index 4
      MyProfileScreen(), // Index 5 (Example of another main content screen)
      // Add other main content screens that should be switched via tabs here
    ];

    // Determine the width of the side menu based on its collapsed state
    final double sideMenuWidth = _isSideMenuCollapsed
        ? AppConstants.spacingXXL + AppConstants.paddingMedium // Min width (icon size + padding)
        : AppConstants.dashboardSideMenuWidth;

    // Colors for the background painters, derived from AppConstants
    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;


    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: isSmallScreen
          ? DashboardAppBar(
              showProfileCompletion: !isPhase2Complete,
              onMenuPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            )
          : null,
      endDrawer: isSmallScreen
          ? DashboardSideMenu(
              userProfile: _userProfile,
              profilePictureUrl: _profilePictureDisplayUrl,
              selectedTabIndex: _selectedTabIndex,
              onTabSelected: (index) {
                _onTabSelected(index);
                Navigator.of(context).pop(); // Close drawer after selection
              },
              isPhase2Complete: isPhase2Complete,
              onCollapseToggle: _onSideMenuCollapseToggle,
              isInitiallyCollapsed: false,
              isDrawerMode: true,
            )
          : null,
      body: Stack(
        children: [
          // --- Full-screen Background Elements (Nebula and Particles) ---
          Positioned.fill(
            child: CustomPaint(
              painter: NebulaBackgroundPainter(
                _backgroundNebulaAnimation,
                primaryColor,
                secondaryColor,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ParticleFieldPainter(
                _deepSpaceParticles,
                _particleFieldAnimation,
                AppConstants.spacingExtraSmall,
                isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    isDarkMode ? AppConstants.backgroundColor.withOpacity(0.8) : AppConstants.lightBackgroundColor.withOpacity(0.8),
                    isDarkMode ? AppConstants.backgroundColor.withOpacity(0.95) : AppConstants.lightBackgroundColor.withOpacity(0.95),
                  ],
                  center: Alignment.center,
                  radius: 1.0,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Row(
              children: [
                if (!isSmallScreen)
                  DashboardSideMenu(
                    userProfile: _userProfile,
                    profilePictureUrl: _profilePictureDisplayUrl,
                    selectedTabIndex: _selectedTabIndex,
                    onTabSelected: _onTabSelected,
                    isPhase2Complete: isPhase2Complete,
                    onCollapseToggle: _onSideMenuCollapseToggle,
                    isInitiallyCollapsed: isMediumScreen,
                    isDrawerMode: false,
                  ),
                AnimatedContainer(
                  duration: AppConstants.animationDurationMedium,
                  curve: Curves.easeInOutCubic,
                  width: isSmallScreen
                      ? size.width
                      : size.width - sideMenuWidth,
                  child: Column(
                    children: [
                      if (!isSmallScreen)
                        DashboardAppBar(
                          showProfileCompletion: !isPhase2Complete,
                        ),
                      if (!isPhase2Complete && !_isLoadingProfile)
                        Container(
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppConstants.bannerBackgroundColorDark.withOpacity(0.95) : AppConstants.bannerBackgroundColorLight.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Action Required: Complete Your Profile Phase 2!',
                                style: TextStyle(
                                  color: isDarkMode ? AppConstants.bannerTextColorDark : AppConstants.bannerTextColorLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppConstants.fontSizeMedium,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingSmall),
                              Text(
                                'Unlock matches, news feed, and discovery by finishing the AI-driven questionnaire. It takes just a few minutes!',
                                style: TextStyle(
                                  color: isDarkMode ? AppConstants.bannerTextColorDark.withOpacity(0.8) : AppConstants.bannerTextColorLight.withOpacity(0.8),
                                  fontSize: AppConstants.fontSizeSmall,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingSmall),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    context.go('/questionnaire-phase2');
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: isDarkMode ? AppConstants.bannerButtonColorDark : AppConstants.bannerButtonColorLight,
                                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                    ),
                                  ),
                                  child: Text(
                                    'Start Phase 2 Now!',
                                    style: TextStyle(
                                      color: isDarkMode ? AppConstants.bannerButtonTextColorDark : AppConstants.bannerButtonTextColorLight,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      _isLoadingProfile
                          ? Expanded(
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: Theme.of(context).colorScheme.secondary)),
                            )
                          : Expanded(
                              // ADDED AbsorbPointer here to block interaction when blurred
                              child: AbsorbPointer(
                                absorbing: showContentBlur, // Only absorb when content should be blurred
                                child: ImageFiltered(
                                  imageFilter: showContentBlur
                                      ? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0)
                                      : ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                                  child: AnimatedOpacity(
                                    opacity: showContentBlur ? 0.4 : 1.0,
                                    duration: AppConstants.animationDurationMedium,
                                    child: DashboardContentSwitcher(
                                      selectedTabIndex: _selectedTabIndex,
                                      screens: _dashboardScreens,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      // Added the missing DashboardFooter here based on the closing brace from your original input
                      const DashboardFooter(),
                    ],
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