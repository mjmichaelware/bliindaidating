// lib/screens/main/main_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier and debugPrint
import 'dart:ui'; // Import for ImageFilter

// Local imports for core project components
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/services/newsfeed_service.dart';

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
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart';

// Import the new Dashboard Overview Screen
import 'package:bliindaidating/screens/dashboard/dashboard_overview_screen.dart';


class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // These should now be driven by ProfileService directly via Consumer/Provider.of
  // UserProfile? _userProfile; // No longer needed as state directly in MainDashboardScreenState
  // String? _profilePictureDisplayUrl; // No longer needed as state directly in MainDashboardScreenState
  // bool _isLoadingProfile = true; // This will now be driven by profileService.isLoading
  StreamSubscription<List<Map<String, dynamic>>>? _profileSubscription;
  int _selectedTabIndex = 0; // Default to Dashboard Overview (index 0)

  // State for the collapsible side menu
  bool _isSideMenuCollapsed = false;

  // NEW: Animation for the pulsating gradient background
  late AnimationController _gradientPulseController;
  late Animation<double> _gradientPulseAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('--- MainDashboardScreen: initState START ---');

    // **IMPORTANT FIX:** Remove the direct call to _loadUserProfileAndSubscribe() here.
    // The profile is already being initialized in main.dart's initState via postFrameCallback.
    // MainDashboardScreen should now *listen* to ProfileService for its state, not trigger the fetch.

    // NEW: Initialize gradient pulse animation controller
    _gradientPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Adjust duration as needed
    )..repeat(reverse: true); // Repeats back and forth

    _gradientPulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _gradientPulseController, curve: Curves.easeInOut),
    );
    debugPrint('MainDashboardScreen: Initialized gradient pulse animation.');
    debugPrint('--- MainDashboardScreen: initState END ---');

    // Now, let's set up the Supabase Realtime subscription here,
    // but only *after* the initial profile load might have happened.
    // We can use `WidgetsBinding.instance.addPostFrameCallback` or ensure `profileService.isProfileLoaded` is true.
    // More robust is to listen directly to ProfileService for the profile itself.
    // However, the real-time subscription is about *future* changes, not the initial load.
    // It's probably better to keep the subscription logic within ProfileService itself
    // so it manages its own data stream and notifies *this* widget.
    // For now, let's keep it here but ensure it doesn't cause a re-fetch.
    _setupProfileSubscription(); // Call this to set up the real-time listener without re-fetching.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('MainDashboardScreen: didChangeDependencies called.');
    // No direct action needed here after removing the direct fetch.
    // The `Provider.of<ProfileService>(context)` call in `build` will handle reactivity.
  }

  // MODIFIED: This method now only sets up the subscription, it doesn't *fetch* the profile initially.
  Future<void> _setupProfileSubscription() async {
    debugPrint('MainDashboardScreen: _setupProfileSubscription START.');
    final User? currentUser = Supabase.instance.client.auth.currentUser;

    // Cancel any existing subscription to prevent duplicates
    _profileSubscription?.cancel();

    if (currentUser == null) {
      debugPrint('MainDashboardScreen: No current user for subscription. Returning.');
      return;
    }

    debugPrint('MainDashboardScreen: Setting up Supabase Realtime subscription for user profile.');
    _profileSubscription = Supabase.instance.client
        .from('user_profiles')
        .stream(primaryKey: ['id'])
        .eq('id', currentUser.id)
        .listen((List<Map<String, dynamic>> data) async {
      debugPrint('MainDashboardScreen: Realtime update received from Supabase.');
      if (data.isNotEmpty) {
        final profileService = Provider.of<ProfileService>(context, listen: false);
        final UserProfile updatedProfile = UserProfile.fromJson(data.first);
        // Update the profileService's internal profile, which will then notify all listeners
        profileService.updateProfileLocally(updatedProfile); // Call a new method on ProfileService
        debugPrint('MainDashboardScreen: Realtime profile update processed via ProfileService for: ${updatedProfile.displayName ?? updatedProfile.fullLegalName ?? 'N/A'}');
      } else {
        debugPrint('MainDashboardScreen: Realtime update data was empty.');
      }
    }, onError: (error) {
      debugPrint('MainDashboardScreen: Error in Supabase Realtime subscription: $error');
    });
    debugPrint('MainDashboardScreen: _setupProfileSubscription END.');
  }


  void _onTabSelected(int index) {
    debugPrint('MainDashboardScreen: Tab selected: $index. Calling setState.');
    setState(() {
      _selectedTabIndex = index;
    });
  }

  // Callback to update collapsed state from side menu
  void _onSideMenuCollapseToggle(bool isCollapsed) {
    debugPrint('MainDashboardScreen: Side menu collapse toggled to: $isCollapsed. Calling setState.');
    setState(() {
      _isSideMenuCollapsed = isCollapsed;
    });
  }

  @override
  void dispose() {
    debugPrint('--- MainDashboardScreen: dispose START ---');
    _profileSubscription?.cancel();
    debugPrint('MainDashboardScreen: Profile subscription cancelled.');
    _gradientPulseController.dispose();
    debugPrint('MainDashboardScreen: Gradient pulse controller disposed.');
    super.dispose();
    debugPrint('--- MainDashboardScreen: dispose END ---');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('--- MainDashboardScreen: build START ---');
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    final size = MediaQuery.of(context).size;

    debugPrint('MainDashboardScreen: build - Screen width: ${size.width}, isSmallScreen: ${size.width < 600}');

    // Responsive breakpoints
    final bool isSmallScreen = size.width < 600; // Mobile
    final bool isMediumScreen = size.width >= 600 && size.width < 1000; // Tablet

    // Get ProfileService and its state (UserProfile, isLoading, isProfileLoaded)
    final profileService = Provider.of<ProfileService>(context);
    final UserProfile? userProfile = profileService.userProfile;
    final bool isLoadingProfile = profileService.isLoading; // Use ProfileService's loading state
    final bool isProfileLoaded = profileService.isProfileLoaded; // Use ProfileService's loaded state

    final bool isPhase2Complete = userProfile?.isPhase2Complete ?? false;
    final String? profilePictureDisplayUrl = userProfile?.profilePictureUrl;

    debugPrint('MainDashboardScreen: build - isPhase2Complete: $isPhase2Complete');
    debugPrint('MainDashboardScreen: build - isLoadingProfile (from service): $isLoadingProfile');
    debugPrint('MainDashboardScreen: build - isProfileLoaded (from service): $isProfileLoaded');


    // FIX: showContentBlur should only be true when actively loading *and* not yet loaded
    final bool showContentBlur = isLoadingProfile || !isProfileLoaded; // If loading OR not yet loaded at all
    debugPrint('MainDashboardScreen: build - showContentBlur: $showContentBlur');

    // CORRECTED: Added 'const' keyword to each widget instance for efficiency
    final List<Widget> _dashboardScreens = const [
      DashboardOverviewScreen(), // Index 0
      NewsfeedScreen(), // Index 1
      MatchesListScreen(), // Index 2
      DiscoverPeopleScreen(), // Index 3
      QuestionnaireScreen(), // Index 4
      MyProfileScreen(), // Index 5
    ];
    debugPrint('MainDashboardScreen: build - Dashboard screens list initialized.');

    final double sideMenuWidth = _isSideMenuCollapsed
        ? AppConstants.spacingXXL + AppConstants.paddingMedium // Min width (icon size + padding)
        : AppConstants.dashboardSideMenuWidth;
    debugPrint('MainDashboardScreen: build - sideMenuWidth: $sideMenuWidth, _isSideMenuCollapsed: $_isSideMenuCollapsed');

    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color tertiaryColor = isDarkMode ? AppConstants.tertiaryColor : AppConstants.lightTertiaryColor; // Ensure this is defined in AppConstants
    debugPrint('MainDashboardScreen: build - Background colors determined.');

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: isSmallScreen
          ? DashboardAppBar(
              showProfileCompletion: !isPhase2Complete,
              onMenuPressed: () {
                debugPrint('MainDashboardScreen: AppBar menu button pressed.');
                _scaffoldKey.currentState?.openEndDrawer();
              },
            )
          : null,
      endDrawer: isSmallScreen
          ? DashboardSideMenu(
              userProfile: userProfile, // Use the profile from service
              profilePictureUrl: profilePictureDisplayUrl, // Use the URL from service
              selectedTabIndex: _selectedTabIndex,
              onTabSelected: (index) {
                debugPrint('MainDashboardScreen: Drawer tab selected: $index.');
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
          // NEW: Animated Gradient Background
          AnimatedBuilder(
            animation: _gradientPulseAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withOpacity(0.7), // Start color, slightly transparent
                      secondaryColor.withOpacity(0.8), // Middle color
                      tertiaryColor.withOpacity(0.9), // End color
                    ],
                    stops: const [0.0, 0.5, 1.0], // Distribution of colors
                    center: Alignment.center,
                    radius: _gradientPulseAnimation.value * (isSmallScreen ? 1.5 : 1.0), // Pulsating radius, adjusted for small screen
                  ),
                ),
              );
            },
          ),
          // Optionally, add a subtle overlay for darker edges/more depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                    Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Row(
              children: [
                if (!isSmallScreen)
                  DashboardSideMenu(
                    userProfile: userProfile, // Use profile from service
                    profilePictureUrl: profilePictureDisplayUrl, // Use URL from service
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
                      // Banner for Phase 2 completion
                      // Show banner only if phase 2 is NOT complete AND profile is loaded AND not currently loading
                      if (!isPhase2Complete && isProfileLoaded && !isLoadingProfile)
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
                                    debugPrint('MainDashboardScreen: "Start Phase 2 Now!" button pressed.');
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
                      // Main Content Area (conditionally blurred/absorbed)
                      // Use profileService.isProfileLoaded to determine if content should be shown
                      // and profileService.isLoading for the loading indicator.
                      (isLoadingProfile && !isProfileLoaded) // Show loading indicator if loading AND not yet loaded
                          ? Expanded(
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: Theme.of(context).colorScheme.secondary)),
                            )
                          : Expanded(
                              child: AbsorbPointer(
                                absorbing: isLoadingProfile, // Only absorb pointer events when the service says it's loading
                                child: ImageFiltered(
                                  imageFilter: isLoadingProfile
                                      ? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0)
                                      : ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                                  child: AnimatedOpacity(
                                    opacity: isLoadingProfile ? 0.4 : 1.0,
                                    duration: AppConstants.animationDurationMedium,
                                    child: DashboardContentSwitcher(
                                      selectedTabIndex: _selectedTabIndex,
                                      screens: _dashboardScreens,
                                    ),
                                  ),
                                ),
                              ),
                            ),
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