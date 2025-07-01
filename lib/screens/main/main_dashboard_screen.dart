// lib/screens/main/main_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:provider/provider.dart'; // Added: Import Provider for ThemeController

import 'package:bliindaidating/shared/glowing_button.dart';
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';
import 'package:bliindaidating/widgets/dashboard_header.dart';
import 'package:bliindaidating/widgets/dashboard_penalty_section.dart';
import 'package:bliindaidating/widgets/dashboard_stat_card.dart';
import 'package:bliindaidating/widgets/dashboard_info_card.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Added for UserProfile model
import 'package:bliindaidating/services/profile_service.dart'; // Added for ProfileService
import 'package:bliindaidating/app_constants.dart'; // Added: Import AppConstants for theme values
import 'package:bliindaidating/controllers/theme_controller.dart'; // Added: Import ThemeController

// Removed: import 'package:bliindaidating/dashboard_menu_drawer.dart'; // This import must be removed or commented out


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

  // Added for user profile data and Realtime
  UserProfile? _userProfile; // Will hold the fetched user profile
  String? _avatarUrl; // Will hold the signed URL for the avatar
  bool _isLoadingProfile = true; // State to manage profile loading
  StreamSubscription<List<Map<String, dynamic>>>? _profileSubscription; // Realtime subscription

  // Instantiate ProfileService using its singleton factory constructor
  final ProfileService _profileService = ProfileService();

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

    _loadUserProfileAndSubscribe(); // Call method to load profile and set up subscription
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
      debugPrint('No current user for dashboard profile load.');
      return;
    }

    try {
      final UserProfile? fetchedProfile = await _profileService.getUserProfile(currentUser.id);
      if (fetchedProfile != null) {
        setState(() {
          _userProfile = fetchedProfile;
          _isLoadingProfile = false;
        });
        // Corrected to profilePictureUrl (camelCase)
        if (fetchedProfile.profilePictureUrl != null) {
          // Using the _profileService instance
          final String? signedUrl = await _profileService.getAnalysisPhotoSignedUrl(fetchedProfile.profilePictureUrl!);
          setState(() {
            _avatarUrl = signedUrl;
          });
        }
      } else {
        setState(() { _isLoadingProfile = false; });
        debugPrint('User profile not found for ID: ${currentUser.id}');
        // Optionally create a default profile or redirect to setup if profile is required
        // context.go('/profile_setup');
      }

      // Setup Realtime Subscription
      _profileSubscription = Supabase.instance.client
          .from('profiles')
          .stream(primaryKey: ['id']) // Ensure 'id' is your primary key
          .eq('id', currentUser.id) // Listen only to current user's profile changes
          .listen((List<Map<String, dynamic>> data) async {
        if (data.isNotEmpty) {
          // Changed to UserProfile.fromJson
          final UserProfile updatedProfile = UserProfile.fromJson(data.first);
          setState(() {
            _userProfile = updatedProfile;
          });
          // Corrected to fullName (camelCase)
          debugPrint('Realtime update for profile: ${updatedProfile.fullName}');
          // Corrected to profilePictureUrl (camelCase) and using _profileService
          if (updatedProfile.profilePictureUrl != null && updatedProfile.profilePictureUrl != _userProfile?.profilePictureUrl) {
            final String? signedUrl = await _profileService.getAnalysisPhotoSignedUrl(updatedProfile.profilePictureUrl!);
            setState(() {
              _avatarUrl = signedUrl;
            });
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading profile or setting up Realtime: $e');
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
    _profileSubscription?.cancel(); // Cancel Realtime subscription to prevent memory leaks
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
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'), // Ensure Inter font
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
                          fontFamily: 'Inter', // Ensure Inter font
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
        textStyle: const TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter'), // Ensure Inter font
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
                    fontSize: 40, fontFamily: 'Inter'), // Ensure Inter font
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'You both love deep conversations and outdoor adventures.',
            style: TextStyle(color: Colors.white70, fontSize: 18, fontFamily: 'Inter'), // Ensure Inter font
          ),
        ],
      ),
      trailingWidget: null,
    );
  }

  Widget _datingIntentions() {
    const String intention = 'Looking for Long-term Relationship';

    return DashboardInfoCard(
      title: 'Dating Intentions',
      description: intention,
      icon: Icons.flag_rounded,
      iconColor: Colors.pinkAccent,
      trailingWidget: GlowingButton(
        icon: Icons.edit_rounded,
        text: 'Edit',
        onPressed: () {
          context.go('/profile_setup');
        },
        gradientColors: const [Color(0xFF8E24AA), Color(0xFFD32F2F)],
        height: 44,
        width: 100,
        textStyle: const TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Inter'), // Ensure Inter font
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
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'), // Ensure Inter font
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
              style: const TextStyle(color: Colors.white70, fontSize: 18, fontFamily: 'Inter'), // Ensure Inter font
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
        textStyle: const TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Inter'), // Ensure Inter font
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
      trailingWidget: null,
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
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'), // Ensure Inter font
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Inter'), // Ensure Inter font
        ),
      ],
    );
  }

  Widget _privacyToggle() {
    bool privacyModeOn = false; // Ideally from state or service

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
              // TODO: Persist privacy mode state & trigger haptics
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
        textStyle: const TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Inter'), // Ensure Inter font
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
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'), // Ensure Inter font
        ),
        const SizedBox(height: 16),
        ...ideas.map(
          (idea) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '• $idea',
              style: const TextStyle(color: Colors.white70, fontSize: 18, fontFamily: 'Inter'), // Ensure Inter font
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Removed: endDrawer: DashboardMenuDrawer(...)
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
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
                          : DashboardHeader(
                              title: _userProfile?.fullName ?? 'Profile Dashboard', // Corrected to fullName (camelCase)
                              glowColor: Colors.redAccent,
                              shadowOffset: const Offset(0, 5),
                            ),
                      const SizedBox(height: 24),
                      _animatedPenaltySection(),
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
                          context.go('/profile_setup');
                        },
                        gradientColors: const [
                          Color(0xFF8E24AA),
                          Color(0xFFD32F2F),
                        ],
                        height: 52,
                        width: double.infinity,
                        textStyle:
                            const TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Inter'), // Ensure Inter font
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

