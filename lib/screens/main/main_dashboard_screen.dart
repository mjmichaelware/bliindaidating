// lib/screens/main/main_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

// Local imports (ensure these files are present in your project from the reverted state)
import 'package:bliindaidating/shared/glowing_button.dart';
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';
import 'package:bliindaidating/widgets/dashboard_penalty_section.dart';
import 'package:bliindaidating/widgets/dashboard_stat_card.dart';
import 'package:bliindaidating/widgets/dashboard_info_card.dart';
import 'package:bliindaidating/models/user_profile.dart'; // UserProfile import
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/app_constants.dart'; // AppConstants import
import 'package:bliindaidating/controllers/theme_controller.dart';

// OpenAI Integration Imports (already assumed to be present and correct)
import 'package:bliindaidating/services/openai_service.dart';
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';
import 'package:bliindaidating/models/newsfeed/ai_engagement_prompt.dart';


class MainDashboardScreen extends StatefulWidget {
  final int totalDatesAttended;
  final int currentMatches;
  final int penaltyCount;

  const MainDashboardScreen({
    super.key,
    required this.totalDatesAttended,
    required this.currentMatches,
    required this.penaltyCount,
  });

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  late final AnimationController _fadeScaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  late final ScrollController _scrollController;

  late int _penaltyCount;

  UserProfile? _userProfile;
  String? _profilePictureDisplayUrl; // Stores the URL for display
  bool _isLoadingProfile = true;
  StreamSubscription<List<Map<String, dynamic>>>? _profileSubscription;

  final ProfileService _profileService = ProfileService();
  final OpenAIService _openAIService = OpenAIService(); // Instantiate OpenAIService


  @override
  void initState() {
    super.initState();
    _penaltyCount = widget.penaltyCount;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeScaleController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _fadeScaleController, curve: Curves.easeOutBack),
    );

    _fadeScaleController.forward();

    _scrollController = ScrollController();

    _loadUserProfileAndSubscribe();
    // This call will attempt to fetch AI data and print to console.
    _fetchAIDummyData(); 
  }

  // Temporary method to fetch AI-generated dummy data and print to console
  Future<void> _fetchAIDummyData() async {
    debugPrint('--- Fetching AI Dummy Data (from MainDashboardScreen) ---');
    try {
      final List<UserProfile> dummyProfiles = await _openAIService.generateDummyUserProfiles(3);
      debugPrint('AI Generated Dummy Profiles:');
      for (var profile in dummyProfiles) {
        debugPrint('  - ${profile.displayName ?? profile.fullName ?? 'Unnamed User'} (${profile.userId}) - Looking For: ${profile.lookingFor}, Interests: ${profile.interests.join(', ')}');
      }

      final List<NewsfeedItem> newsfeedItems = await _openAIService.generateNewsfeedItems(
        5,
        userLocation: 'Salt Lake City, UT',
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


  @override
  void didUpdateWidget(covariant MainDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.penaltyCount != widget.penaltyCount) {
      setState(() {
        _penaltyCount = widget.penaltyCount;
      });
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
           if (mounted) context.go('/profile-setup');
           return;
        }
      } else {
        setState(() { _isLoadingProfile = false; });
        debugPrint('MainDashboardScreen: User profile not found for ID: ${currentUser.id}. Redirecting to setup.');
        if (mounted) {
          context.go('/profile-setup');
        }
      }

      _profileSubscription = Supabase.instance.client
          .from('profiles')
          .stream(primaryKey: ['id']) // FIXED: Changed primaryKey from 'user_id' to 'id'
          .eq('id', currentUser.id) // FIXED: Changed eq filter from 'user_id' to 'id'
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

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeScaleController.dispose();
    _scrollController.dispose();
    _profileSubscription?.cancel();
    super.dispose();
  }

  Widget _animatedStatCard({
    required String label,
    required int value,
    required IconData icon,
    required Color iconColor,
  }) {
    return DashboardStatCard(
      label: label,
      value: value,
      icon: icon,
      iconColor: iconColor,
      fadeAnimation: _fadeAnimation,
      scaleAnimation: _scaleAnimation,
      pulseAnimation: _pulseAnimation,
    );
  }

  Widget _animatedPenaltySection() {
    return DashboardPenaltySection(
      penaltyCount: _penaltyCount,
    );
  }

  Widget _suggestedProfiles() {
    List<String> dummyProfiles = ['Alex', 'Jamie', 'Taylor', 'Jordan', 'Morgan'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested Profiles',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dummyProfiles.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final profile = dummyProfiles[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.85, end: 1.0),
                  duration: Duration(milliseconds: 600 + index * 150),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade800,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.shade300.withOpacity(0.6),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        profile,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          shadows: [
                            Shadow(
                              color: Colors.pinkAccent,
                              blurRadius: 8,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dailyPersonalityQuestion() {
    return DashboardInfoCard(
      title: 'Daily Personality Question',
      description: 'What’s your ideal way to spend a weekend?',
      icon: FontAwesomeIcons.youtube,
      iconColor: const Color(0xFF8E24AA),
      trailingWidget: GlowingButton(
        icon: FontAwesomeIcons.youtube,
        text: 'Answer Now',
        onPressed: () {
          // TODO: Implement question answering flow
        },
        gradientColors: const [Color(0xFF8E24AA), Color(0xFFD32F2F)],
        height: 48,
        width: 160,
        textStyle: const TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter'),
      ),
    );
  }

  Widget _compatibilityScore() {
    return DashboardInfoCard(
      title: 'Compatibility Score',
      icon: Icons.star_rounded,
      iconColor: Colors.amber,
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.star_rounded, color: Colors.amber, size: 48),
              SizedBox(width: 16),
              Text(
                '87%',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 40, fontFamily: 'Inter'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'You both love deep conversations and outdoor adventures.',
            style: TextStyle(color: Colors.white70, fontSize: 18, fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }

  Widget _datingIntentions() {
    final String intention = _userProfile?.lookingFor ?? 'Not set yet';

    return DashboardInfoCard(
      title: 'Dating Intentions',
      description: intention,
      icon: Icons.flag_rounded,
      iconColor: Colors.pinkAccent,
      trailingWidget: GlowingButton(
        icon: Icons.edit_rounded,
        text: 'Edit',
        onPressed: () {
          context.go('/edit_profile');
        },
        gradientColors: const [Color(0xFF8E24AA), Color(0xFFD32F2F)],
        height: 44,
        width: 100,
        textStyle: const TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter'),
      ),
    );
  }

  Widget _nearbyEvents() {
    List<String> dummyEvents = [
      'Speed Dating Night - June 30',
      'Singles Mixer - July 5',
      'Outdoor Hike Meetup - July 12',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Events',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        ),
        const SizedBox(height: 16),
        ...dummyEvents.map(
          (event) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade800.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.shade700.withOpacity(0.7),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Text(
              event,
              style: const TextStyle(color: Colors.white70, fontSize: 18, fontFamily: 'Inter'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _premiumBenefits() {
    return DashboardInfoCard(
      title: 'Premium Benefits',
      description: 'Unlock profile boosts, advanced filters, and more!',
      icon: Icons.star_rounded,
      iconColor: Colors.amber,
      trailingWidget: GlowingButton(
        icon: Icons.upgrade_rounded,
        text: 'Upgrade Now',
        onPressed: () {
          // context.go('/premium');
        },
        gradientColors: const [Color(0xFFD32F2F), Color(0xFF8E24AA)],
        height: 52,
        width: double.infinity,
        textStyle: const TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Inter'),
      ),
    );
  }

  Widget _weeklyInsights() {
    final views = 45;
    final favorites = 12;
    final newMatches = 3;

    return DashboardInfoCard(
      title: 'Weekly Insights',
      description: null,
      icon: Icons.insights_rounded,
      iconColor: Colors.pink.shade300,
      customContent: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statIconLabel(Icons.visibility_rounded, 'Views', views),
          _statIconLabel(Icons.favorite_rounded, 'Favorites', favorites),
          _statIconLabel(Icons.favorite_border_rounded, 'New Matches', newMatches),
        ],
      ),
    );
  }

  Widget _statIconLabel(IconData icon, String label, int value) {
    return Column(
      children: [
        Icon(icon, color: Colors.pink.shade300, size: 34),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Inter'),
        ),
      ],
    );
  }

  Widget _privacyToggle() {
    bool privacyModeOn = false;

    return StatefulBuilder(builder: (context, setStateSB) {
      return DashboardInfoCard(
        title: 'Privacy Mode',
        description: null,
        icon: Icons.lock_rounded,
        iconColor: Colors.white70,
        trailingWidget: Switch(
          value: privacyModeOn,
          activeColor: Colors.pink.shade400,
          onChanged: (val) {
            setStateSB(() {
              privacyModeOn = val;
            });
          },
        ),
      );
    });
  }

  Widget _profileBoostButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: GlowingButton(
        icon: Icons.flash_on_rounded,
        text: 'Spotlight Me',
        onPressed: () {
          // TODO: Trigger profile boost with animation & feedback
        },
        gradientColors: const [Color(0xFFD32F2F), Color(0xFF8E24AA)],
        height: 52,
        width: double.infinity,
        textStyle: const TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Inter'),
      ),
    );
  }

  Widget _dateIdeas() {
    List<String> ideas = [
      'Picnic in the park',
      'Visit a local art gallery',
      'Try a cooking class',
      'Stargazing night',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Ideas',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        ),
        const SizedBox(height: 16),
        ...ideas.map(
          (idea) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '• $idea',
              style: const TextStyle(color: Colors.white70, fontSize: 18, fontFamily: 'Inter'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtendedProfileNudge(BuildContext context, bool isDarkMode) {
    // Corrected condition: Nudge only if profile is NOT complete
    if (_userProfile != null && !(_userProfile?.isProfileComplete ?? false)) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 24.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.black : Colors.grey.shade400).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade400, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Unlock Better Matches!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Inter',
                      color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your initial profile is complete, which got you in fast! But for the most accurate and meaningful matches, take a moment to complete your extended profile details.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Inter',
                color: isDarkMode ? AppConstants.textColor.withOpacity(0.8) : AppConstants.lightTextColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.go('/profile-setup');
                  debugPrint('Extended profile nudge clicked.');
                },
                child: Text(
                  'Complete Extended Profile',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontFamily: 'Inter',
                    color: isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink(); // Hide if profile is complete
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Main Dashboard',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor),
            onPressed: () {
              context.push('/settings');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration( // Wrapped RadialGradient in BoxDecoration
                gradient: RadialGradient(
                  colors: [
                    Colors.deepPurple.shade900.withOpacity(0.7),
                    Colors.black.withOpacity(0.85),
                  ],
                  center: Alignment.topLeft,
                  radius: 1.5,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isLoadingProfile
                          ? Center(
                              child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.secondary),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${_userProfile?.displayName ?? _userProfile?.fullName ?? 'User'}!',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontFamily: 'Inter',
                                    color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacingMedium),
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
                                  backgroundImage: _profilePictureDisplayUrl != null
                                      ? NetworkImage(_profilePictureDisplayUrl!) as ImageProvider<Object>
                                      : null,
                                  child: _profilePictureDisplayUrl == null
                                      ? Icon(
                                          Icons.account_circle,
                                          size: 60,
                                          color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: AppConstants.spacingLarge),
                              ],
                            ),

                      _buildExtendedProfileNudge(context, isDarkMode), // Directly call the widget, as it now returns SizedBox.shrink()

                      _animatedPenaltySection(),
                      const SizedBox(height: AppConstants.spacingLarge),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _animatedStatCard(
                            label: 'Dates Attended',
                            value: widget.totalDatesAttended,
                            icon: Icons.event_available_rounded,
                            iconColor: Colors.greenAccent.shade400,
                          ),
                          _animatedStatCard(
                            label: 'Current Matches',
                            value: widget.currentMatches,
                            icon: Icons.favorite_rounded,
                            iconColor: Colors.pink.shade400,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _suggestedProfiles(),
                      const SizedBox(height: 24),
                      _dailyPersonalityQuestion(),
                      const SizedBox(height: 24),
                      _compatibilityScore(),
                      const SizedBox(height: 24),
                      _datingIntentions(),
                      const SizedBox(height: 24),
                      _nearbyEvents(),
                      const SizedBox(height: 24),
                      _premiumBenefits(),
                      const SizedBox(height: 24),
                      _weeklyInsights(),
                      const SizedBox(height: 24),
                      _privacyToggle(),
                      const SizedBox(height: 24),
                      _profileBoostButton(),
                      const SizedBox(height: 24),
                      _dateIdeas(),
                      const SizedBox(height: 40),
                      GlowingButton(
                        icon: Icons.edit_rounded,
                        text: 'Edit Profile',
                        onPressed: () {
                          context.go('/edit_profile');
                        },
                        gradientColors: const [
                          Color(0xFF8E24AA),
                          Color(0xFFD32F2F),
                        ],
                        height: 52,
                        width: double.infinity,
                        textStyle:
                            const TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}