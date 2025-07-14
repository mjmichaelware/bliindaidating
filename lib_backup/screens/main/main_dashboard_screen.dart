// lib/screens/main/main_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

// Local imports for core project components
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';

// OpenAI Integration Imports (already confirmed to exist and be populated)
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';
import 'package:bliindaidating/models/newsfeed/ai_engagement_prompt.dart';

// NEW: Dashboard Shell Component Imports (These files now exist as per tree output)
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_app_bar.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_side_menu.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_footer.dart';
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_content_switcher.dart';

// NEW: Tab Content Screen Imports (These placeholder files now exist as per tree output)
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart';
import 'package:bliindaidating/screens/profile/my_profile_screen.dart'; // From screens/profile
import 'package:bliindaidating/screens/discovery/discovery_screen.dart'; // Existing screen, likely in screens/discovery
import 'package:bliindaidating/screens/questionnaire/questionnaire_screen.dart';
import 'package:bliindaidating/screens/matches/matches_list_screen.dart'; // Existing screen, likely in screens/matches

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

  final ProfileService _profileService = ProfileService();


  @override
  void initState() {
    super.initState();
    _loadUserProfileAndSubscribe();
    // Call the AI dummy data fetch method for console verification
    _fetchAIDummyData(); 
  }

  Future<void> _fetchAIDummyData() async {
    debugPrint('--- Fetching AI Dummy Data (from MainDashboardScreen) ---');
    try {
      final List<UserProfile> dummyProfiles = await _openAIService.generateDummyUserProfiles(3);
      debugPrint('AI Generated Dummy Profiles:');
      for (var profile in dummyProfiles) {
        debugPrint('  - ${profile.displayName ?? profile.fullName ?? 'Unnamed User'} (${profile.id}) - Looking For: ${profile.lookingFor}, Interests: ${profile.(interests ?? []).join(', ')}');
      }

      final List<NewsfeedItem> newsfeedItems = await _openAIService.generateNewsfeedItems(
        5,
        userLocation: 'Snyderville, Utah', // Updated to current location
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

      if ((dummyProfiles ?? []).isNotEmpty) {
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

  Future<void> _loadUserProfileAndSubscribe() async {
    final User? currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      setState(() { _isLoadingProfile = false; });
      debugPrint('MainDashboardScreen: No current user for profile load. Redirecting to login.');
      if (mounted) context.go('/login');
      return;
    }

    try {
      final UserProfile? fetchedProfile = await _profileService.fetchUserProfile(currentUser.id);
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
        if (!fetchedProfile.isPhase1Complete) { // Changed from isProfileComplete to isPhase1Complete
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
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('id', currentUser.id)
          .listen((List<Map<String, dynamic>> data) async {
        if ((data ?? []).isNotEmpty) {
          final UserProfile updatedProfile = UserProfile.fromJson(data.first);
          setState(() {
            _userProfile = updatedProfile;
            // Ensure profile picture URL update on real-time changes
            if (updatedProfile.profilePictureUrl != null && updatedProfile.profilePictureUrl != _profilePictureDisplayUrl) {
              _profilePictureDisplayUrl = updatedProfile.profilePictureUrl;
            }
          });
          debugPrint('MainDashboardScreen: Realtime update for profile: ${updatedProfile.displayName ?? updatedProfile.fullName}');
          // If Phase 1 becomes incomplete (unlikely but for robustness) or Phase 2 changes, trigger router refresh
          // The main.dart listener for profileService takes care of router refresh.
          // This local update just ensures the UI reacts.
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
    // Prevent changing tabs if Phase 2 is incomplete, unless it's the questionnaire tab
    if (_userProfile != null && !_userProfile!.isPhase2Complete && index != 3) { // Assuming QuestionnaireScreen is index 3
      context.go('/questionnaire_screen'); // Directly navigate to ensure GoRouter redirect logic is hit
      return;
    }
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

    // Check Phase 2 completion status
    final bool isPhase2Complete = _userProfile?.isPhase2Complete ?? false;
    // Determine if the content should be absorbed (interactions blocked)
    final bool absorbContent = _isLoadingProfile || !isPhase2Complete;


    // List of screens for the DashboardContentSwitcher
    // Ensure QuestionnaireScreen is at a specific, known index (e.g., 3) for logic
    final List<Widget> _dashboardScreens = [
      const NewsfeedScreen(),
      const MatchesListScreen(),
      const DiscoveryScreen(),
      const QuestionnaireScreen(), // Assuming this is always index 3
    ];

    // Ensure _selectedTabIndex defaults to Questionnaire if Phase 2 is incomplete
    if (!isPhase2Complete && _selectedTabIndex != 3) {
      _selectedTabIndex = 3; // Force to Questionnaire screen
    }


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
                            color: isDarkMode ? Colors.orange.shade800.withOpacity(0.9) : Colors.amber.shade200.withOpacity(0.9),
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
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppConstants.fontSizeMedium,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: AppConstants.paddingSmall),
                              Text(
                                'Unlock matches, news feed, and discovery by finishing the AI-driven questionnaire. It takes just a few minutes!',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  fontSize: AppConstants.fontSizeSmall,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: AppConstants.paddingSmall),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // Navigate to the Questionnaire screen
                                    context.go('/questionnaire_screen');
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: isDarkMode ? AppConstants.primaryColor : AppConstants.accentColor,
                                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                    ),
                                  ),
                                  child: Text(
                                    'Start Phase 2 Now!',
                                    style: TextStyle(
                                      color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
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
                              // AbsorbPointer to block interaction if Phase 2 is incomplete
                              child: AbsorbPointer(
                                absorbing: absorbContent && _selectedTabIndex != 3, // Absorb if incomplete AND not on Questionnaire tab
                                child: Opacity(
                                  opacity: absorbContent && _selectedTabIndex != 3 ? 0.5 : 1.0, // Visually indicate disabled state
                                  child: DashboardContentSwitcher(
                                    selectedTabIndex: _selectedTabIndex,
                                    screens: _dashboardScreens,
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