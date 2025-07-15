// lib/screens/main/main_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:provider/provider.dart'; // FIXED: Changed .h to .dart
import 'package:flutter/foundation.dart'; // For debugPrint
import 'dart:ui'; // Import for ImageFilter
import 'dart:math' as math; // For math.Random and other math functions

// Local imports for core project components
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart'; // CORRECTED: .h changed to .dart
import 'package:bliindaidating/services/profile_service.dart';

// OpenAI Integration Imports (already confirmed to exist and be populated)
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';
import 'package:bliindaidating/models/newsfeed/ai_engagement_prompt.dart';

// NEW: Dashboard Shell Component Imports
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_app_bar.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_side_menu.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_footer.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_content_switcher.dart';

// NEW: Tab Content Screen Imports
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart';
import 'package:bliindaidating/screens/profile/my_profile_screen.dart';
import 'package:bliindaidating/screens/discovery/discover_people_screen.dart'; // Corrected import to discover_people_screen
import 'package:bliindaidating/screens/questionnaire/questionnaire_screen.dart';
import 'package:bliindaidating/screens/matches/matches_list_screen.dart';
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart';

// Re-importing the custom painters from landing_page for consistency
import 'package:bliindaidating/landing_page/landing_page.dart'; // Contains NebulaBackgroundPainter, ParticleFieldPainter


class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> with TickerProviderStateMixin {
  UserProfile? _userProfile;
  String? _profilePictureDisplayUrl;
  bool _isLoadingProfile = true;
  StreamSubscription<List<Map<String, dynamic>>>? _profileSubscription;
  int _selectedTabIndex = 0; // Default to Newsfeed (index 0)

  // State for the collapsible side menu
  // This state is now managed by MainDashboardScreen for the persistent sidebar
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
      if (mounted) context.go('/login');
      return;
    }

    try {
      final UserProfile? fetchedProfile = await profileService.fetchUserProfile(currentUser.id);
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
        if (!fetchedProfile.isPhase1Complete) {
           debugPrint('MainDashboardScreen: Profile Phase 1 is not complete. Redirecting to setup.');
           if (mounted) context.go('/profile_setup');
           return;
        }
      } else {
        setState(() { _isLoadingProfile = false; });
        debugPrint('MainDashboardScreen: User profile not found for ID: ${currentUser.id}. Redirecting to setup.');
        if (mounted) {
          context.go('/profile_setup');
        }
      }

      _profileSubscription = Supabase.instance.client
          .from('user_profiles') // Corrected table name from 'profiles' to 'user_profiles'
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
          // Using fullLegalName or displayName as per your model
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
    final bool isLargeScreen = size.width >= 1000; // Desktop

    final profileService = Provider.of<ProfileService>(context);
    final bool isPhase2Complete = profileService.userProfile?.isPhase2Complete ?? false;

    // Phase 2 setup is now a direct route, not a tab index in _dashboardScreens
    // The banner will navigate directly to '/questionnaire-phase2'
    const int dummyPhase2SetupTabIndex = -1; // No longer directly mapped to a tab index in _dashboardScreens

    final bool absorbAndBlurContent = _isLoadingProfile || (!isPhase2Complete); // Blur if loading or Phase 2 incomplete

    final List<Widget> _dashboardScreens = const [
      NewsfeedScreen(), // Index 0
      MatchesListScreen(), // Index 1
      DiscoverPeopleScreen(), // Index 2
      QuestionnaireScreen(), // Index 3
      MyProfileScreen(), // Index 4 (Example of another main content screen)
      // Add other main content screens that should be switched via tabs here
      // Phase2SetupScreen is now a direct route, not part of this list.
    ];

    // Determine the width of the side menu based on its collapsed state
    final double sideMenuWidth = _isSideMenuCollapsed
        ? AppConstants.spacingXXL + AppConstants.paddingMedium // Min width (icon size + padding)
        : AppConstants.dashboardSideMenuWidth;

    // Colors for the background painters, derived from AppConstants
    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;


    return Scaffold(
      extendBodyBehindAppBar: true,
      // AppBar for mobile (will show menu icon to open drawer)
      // For larger screens, the side menu is persistent, so no need for leading icon in app bar.
      appBar: isSmallScreen
          ? DashboardAppBar(
              showProfileCompletion: !isPhase2Complete,
              // For mobile, the menu button opens the endDrawer
              onMenuPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            )
          : null, // No app bar for larger screens (or a custom one without leading menu icon)
      // End Drawer for mobile (the actual side menu)
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
              onCollapseToggle: _onSideMenuCollapseToggle, // This won't be used in drawer mode
              isInitiallyCollapsed: false, // Mobile drawer is always initially expanded when opened
              isDrawerMode: true, // Explicitly set to true for drawer behavior
            )
          : null,
      body: Stack(
        children: [
          // --- Full-screen Background Elements (Nebula and Particles) ---
          // Nebula background
          Positioned.fill(
            child: CustomPaint(
              painter: NebulaBackgroundPainter(
                _backgroundNebulaAnimation,
                primaryColor,
                secondaryColor,
              ),
            ),
          ),
          // Particle field background
          Positioned.fill(
            child: CustomPaint(
              painter: ParticleFieldPainter(
                _deepSpaceParticles, // Using deep space particles for main background
                _particleFieldAnimation,
                AppConstants.spacingExtraSmall, // Particle size
                isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
              ),
            ),
          ),
          // Subtle overlay gradient for depth and consistency
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    isDarkMode ? AppConstants.backgroundColor.withOpacity(0.8) : AppConstants.lightBackgroundColor.withOpacity(0.8),
                    isDarkMode ? AppConstants.backgroundColor.withOpacity(0.95) : AppConstants.lightBackgroundColor.withOpacity(0.95),
                  ],
                  center: Alignment.center, // Centered for overall screen effect
                  radius: 1.0,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Row(
              children: [
                // Persistent Side Menu for Tablet/Desktop
                if (!isSmallScreen)
                  DashboardSideMenu(
                    userProfile: _userProfile,
                    profilePictureUrl: _profilePictureDisplayUrl,
                    selectedTabIndex: _selectedTabIndex,
                    onTabSelected: _onTabSelected,
                    isPhase2Complete: isPhase2Complete,
                    onCollapseToggle: _onSideMenuCollapseToggle, // Pass callback
                    isInitiallyCollapsed: isMediumScreen, // Start collapsed on tablet, expanded on desktop
                    isDrawerMode: false, // Explicitly set to false for persistent sidebar behavior
                  ),
                // Main Content Area - dynamically sized
                AnimatedContainer(
                  duration: AppConstants.animationDurationMedium,
                  curve: Curves.easeInOutCubic,
                  width: isSmallScreen
                      ? size.width // Mobile: takes full width
                      : size.width - sideMenuWidth, // Desktop/Tablet: takes remaining width
                  child: Column(
                    children: [
                      // Dashboard AppBar for larger screens (since Scaffold AppBar is null)
                      if (!isSmallScreen)
                        DashboardAppBar(
                          showProfileCompletion: !isPhase2Complete,
                          // No menu button needed here as sidebar is persistent
                          // You might add other actions here if needed
                        ),
                      // Phase 2 Completion Banner
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
                                    // Navigate directly to the Phase 2 setup screen route
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
                      // Loading indicator or content area
                      _isLoadingProfile
                          ? Expanded(
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.secondary),
                              ),
                            )
                          : Expanded(
                              child: AbsorbPointer(
                                absorbing: absorbAndBlurContent,
                                child: AnimatedOpacity(
                                  opacity: absorbAndBlurContent ? 0.4 : 1.0,
                                  duration: AppConstants.animationDurationMedium,
                                  child: ImageFiltered(
                                    imageFilter: absorbAndBlurContent
                                        ? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0)
                                        : ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                                    child: DashboardContentSwitcher(
                                      selectedTabIndex: _selectedTabIndex,
                                      screens: _dashboardScreens,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      // Dashboard Footer at the very bottom
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