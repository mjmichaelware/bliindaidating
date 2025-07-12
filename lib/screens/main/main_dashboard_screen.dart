// lib/screens/main/main_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'dart:ui'; // Import for ImageFilter

// Local imports for core project components
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';

// OpenAI Integration Imports (already confirmed to exist and be populated)
import 'package:bliindaidating/services/openai_service.dart';
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';
import 'package:bliindaidating/models/newsfeed/ai_engagement_prompt.dart';

// NEW: Dashboard Shell Component Imports (These files now exist as per tree output)
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_app_bar.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_side_menu.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_footer.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_content_switcher.dart';

// NEW: Tab Content Screen Imports (These placeholder files now exist as per tree output)
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart';
import 'package:bliindaidating/screens/profile/my_profile_screen.dart';
import 'package:bliindaidating/screens/discovery/discovery_screen.dart';
import 'package:bliindaidating/screens/questionnaire/questionnaire_screen.dart'; // This is tab index 3
import 'package:bliindaidating/screens/matches/matches_list_screen.dart';

// NEW: Import the new Phase2SetupScreen
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart'; // This is tab index 4

// Assuming AnimatedOrbBackground is in landing_page/widgets as per tree
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';


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

  // Obtain ProfileService via Provider in initState or build, not instantiate directly
  // The ProfileService is provided at the root of the app.
  // final ProfileService _profileService = ProfileService(); // REMOVE: Don't instantiate here
  final OpenAIService _openAIService = OpenAIService(); // Instantiate OpenAIService


  @override
  void initState() {
    super.initState();
    // No need to instantiate ProfileService here if it's already provided by MultiProvider
    // Access it using Provider.of in _loadUserProfileAndSubscribe
    _loadUserProfileAndSubscribe();
    _fetchAIDummyData();
  }

  // Moved profile service access to the method, as context is available
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
        // Redirect if Phase 1 is incomplete (handled by main.dart's redirect primarily, but good fallback here)
        if (!fetchedProfile.isPhase1Complete) {
           debugPrint('MainDashboardScreen: Profile Phase 1 is not complete. Redirecting to setup.');
           if (mounted) context.go('/profile_setup');
           return;
        }
      } else {
        setState(() { _isLoadingProfile = false; });
        debugPrint('MainDashboardScreen: User profile not found for ID: ${currentUser.id}. Redirecting to setup.');
        if (mounted) {
          context.go('/profile_setup'); // Ensure Phase 1 setup handles new profile creation
        }
      }

      // Realtime subscription setup
      // Use profileService.userProfileStream if ProfileService exposes one,
      // or set up a direct Supabase stream here as before.
      // The current direct stream is fine.
      _profileSubscription = Supabase.instance.client
          .from('profiles')
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
          debugPrint('MainDashboardScreen: Realtime update for profile: ${updatedProfile.displayName ?? updatedProfile.fullName}');
          // If profile completion status changes, this setState will trigger a rebuild,
          // and the UI (blur, banner) will react accordingly.
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


  Future<void> _fetchAIDummyData() async {
    debugPrint('--- Fetching AI Dummy Data (from MainDashboardScreen) ---');
    try {
      final List<UserProfile> dummyProfiles = await _openAIService.generateDummyUserProfiles(3);
      debugPrint('AI Generated Dummy Profiles:');
      for (var profile in dummyProfiles) {
        debugPrint('  - ${profile.displayName ?? profile.fullName ?? 'Unnamed User'} (${profile.userId}) - Looking For: ${profile.lookingFor}, Interests: ${(profile.interests ?? []).join(', ')}');
      }

      final List<NewsfeedItem> newsfeedItems = await _openAIService.generateNewsfeedItems(
        5,
        userLocation: 'Snyderville, Utah',
        userRadius: 50,
      );
      debugPrint('AI Generated Newsfeed Items:');
      for (var item in newsfeedItems) {
        debugPrint('  - [${item.type.name}] ${item.username ?? ''}: ${item.content}');
      }

      final List<AIEngagementPrompt> aiPrompts = await _openAIService.generateAIEngagementPrompts(3);
      debugPrint('AI Generated Engagement Prompts:');
      for (var prompt in aiPrompts) {
        debugPrint('  - ${prompt.tip}');
      }

      if (dummyProfiles.isNotEmpty) {
        final List<Map<String, dynamic>> dummyMatches = await _openAIService.generateDummyMatches(2, dummyProfiles);
        debugPrint('AI Generated Dummy Matches:');
        for (var match in dummyMatches) {
          debugPrint('  - Match between ${match['user1Id']} and ${match['user2Id']} - Score: ${match['compatibilityScore']}, Reason: ${match['reason']}');
        }
      }
      debugPrint('--- AI Dummy Data Fetch Complete ---');
    } catch (e) {
      debugPrint('Error fetching AI dummy data: $e');
      if (kDebugMode) {
        print('Detailed AI Dummy Data Error: ${e.toString()}');
      }
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    // Check Phase 2 completion status from the service's current profile
    // It's crucial to listen to ProfileService here if you want immediate UI reactions
    // to changes in isPhase2Complete without relying solely on _profileSubscription.
    // However, _profileSubscription already updates _userProfile, so that's effective.
    final profileService = Provider.of<ProfileService>(context); // Listen to ProfileService
    final bool isPhase2Complete = profileService.userProfile?.isPhase2Complete ?? false;


    // Define the index for the Phase 2 setup screen in your _dashboardScreens list.
    // IMPORTANT: Ensure this matches the actual index of Phase2SetupScreen in the list below.
    const int phase2SetupTabIndex = 4; // Phase2SetupScreen is at index 4

    // Determine if the content should be blurred and absorbed (interactions blocked)
    // Content is absorbed if profile is still loading OR if Phase 2 is incomplete
    // AND the current tab is NOT the Phase 2 setup tab.
    final bool absorbAndBlurContent = _isLoadingProfile || (!isPhase2Complete && _selectedTabIndex != phase2SetupTabIndex);


    // List of screens for the DashboardContentSwitcher
    final List<Widget> _dashboardScreens = const [
      NewsfeedScreen(),           // Index 0
      MatchesListScreen(),        // Index 1
      DiscoveryScreen(),          // Index 2
      QuestionnaireScreen(),      // Index 3 (Assuming this is a general questionnaire, not Phase 2 setup)
      Phase2SetupScreen(),        // Index 4 (This is the dedicated Phase 2 Setup with sub-tabs)
      // Add other main dashboard screens as needed
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: DashboardAppBar(
        showProfileCompletion: !isPhase2Complete, // Pass status to app bar for potential indicator
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()), // Reuse background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    isDarkMode ? Colors.deepPurple.shade900.withOpacity(0.7) : Colors.blue.shade100.withOpacity(0.7),
                    isDarkMode ? Colors.black : Colors.white.withOpacity(0.85),
                  ],
                  center: Alignment.topLeft,
                  radius: 1.5,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                // Left Side Menu - pass isPhase2Complete to control enabled tabs
                DashboardSideMenu(
                  userProfile: _userProfile,
                  profilePictureUrl: _profilePictureDisplayUrl,
                  selectedTabIndex: _selectedTabIndex,
                  onTabSelected: _onTabSelected,
                  isPhase2Complete: isPhase2Complete, // Pass Phase 2 status
                ),
                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Phase 2 Completion Banner
                      if (!isPhase2Complete && !_isLoadingProfile) // Only show if not loading and Phase 2 incomplete
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
                                    // Navigate to the Phase 2 Setup screen if not already there
                                    if (_selectedTabIndex != phase2SetupTabIndex) {
                                      _onTabSelected(phase2SetupTabIndex); // Programmatically select the Phase 2 setup tab
                                    }
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
                              // Apply blur and absorb pointer based on absorbAndBlurContent
                              child: AbsorbPointer(
                                absorbing: absorbAndBlurContent,
                                child: AnimatedOpacity(
                                  opacity: absorbAndBlurContent ? 0.4 : 1.0, // Visually indicate disabled state more distinctly
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