// lib/widgets/dashboard_shell/dashboard_side_menu.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math; // For math.pi and other math functions

import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile
import 'package:bliindaidating/services/auth_service.dart'; // Import AuthService for sign out
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService for completion status

// NEW IMPORTS for all screens and categories to be linked
// Corrected path for profile_setup_screen.dart
import 'package:bliindaidating/profile/profile_setup_screen.dart'; // Corrected Path for Phase 1 setup

// All other imports remain as they were in your last provided version.
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart'; // For /home
import 'package:bliindaidating/screens/discovery/discover_people_screen.dart'; // For /discovery
import 'package:bliindaidating/screens/matches/matches_list_screen.dart'; // For /matches
import 'package:bliindaidating/screens/daily/daily_prompts_screen.dart'; // For /daily-prompts
import 'package:bliindaidating/screens/notifications/notifications_screen.dart'; // For /notifications
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart'; // For /questionnaire-phase2
import 'package:bliindaidating/screens/questionnaire/questionnaire_screen.dart'; // For /questionnaire

// Friends & Events related screens
import 'package:bliindaidating/friends/local_events_screen.dart'; // For /events
import 'package:bliindaidating/friends/friends_match_screen.dart'; // For /friends-match
import 'package:bliindaidating/friends/event_details_screen.dart'; // For /event-details (if dynamic)

// Matching Insights related screens
import 'package:bliindaidating/screens/dashboard/compatibility_results_screen.dart'; // For /compatibility-results
import 'package:bliindaidating/screens/dashboard/daily_personality_question_screen.dart'; // For /daily-personality-question
import 'package:bliindaidating/screens/quiz/personality_quiz_screen.dart'; // For /personality-quiz

// Date Management related screens
import 'package:bliindaidating/screens/date/scheduled_dates_list_screen.dart'; // For /scheduled-dates-list
import 'package:bliindaidating/screens/date/post_date_feedback_screen.dart'; // For /post-date-feedback
import 'package:bliindaidating/matching/date_proposal_screen.dart'; // For /date-proposal

// Info & Support related screens
import 'package:bliindaidating/screens/info/activity_feed_screen.dart'; // For /activity-feed
import 'package:bliindaidating/screens/info/blocked_users_screen.dart'; // For /blocked-users
import 'package:bliindaidating/screens/info/date_ideas_screen.dart'; // For /date-ideas
import 'package:bliindaidating/screens/info/guided_tour_screen.dart'; // For /guided-tour
import 'package:bliindaidating/screens/info/privacy_screen.dart'; // For /privacy
import 'package:bliindaidating/screens/info/safety_tips_screen.dart'; // For /safety-tips
import 'package:bliindaidating/screens/info/terms_screen.dart'; // For /terms
import 'package:bliindaidating/screens/info/user_progress_screen.dart'; // For /user-progress
import 'package:bliindaidating/screens/feedback_report/feedback_screen.dart'; // For /feedback
import 'package:bliindaidating/screens/feedback_report/report_screen.dart'; // For /report
import 'package:bliindaidating/screens/info/about_us_screen.dart'; // For /about-us

// Settings related screens
import 'package:bliindaidating/screens/settings/app_settings_screen.dart'; // For /app-settings
import 'package:bliindaidating/screens/admin/admin_dashboard_screen.dart'; // For /admin
import 'package:bliindaidating/screens/premium/referral_screen.dart'; // For /referral

// Other specific screens that might be linked
import 'package:bliindaidating/screens/profile/my_profile_screen.dart'; // For /my-profile
import 'package:bliindaidating/screens/favorites/favorites_list_screen.dart'; // For /favorites
import 'package:bliindaidating/matching/match_display_screen.dart'; // For /match-display
import 'package:bliindaidating/screens/date/scheduled_date_details_screen.dart'; // For /scheduled-date-details
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart'; // Explicit import for newsfeed

// NEW IMPORT for the new dashboard overview screen
import 'package:bliindaidating/screens/dashboard/dashboard_overview_screen.dart';
// REMOVED: import 'package:bliindaidating/widgets/global/custom_network_image.dart'; // This was causing the error


// --- Custom Painter for Side Menu Background (Inspired by NebulaBackgroundPainter) ---
class SideMenuBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Offset> particles;
  final double particleMaxRadius;
  final bool isDrawerMode; // Added to control opacity

  SideMenuBackgroundPainter(
    this.animation,
    this.primaryColor,
    this.secondaryColor,
    this.particles,
    this.particleMaxRadius,
    this.isDrawerMode, // Added
  ) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Main gradient background
    final color1 = Color.lerp(primaryColor.withOpacity(0.4), secondaryColor.withOpacity(0.6), animation.value)!;
    final color2 = Color.lerp(secondaryColor.withOpacity(0.4), primaryColor.withOpacity(0.6), animation.value)!;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient( // Changed to Linear for side menu feel
          colors: [color1, color2, Colors.transparent],
          stops: const [0.0, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & size),
    );

    // Secondary subtle glow/nebula effect
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppConstants.textColor.withOpacity(0.05 + animation.value * 0.05),
            AppConstants.textColor.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
          center: Alignment(math.cos(animation.value * math.pi) * 0.7, math.sin(animation.value * math.pi) * 0.7),
          radius: 0.2 + 0.1 * animation.value,
        ).createShader(Offset.zero & size)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 * animation.value),
    );

    // Particles (inspired by ParticleFieldPainter)
    final particlePaint = Paint()
      ..color = AppConstants.textColor.withOpacity(0.2 + 0.3 * animation.value)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleMaxRadius * animation.value * 0.5);

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final driftX = math.sin(animation.value * math.pi * 2 + i * 0.1) * 3;
      final driftY = math.cos(animation.value * math.pi * 2 + i * 0.1) * 3;
      final currentPosition = Offset(particle.dx * size.width + driftX, particle.dy * size.height + driftY);
      canvas.drawCircle(currentPosition, particleMaxRadius * animation.value, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SideMenuBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.primaryColor != primaryColor ||
           oldDelegate.secondaryColor != secondaryColor ||
           oldDelegate.isDrawerMode != isDrawerMode; // Added
  }
}

// --- Side Menu Profile Header (Enhanced) ---
class _SideMenuProfileHeader extends StatelessWidget {
  final UserProfile? userProfile;
  final String? profilePictureUrl;
  final Animation<double> expandAnimation;
  final bool isCollapsed;

  const _SideMenuProfileHeader({
    super.key,
    required this.userProfile,
    required this.profilePictureUrl,
    required this.expandAnimation,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color headerAccentColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color headerTextColor = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color onlineIndicatorColor = AppConstants.successColor;

    final String displayName = userProfile?.displayName ?? userProfile?.fullLegalName ?? 'Stellar Traveler'; // Corrected to use fullLegalName

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.paddingLarge,
        horizontal: AppConstants.paddingMedium,
      ),
      child: Column(
        children: [
          // Profile Picture with Animated Glow
          AnimatedBuilder(
            animation: expandAnimation,
            builder: (context, child) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: expandAnimation, curve: Curves.easeOutBack),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: headerAccentColor.withOpacity(0.4 * expandAnimation.value),
                        blurRadius: 15 * expandAnimation.value,
                        spreadRadius: 5 * expandAnimation.value,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: AppConstants.avatarRadius,
                    backgroundColor: AppConstants.cardColor.withOpacity(0.8),
                    backgroundImage: profilePictureUrl != null
                        ? NetworkImage(profilePictureUrl!)
                        : null,
                    child: profilePictureUrl == null
                        ? Icon(
                            Icons.person_rounded,
                            size: AppConstants.avatarRadius * 1.2,
                            color: headerTextColor.withOpacity(0.7),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          // User Name and Status
          AnimatedCrossFade(
            duration: AppConstants.animationDurationMedium,
            crossFadeState: isCollapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Container(width: 0, height: 0), // Collapsed state
            secondChild: Column(
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    color: headerTextColor,
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: onlineIndicatorColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: onlineIndicatorColor.withOpacity(0.6),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: headerTextColor.withOpacity(0.8),
                        fontSize: AppConstants.fontSizeSmall,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// --- Side Menu Item (Generic) ---
class _SideMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isCollapsed;
  final bool showNotificationBadge; // New property
  final int notificationCount; // New property
  final bool isComingSoon; // New property

  const _SideMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isCollapsed = false,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.isComingSoon = false, // Initialize here
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final itemColor = isDarkMode ? AppConstants.textColor.withOpacity(0.9) : AppConstants.lightTextColor.withOpacity(0.9);
    final selectedItemColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final badgeColor = AppConstants.errorColor; // For notification badge

    // Determine if this item is currently active based on the GoRouter location
    // Corrected GoRouter.of(context).currentRoute.fullPath to GoRouter.of(context).routerDelegate.currentConfiguration.fullPath
    final bool isSelected = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath == _getPathFromTitle(title);
    return InkWell(
      onTap: isComingSoon ? null : onTap, // Disable tap if coming soon
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingSmall,
          vertical: AppConstants.paddingExtraSmall,
        ),
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.paddingMedium,
          horizontal: isCollapsed ? AppConstants.paddingSmall : AppConstants.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedItemColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        child: Row(
          mainAxisSize: isCollapsed ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(
              icon,
              color: isSelected ? selectedItemColor : itemColor,
              size: AppConstants.fontSizeLarge,
            ),
            AnimatedCrossFade(
              duration: AppConstants.animationDurationMedium,
              crossFadeState: isCollapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: const SizedBox.shrink(), // Collapsed state (no text)
              secondChild: Row(
                children: [
                  const SizedBox(width: AppConstants.spacingMedium),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? selectedItemColor : itemColor,
                      fontSize: AppConstants.fontSizeMedium,
                      fontFamily: 'Inter',
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (showNotificationBadge && notificationCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: AppConstants.spacingSmall),
                      child: Container(
                        padding: const EdgeInsets.all(AppConstants.paddingExtraSmall),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          notificationCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppConstants.fontSizeSmall,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (isComingSoon)
                    Padding(
                      padding: const EdgeInsets.only(left: AppConstants.spacingSmall),
                      child: Text(
                        '(Coming Soon)',
                        style: TextStyle(
                          color: itemColor.withOpacity(0.6),
                          fontSize: AppConstants.fontSizeSmall,
                          fontFamily: 'Inter',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to determine the path from title for selection
  String _getPathFromTitle(String title) {
    switch (title) {
      case 'Dashboard':
        return '/dashboard-overview';
      case 'Discovery':
        return '/discovery';
      case 'Matches':
        return '/matches';
      case 'Newsfeed':
        return '/newsfeed';
      case 'Daily Prompts':
        return '/daily-prompts';
      case 'Notifications':
        return '/notifications';
      case 'Profile Setup':
        return '/profile_setup'; // Path for Phase 1
      case 'AI Questionnaire':
        return '/questionnaire'; // Path for general questionnaire or phase 2 direct link
      case 'My Profile':
        return '/my-profile';
      case 'Scheduled Dates':
        return '/scheduled-dates-list';
      case 'Post-Date Feedback':
        return '/post-date-feedback';
      case 'Date Proposal':
        return '/date-proposal';
      case 'Compatibility Insights':
        return '/compatibility-results';
      case 'Daily Personality Question':
        return '/daily-personality-question';
      case 'Personality Quiz':
        return '/personality-quiz';
      case 'Local Events':
        return '/events';
      case 'Friends Match':
        return '/friends-match';
      case 'App Settings': // Corrected to App Settings
        return '/app-settings';
      case 'About Us':
        return '/about-us';
      case 'Privacy Policy':
        return '/privacy';
      case 'Terms & Conditions':
        return '/terms';
      case 'Feedback':
        return '/feedback';
      case 'Report User':
        return '/report';
      case 'Admin Dashboard':
        return '/admin';
      case 'Referral Program':
        return '/referral';
      case 'Activity Feed':
        return '/activity-feed';
      case 'Blocked Users':
        return '/blocked-users';
      case 'Date Ideas':
        return '/date-ideas';
      case 'Guided Tour':
        return '/guided-tour';
      case 'Safety Tips':
        return '/safety-tips';
      case 'User Progress':
        return '/user-progress';
      case 'Favorites':
        return '/favorites';
      case 'Match Display': // While not directly in menu, good to have path mapping
        return '/match-display';
      case 'Scheduled Date Details': // While not directly in menu, good to have path mapping
        return '/scheduled-date-details';
      default:
        return '';
    }
  }
}

// --- Main Side Menu Widget ---
class DashboardSideMenu extends StatefulWidget {
  final UserProfile? userProfile;
  final String? profilePictureUrl;
  final int selectedTabIndex;
  final Function(int) onTabSelected;
  final bool isPhase2Complete; // This is passed from MainDashboardScreen
  final Function(bool) onCollapseToggle;
  final bool isInitiallyCollapsed;
  final bool isDrawerMode;

  const DashboardSideMenu({
    super.key,
    required this.userProfile,
    required this.profilePictureUrl,
    required this.selectedTabIndex,
    required this.onTabSelected,
    required this.isPhase2Complete,
    required this.onCollapseToggle,
    required this.isInitiallyCollapsed,
    required this.isDrawerMode,
  });

  @override
  State<DashboardSideMenu> createState() => _DashboardSideMenuState();
}

class _DashboardSideMenuState extends State<DashboardSideMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late bool _isCollapsed;

  final List<Offset> _particles = List.generate(50, (index) => Offset(math.Random().nextDouble(), math.Random().nextDouble()));
  static const double _particleMaxRadius = 2.0;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.isInitiallyCollapsed;

    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationLong,
    )..repeat(reverse: true);
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DashboardSideMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInitiallyCollapsed != oldWidget.isInitiallyCollapsed) {
      setState(() {
        _isCollapsed = widget.isInitiallyCollapsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    // FIX: Get ProfileService directly here for phase completion flags
    final profileService = Provider.of<ProfileService>(context);
    final authService = Provider.of<AuthService>(context, listen: false); // listen: false if only calling methods

    final isDarkMode = themeController.isDarkMode;
    final primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final dividerColor = isDarkMode ? AppConstants.borderColor : AppConstants.lightBorderColor;

    // Use profileService's userProfile to get current phase completion statuses
    final bool isPhase1Complete = profileService.userProfile?.isPhase1Complete ?? false;
    final bool isPhase2Complete = profileService.userProfile?.isPhase2Complete ?? false; // This is redundant with widget.isPhase2Complete but safe
    final bool isProfileFullyComplete = isPhase1Complete && isPhase2Complete;


    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Drawer(
          // width: _isCollapsed ? 80 : 250, // Let its parent control width if not in DrawerMode
          width: widget.isDrawerMode ? MediaQuery.of(context).size.width * 0.75 : (_isCollapsed ? 80 : 250),
          child: CustomPaint(
            painter: SideMenuBackgroundPainter(
              _animationController,
              primaryColor,
              secondaryColor,
              _particles,
              _particleMaxRadius,
              widget.isDrawerMode,
            ),
            child: Container(
              color: Colors.transparent,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Profile Header
                  _SideMenuProfileHeader(
                    userProfile: profileService.userProfile, // Use profileService.userProfile
                    profilePictureUrl: profileService.userProfile?.profilePictureUrl, // Use profileService.userProfile
                    expandAnimation: _expandAnimation,
                    isCollapsed: _isCollapsed,
                  ),
                  // Toggle Collapse Button - only show if not in drawer mode
                  if (!widget.isDrawerMode)
                    ListTile(
                      title: AnimatedCrossFade(
                        duration: AppConstants.animationDurationShort,
                        crossFadeState: _isCollapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        firstChild: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_forward_ios_rounded, color: textColor.withOpacity(0.7)),
                        ),
                        secondChild: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_back_ios_rounded, color: textColor.withOpacity(0.7)),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _isCollapsed = !_isCollapsed;
                          widget.onCollapseToggle(_isCollapsed);
                        });
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                    ),
                  Divider(color: dividerColor.withOpacity(0.5), height: 1),

                  // --- Core Navigation ---
                  _SideMenuItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    onTap: () {
                      context.go('/dashboard-overview');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.person_search_rounded,
                    title: 'Discovery',
                    onTap: () {
                      context.go('/discovery');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.favorite_rounded,
                    title: 'Matches',
                    onTap: () {
                      context.go('/matches');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                    _SideMenuItem(
                    icon: Icons.rss_feed_rounded,
                    title: 'Newsfeed',
                    onTap: () {
                      context.go('/newsfeed');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.notifications_active_rounded,
                    title: 'Notifications',
                    onTap: () {
                      context.go('/notifications');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                    showNotificationBadge: true,
                    notificationCount: 5,
                  ),
                  Divider(color: dividerColor.withOpacity(0.5), height: 1),

                  // --- Profile & AI Section ---
                  _SideMenuItem(
                    icon: Icons.person_rounded,
                    title: 'My Profile',
                    onTap: () {
                      context.go('/my-profile');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.settings_accessibility_rounded,
                    title: 'Profile Setup',
                    onTap: () {
                      if (!isPhase1Complete) {
                        context.go('/profile_setup');
                      } else if (!isPhase2Complete) {
                        context.go('/questionnaire-phase2');
                      } else {
                        // If both complete, perhaps go to a profile completion summary or just My Profile
                        context.go('/my-profile');
                      }
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.quiz_rounded,
                    title: 'AI Questionnaire',
                    onTap: () {
                      context.go('/questionnaire');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Daily Prompts',
                    onTap: () {
                      context.go('/daily-prompts');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  Divider(color: dividerColor.withOpacity(0.5), height: 1),

                  // --- Match Insights ---
                  _SideMenuItem(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Compatibility Insights',
                    onTap: () {
                      context.go('/compatibility-results');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.quiz_rounded, // Corrected icon
                    title: 'Daily Personality Question',
                    onTap: () {
                      context.go('/daily-personality-question');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.psychology_alt_rounded,
                    title: 'Personality Quiz',
                    onTap: () {
                      context.go('/personality-quiz');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  Divider(color: dividerColor.withOpacity(0.5), height: 1),

                  // --- Date Management ---
                  _SideMenuItem(
                    icon: Icons.calendar_today_rounded,
                    title: 'Scheduled Dates',
                    onTap: () {
                      context.go('/scheduled-dates-list');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.rate_review_rounded,
                    title: 'Post-Date Feedback',
                    onTap: () {
                      context.go('/post-date-feedback');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.send_rounded,
                    title: 'Date Proposal',
                    onTap: () {
                      context.go('/date-proposal');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  Divider(color: dividerColor.withOpacity(0.5), height: 1),

                  // --- Social & Events (Coming Soon) ---
                  _SideMenuItem(
                    icon: Icons.groups_rounded,
                    title: 'Friends Match',
                    onTap: () { /* No-op */ },
                    isCollapsed: _isCollapsed,
                    isComingSoon: true, // Mark as coming soon
                  ),
                  _SideMenuItem(
                    icon: Icons.event_note_rounded,
                    title: 'Local Events',
                    onTap: () {
                      context.go('/events');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  Divider(color: dividerColor.withOpacity(0.5), height: 1),

                  // --- Info & Support ---
                  _SideMenuItem(
                    icon: Icons.feedback_rounded,
                    title: 'Feedback',
                    onTap: () {
                      context.go('/feedback');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.gavel_rounded,
                    title: 'Report User',
                    onTap: () {
                      context.go('/report');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.help_rounded,
                    title: 'Guided Tour',
                    onTap: () {
                      context.go('/guided-tour');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                   _SideMenuItem(
                    icon: Icons.security_rounded,
                    title: 'Safety Tips',
                    onTap: () {
                      context.go('/safety-tips');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.privacy_tip_rounded,
                    title: 'Privacy Policy',
                    onTap: () {
                      context.go('/privacy');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.policy_rounded,
                    title: 'Terms & Conditions',
                    onTap: () {
                      context.go('/terms');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.info_rounded,
                    title: 'About Us',
                    onTap: () {
                      context.go('/about-us');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'User Progress',
                    onTap: () {
                      context.go('/user-progress');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.favorite_border_rounded,
                    title: 'Favorites',
                    onTap: () {
                      context.go('/favorites');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                   _SideMenuItem(
                    icon: Icons.block_rounded,
                    title: 'Blocked Users',
                    onTap: () {
                      context.go('/blocked-users');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  _SideMenuItem(
                    icon: Icons.lightbulb_rounded,
                    title: 'Date Ideas',
                    onTap: () {
                      context.go('/date-ideas');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  Divider(color: dividerColor.withOpacity(0.5), height: 1),

                  // --- Settings & Admin ---
                   _SideMenuItem(
                    icon: Icons.settings_rounded,
                    title: 'App Settings', // Corrected title
                    onTap: () {
                      context.go('/app-settings');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                   _SideMenuItem(
                    icon: Icons.person_add_rounded,
                    title: 'Referral Program',
                    onTap: () {
                      context.go('/referral');
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  // Admin Dashboard - show only if user is admin (you'll need to check this from userProfile)
                  if (profileService.userProfile?.isAdmin == true)
                    _SideMenuItem(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Admin Dashboard',
                      onTap: () {
                        context.go('/admin');
                        if (widget.isDrawerMode) Navigator.of(context).pop();
                      },
                      isCollapsed: _isCollapsed,
                    ),
                  Divider(color: dividerColor.withOpacity(0.5), height: 1),

                  // --- Sign Out ---
                  _SideMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    onTap: () async {
                      debugPrint('DashboardSideMenu: Sign Out button pressed.');
                      await authService.signOut();
                      if (context.mounted) {
                        context.go('/login'); // Redirect to login after sign out
                      }
                      if (widget.isDrawerMode) Navigator.of(context).pop();
                    },
                    isCollapsed: _isCollapsed,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge), // Extra space at bottom
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}