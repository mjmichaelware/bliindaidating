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
import 'package:bliindaidating/screens/profile/my_profile_screen.dart'; // From screens/profile
import 'package:bliindaidating/screens/discovery/discovery_screen.dart'; // Existing screen, likely in screens/discovery
import 'package:bliindaidating/screens/questionnaire/questionnaire_screen.dart';
import 'package:bliindaidating/screens/matches/matches_list_screen.dart'; // Existing screen, likely in screens/matches

// Assuming AnimatedOrbBackground is in landing_page/widgets as per tree
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';


class MainDashboardScreen extends StatefulWidget {
  // Parameters like totalDatesAttended, currentMatches, penaltyCount will be managed by sub-widgets or fetched as needed.
  // The main dashboard shell doesn't directly need them in its constructor anymore.
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
  final OpenAIService _openAIService = OpenAIService(); // Instantiate OpenAIService


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
      // NOTE: Ensure your OpenAIService.generateDummyUserProfiles returns UserProfile objects
      // with a 'userId' and 'profilePictureUrl' for these next steps to work correctly.
      final List<UserProfile> dummyProfiles = await _openAIService.generateDummyUserProfiles(3);
      debugPrint('AI Generated Dummy Profiles:');
      for (var profile in dummyProfiles) {
        debugPrint('  - ${profile.displayName ?? profile.fullName ?? 'Unnamed User'} (${profile.userId}) - Looking For: ${profile.lookingFor}, Interests: ${profile.interests.join(', ')}');
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

      if (dummyProfiles.isNotEmpty) {
        // Ensure generateDummyMatches can handle UserProfile objects
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
        if (!fetchedProfile.isProfileComplete) {
           debugPrint('MainDashboardScreen: Profile is not marked complete. Redirecting to setup.');
           if (mounted) context.go('/profile_setup'); // Corrected path if it was profile-setup
           return;
        }
      } else {
        setState(() { _isLoadingProfile = false; });
        debugPrint('MainDashboardScreen: User profile not found for ID: ${currentUser.id}. Redirecting to setup.');
        if (mounted) {
          context.go('/profile_setup'); // Corrected path if it was profile-setup
        }
      }

      _profileSubscription = Supabase.instance.client
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('id', currentUser.id)
          .listen((List<Map<String, dynamic>> data) async {
        if (data.isNotEmpty) {
          final UserProfile updatedProfile = UserProfile.fromJson(data.first);
          setState(() {
            _userProfile = updatedProfile;
          });
          debugPrint('MainDashboardScreen: Realtime update for profile: ${updatedProfile.displayName ?? updatedProfile.fullName}');
          if (updatedProfile.profilePictureUrl != null && updatedProfile.profilePictureUrl != _profilePictureDisplayUrl) {
            setState(() {
              _profilePictureDisplayUrl = updatedProfile.profilePictureUrl;
            });
          }
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

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    // List of screens for the DashboardContentSwitcher
    final List<Widget> _dashboardScreens = [
      const NewsfeedScreen(), // Now a Stateful widget that fetches AI data
      const MatchesListScreen(), // Now correctly navigates to ProfileViewScreen
      const DiscoveryScreen(), // Now the overhauled Profile Discovery screen
      const QuestionnaireScreen(), // Now a Stateful widget that fetches questions
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      // Use the new DashboardAppBar
      appBar: const DashboardAppBar(),
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
                // Left Side Menu
                DashboardSideMenu(
                  userProfile: _userProfile,
                  profilePictureUrl: _profilePictureDisplayUrl,
                  selectedTabIndex: _selectedTabIndex,
                  onTabSelected: _onTabSelected,
                ),
                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Loading indicator for profile
                      _isLoadingProfile
                          ? Expanded(
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.secondary),
                              ),
                            )
                          : Expanded(
                              // Use DashboardContentSwitcher for displaying current tab's content
                              child: DashboardContentSwitcher(
                                selectedTabIndex: _selectedTabIndex,
                                screens: _dashboardScreens,
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