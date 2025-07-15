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
                        color: onlineIndicatorColor,
                        fontSize: AppConstants.fontSizeSmall,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextButton(
                  onPressed: () {
                    context.go('/my-profile');
                  },
                  child: Text(
                    'Manage Profile',
                    style: TextStyle(
                      color: headerAccentColor,
                      fontSize: AppConstants.fontSizeSmall,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: headerAccentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppConstants.borderColor.withOpacity(0.2), height: AppConstants.spacingMedium),
        ],
      ),
    );
  }
}

// --- Side Menu Item (Enhanced with Hover and Animation) ---
class _SideMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String routeName;
  final bool isSelected;
  final bool isEnabled;
  final bool isCollapsed;
  final ValueChanged<int>? onTabSelected; // For main dashboard tabs
  final int? tabIndex; // Corresponding tab index for onTabSelected
  final Animation<double> expandAnimation;

  const _SideMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.routeName,
    this.isSelected = false,
    this.isEnabled = true,
    required this.isCollapsed,
    this.onTabSelected,
    this.tabIndex,
    required this.expandAnimation,
  }) : super(key: key);

  @override
  State<_SideMenuItem> createState() => _SideMenuItemState();
}

class _SideMenuItemState extends State<_SideMenuItem> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationShort,
    );
    _hoverAnimation = CurvedAnimation(parent: _hoverController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color selectedItemColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color unselectedItemColor = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color disabledColor = isDarkMode ? AppConstants.textLowEmphasis.withOpacity(0.3) : AppConstants.lightTextLowEmphasis.withOpacity(0.3);

    final Color currentIconColor = widget.isEnabled
        ? (widget.isSelected ? selectedItemColor : unselectedItemColor)
        : disabledColor;
    final Color currentTextColor = widget.isEnabled
        ? (widget.isSelected ? textColor : unselectedItemColor)
        : disabledColor;

    return MouseRegion(
      onEnter: (_) {
        if (widget.isEnabled) _hoverController.forward();
      },
      onExit: (_) {
        if (widget.isEnabled) _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.isEnabled
            ? () {
                if (widget.onTabSelected != null && widget.tabIndex != null) {
                  widget.onTabSelected!(widget.tabIndex!);
                } else {
                  context.go(widget.routeName);
                }
              }
            : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.expandAnimation, _hoverAnimation]),
          builder: (context, child) {
            final double expandFactor = widget.expandAnimation.value;
            final double hoverFactor = _hoverAnimation.value;

            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingSmall,
                vertical: AppConstants.paddingExtraSmall,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected && widget.isEnabled
                    ? selectedItemColor.withOpacity(0.2 + 0.1 * hoverFactor)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: widget.isSelected && widget.isEnabled
                    ? Border.all(color: selectedItemColor.withOpacity(0.5 + 0.2 * hoverFactor), width: 1.0 + 0.5 * hoverFactor)
                    : null,
                boxShadow: [
                  if (widget.isSelected && widget.isEnabled)
                    BoxShadow(
                      color: selectedItemColor.withOpacity(0.2 * hoverFactor + 0.1),
                      blurRadius: 8 * hoverFactor + 4,
                      spreadRadius: 2 * hoverFactor + 1,
                    ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: Color.lerp(currentIconColor, selectedItemColor, hoverFactor),
                      size: AppConstants.fontSizeExtraLarge * (1.0 + 0.1 * hoverFactor),
                    ),
                    SizedBox(width: AppConstants.spacingMedium * expandFactor),
                    Expanded(
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: expandFactor,
                          child: Opacity(
                            opacity: expandFactor,
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                color: Color.lerp(currentTextColor, textColor, hoverFactor),
                                fontSize: AppConstants.fontSizeMedium,
                                fontFamily: 'Inter',
                                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- Side Menu Category Item (Enhanced ExpansionTile) ---
class _SideMenuCategoryItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isCollapsed;
  final Animation<double> expandAnimation;

  const _SideMenuCategoryItem({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    required this.isCollapsed,
    required this.expandAnimation,
  });

  @override
  State<_SideMenuCategoryItem> createState() => _SideMenuCategoryItemState();
}

class _SideMenuCategoryItemState extends State<_SideMenuCategoryItem> with SingleTickerProviderStateMixin {
  late AnimationController _expansionController;
  late Animation<double> _expansionAnimation;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expansionController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationMedium,
    );
    _expansionAnimation = CurvedAnimation(parent: _expansionController, curve: Curves.easeInOutCubic);

    _hoverController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationShort,
    );
    _hoverAnimation = CurvedAnimation(parent: _hoverController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color unselectedItemColor = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color selectedItemColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.expandAnimation, _hoverAnimation, _expansionAnimation]),
        builder: (context, child) {
          final double expandFactor = widget.expandAnimation.value;
          final double hoverFactor = _hoverAnimation.value;

          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingSmall,
              vertical: AppConstants.paddingExtraSmall,
            ),
            decoration: BoxDecoration(
              color: _isExpanded
                  ? selectedItemColor.withOpacity(0.15 + 0.05 * hoverFactor)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              border: _isExpanded
                  ? Border.all(color: selectedItemColor.withOpacity(0.3 + 0.1 * hoverFactor), width: 1.0)
                  : null,
              boxShadow: [
                if (_isExpanded)
                  BoxShadow(
                    color: selectedItemColor.withOpacity(0.1 * hoverFactor + 0.05),
                    blurRadius: 5 * hoverFactor + 2,
                    spreadRadius: 1 * hoverFactor + 0.5,
                  ),
              ],
            ),
            child: ClipRRect( // Clip to prevent overflow during collapse
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              child: Theme( // Override default ExpansionTile theme for custom styling
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  listTileTheme: ListTileThemeData(
                    iconColor: unselectedItemColor,
                    textColor: textColor,
                    selectedColor: selectedItemColor,
                    minLeadingWidth: AppConstants.fontSizeExtraLarge,
                  ),
                ),
                child: ExpansionTile(
                  key: ValueKey(widget.title), // Key to ensure state is reset when title changes
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _isExpanded = expanded;
                    });
                    if (expanded) {
                      _expansionController.forward();
                    } else {
                      _expansionController.reverse();
                    }
                  },
                  leading: Icon(
                    widget.icon,
                    color: Color.lerp(unselectedItemColor, selectedItemColor, hoverFactor),
                    size: AppConstants.fontSizeExtraLarge * (1.0 + 0.1 * hoverFactor),
                  ),
                  title: ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: expandFactor,
                      child: Opacity(
                        opacity: expandFactor,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: Color.lerp(unselectedItemColor, textColor, hoverFactor),
                            fontSize: AppConstants.fontSizeMedium,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  trailing: AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0.0, // Rotate arrow when expanded
                    duration: AppConstants.animationDurationMedium,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: unselectedItemColor.withOpacity(expandFactor),
                      size: AppConstants.fontSizeSmall * 1.5,
                    ),
                  ),
                  children: [
                    // Sub-items are only visible when expanded
                    Padding(
                      padding: EdgeInsets.only(left: AppConstants.paddingLarge * expandFactor),
                      child: SizeTransition(
                        sizeFactor: _expansionAnimation,
                        child: FadeTransition(
                          opacity: AlwaysStoppedAnimation<double>(_expansionAnimation.value),
                          child: Column(
                            children: widget.children.map<Widget>((child) {
                              // Ensure sub-items also respect the theme and expand factor
                              if (child is _SideMenuItem) {
                                return _SideMenuItem(
                                  key: child.key,
                                  icon: child.icon,
                                  title: child.title,
                                  routeName: child.routeName,
                                  isSelected: child.isSelected,
                                  isEnabled: child.isEnabled,
                                  isCollapsed: widget.isCollapsed, // Pass collapsed state
                                  onTabSelected: child.onTabSelected,
                                  tabIndex: child.tabIndex,
                                  expandAnimation: widget.expandAnimation, // Pass parent animation
                                );
                              }
                              return child;
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Main Dashboard Side Menu Widget ---
class DashboardSideMenu extends StatefulWidget {
  final UserProfile? userProfile;
  final String? profilePictureUrl;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final bool isPhase2Complete;
  final ValueChanged<bool> onCollapseToggle;
  final bool isInitiallyCollapsed;
  final bool isDrawerMode; // NEW: Indicates if it's operating as a Drawer

  const DashboardSideMenu({
    super.key,
    this.userProfile,
    this.profilePictureUrl,
    required this.selectedTabIndex,
    required this.onTabSelected,
    this.isPhase2Complete = false,
    required this.onCollapseToggle,
    this.isInitiallyCollapsed = false,
    this.isDrawerMode = false, // Default to false (persistent sidebar)
  });

  @override
  State<DashboardSideMenu> createState() => _DashboardSideMenuState();
}

class _DashboardSideMenuState extends State<DashboardSideMenu> with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  bool _isCollapsed = false; // Internal state for collapsed/expanded

  final List<Offset> _backgroundParticles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    // If in drawer mode, force it to be expanded
    _isCollapsed = widget.isDrawerMode ? false : widget.isInitiallyCollapsed;

    _expandController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationMedium,
    );
    _expandAnimation = CurvedAnimation(parent: _expandController, curve: Curves.easeInOutCubic);

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // Slower animation for background
    )..repeat(reverse: true);
    _backgroundAnimation = CurvedAnimation(parent: _backgroundAnimationController, curve: Curves.linear);

    _generateParticles(50, _backgroundParticles);

    // Initial state of the animation controller based on _isCollapsed
    if (_isCollapsed) {
      _expandController.value = 0.0; // Fully collapsed
    } else {
      _expandController.value = 1.0; // Fully expanded
    }
  }

  void _generateParticles(int count, List<Offset> particleList) {
    for (int i = 0; i < count; i++) {
      particleList.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
      if (_isCollapsed) {
        _expandController.reverse();
      } else {
        _expandController.forward();
      }
    });
    widget.onCollapseToggle(_isCollapsed); // Notify parent of the change
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final authService = Provider.of<AuthService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context);

    final bool isPhase1Complete = profileService.userProfile?.isPhase1Complete ?? false;
    final bool isPhase2Complete = profileService.userProfile?.isPhase2Complete ?? false; // Corrected local variable name
    final bool isProfileFullyComplete = isPhase1Complete && isPhase2Complete;

    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color menuBackgroundColor = isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color unselectedItemColor = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color logoutButtonColor = AppConstants.errorColor; // Use error color for logout

    // Responsive width logic
    final double maxMenuWidth = AppConstants.dashboardSideMenuWidth;
    final double minMenuWidth = AppConstants.spacingXXL + AppConstants.paddingMedium; // Icon size + padding

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        // In drawer mode, width is always maxMenuWidth and it's never collapsed visually
        final double currentWidth = widget.isDrawerMode
            ? maxMenuWidth
            : minMenuWidth + (maxMenuWidth - minMenuWidth) * _expandAnimation.value;
        final bool isCurrentlyCollapsed = widget.isDrawerMode ? false : _expandAnimation.value < 0.5; // Visual check for collapsed state

        return Container(
          width: currentWidth,
          decoration: BoxDecoration(
            color: widget.isDrawerMode
                ? menuBackgroundColor.withOpacity(1.0) // Fully opaque in drawer mode
                : menuBackgroundColor, // Base color for persistent
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(5, 0),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated Background Painter
              Positioned.fill(
                child: CustomPaint(
                  painter: SideMenuBackgroundPainter(
                    _backgroundAnimation,
                    primaryColor,
                    secondaryColor,
                    _backgroundParticles,
                    AppConstants.spacingExtraSmall, // Particle size
                    widget.isDrawerMode, // Pass isDrawerMode to painter
                  ),
                ),
              ),
              // Overlay gradient for depth
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.isDrawerMode
                            ? menuBackgroundColor.withOpacity(1.0) // Fully opaque in drawer mode
                            : menuBackgroundColor.withOpacity(0.8),
                        widget.isDrawerMode
                            ? menuBackgroundColor.withOpacity(1.0) // Fully opaque in drawer mode
                            : menuBackgroundColor.withOpacity(0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              // Actual menu content
              Column(
                children: [
                  // Toggle Button (top right) - Only show for persistent sidebar, not for drawer
                  if (!widget.isDrawerMode)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingSmall),
                        child: IconButton(
                          icon: AnimatedRotation(
                            turns: isCurrentlyCollapsed ? 0.0 : 0.25, // Rotate 90 degrees when expanded
                            duration: AppConstants.animationDurationMedium,
                            child: Icon(
                              isCurrentlyCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                              color: textColor.withOpacity(0.7),
                              size: AppConstants.fontSizeLarge,
                            ),
                          ),
                          onPressed: _toggleCollapse,
                          tooltip: isCurrentlyCollapsed ? 'Expand Menu' : 'Collapse Menu',
                        ),
                      ),
                    ),
                  // Profile Header
                  _SideMenuProfileHeader(
                    userProfile: widget.userProfile,
                    profilePictureUrl: widget.profilePictureUrl,
                    expandAnimation: _expandAnimation,
                    isCollapsed: isCurrentlyCollapsed,
                  ),
                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // Dashboard
                        _SideMenuItem(
                          icon: Icons.dashboard_rounded,
                          title: 'Dashboard',
                          routeName: '/home',
                          isSelected: widget.selectedTabIndex == 0,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 0,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                        ),
                        // Discovery
                        _SideMenuItem(
                          icon: Icons.travel_explore_rounded,
                          title: 'Discovery',
                          routeName: '/discovery',
                          isSelected: widget.selectedTabIndex == 1,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 1,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                        ),
                        // Matches
                        _SideMenuItem(
                          icon: Icons.favorite_rounded,
                          title: 'Matches',
                          routeName: '/matches',
                          isSelected: widget.selectedTabIndex == 2,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 2,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                        ),
                        // News Feed
                        _SideMenuItem(
                          icon: Icons.rss_feed_rounded,
                          title: 'News Feed',
                          routeName: '/newsfeed',
                          isSelected: widget.selectedTabIndex == 3,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 3,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                        ),
                        // Daily Prompts
                        _SideMenuItem(
                          icon: Icons.lightbulb_outline_rounded,
                          title: 'Daily Prompts',
                          routeName: '/daily-prompts',
                          isSelected: widget.selectedTabIndex == 4,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 4,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                        ),
                        // Notifications
                        _SideMenuItem(
                          icon: Icons.notifications_rounded,
                          title: 'Notifications',
                          routeName: '/notifications',
                          isSelected: widget.selectedTabIndex == 5,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 5,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                        ),
                        // Profile Setup (Phase 1) - always visible for review
                        _SideMenuItem(
                          icon: Icons.account_circle_rounded,
                          title: 'Profile Setup',
                          routeName: '/profile_setup',
                          isSelected: widget.selectedTabIndex == 6,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 6,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                        ),
                        // Phase 2 Setup / Questionnaire (conditional visibility)
                        // This should be the 'ongoing questionnaire'
                        if (isPhase1Complete)
                          _SideMenuItem(
                            icon: Icons.quiz_rounded,
                            title: 'AI Questionnaire',
                            routeName: '/questionnaire', // New route for the ongoing questionnaire
                            isSelected: widget.selectedTabIndex == 7,
                            onTabSelected: widget.onTabSelected,
                            tabIndex: 7,
                            isCollapsed: isCurrentlyCollapsed,
                            expandAnimation: _expandAnimation,
                          ),
                        // Conditional Phase 2 Setup (if not complete)
                        if (isPhase1Complete && !isPhase2Complete)
                          _SideMenuItem(
                            icon: Icons.rocket_launch_rounded,
                            title: 'Complete Phase 2',
                            routeName: '/questionnaire-phase2', // Route for Phase 2 setup
                            isSelected: widget.selectedTabIndex == 8,
                            onTabSelected: widget.onTabSelected,
                            tabIndex: 8,
                            isCollapsed: isCurrentlyCollapsed,
                            expandAnimation: _expandAnimation,
                          ),

                        Divider(color: AppConstants.borderColor.withOpacity(0.2), height: AppConstants.spacingMedium),

                        // --- Categories with Dropdowns ---

                        // Friends & Events Category
                        _SideMenuCategoryItem(
                          title: 'Friends & Events',
                          icon: Icons.people_alt_rounded,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                          children: [
                            _SideMenuItem(
                              icon: Icons.event_note_rounded,
                              title: 'Local Events',
                              routeName: '/events',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.group_add_rounded,
                              title: 'Friends Match',
                              routeName: '/friends-match',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                          ],
                        ),

                        // Matching Insights Category
                        _SideMenuCategoryItem(
                          title: 'Matching Insights',
                          icon: Icons.insights_rounded,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                          children: [
                            _SideMenuItem(
                              icon: Icons.auto_awesome_rounded,
                              title: 'Compatibility Results',
                              routeName: '/compatibility-results',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.lightbulb_rounded,
                              title: 'Daily Personality Q',
                              routeName: '/daily-personality-question',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.sentiment_satisfied_alt_rounded,
                              title: 'Personality Quiz',
                              routeName: '/personality-quiz',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                          ],
                        ),

                        // Date Management Category
                        _SideMenuCategoryItem(
                          title: 'Date Management',
                          icon: Icons.calendar_today_rounded,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                          children: [
                            _SideMenuItem(
                              icon: Icons.list_alt_rounded,
                              title: 'Scheduled Dates',
                              routeName: '/scheduled-dates-list',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.rate_review_rounded,
                              title: 'Post-Date Feedback',
                              routeName: '/post-date-feedback',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.date_range_rounded,
                              title: 'Date Proposals',
                              routeName: '/date-proposal',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                          ],
                        ),

                        // Info & Support Category
                        _SideMenuCategoryItem(
                          title: 'Info & Support',
                          icon: Icons.info_rounded,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                          children: [
                            _SideMenuItem(
                              icon: Icons.history_toggle_off_rounded,
                              title: 'Activity Feed',
                              routeName: '/activity-feed',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.block_rounded,
                              title: 'Blocked Users',
                              routeName: '/blocked-users',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.lightbulb_outline_rounded,
                              title: 'Date Ideas',
                              routeName: '/date-ideas',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.tour_rounded,
                              title: 'Guided Tour',
                              routeName: '/guided-tour',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.security_rounded,
                              title: 'Privacy Policy',
                              routeName: '/privacy',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.health_and_safety_rounded,
                              title: 'Safety Tips',
                              routeName: '/safety-tips',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.gavel_rounded,
                              title: 'Terms of Service',
                              routeName: '/terms',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.bar_chart_rounded,
                              title: 'User Progress',
                              routeName: '/user-progress',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.feedback_rounded,
                              title: 'Feedback',
                              routeName: '/feedback',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.report_rounded,
                              title: 'Report a Problem',
                              routeName: '/report',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.info_outline_rounded,
                              title: 'About Us',
                              routeName: '/about-us',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                          ],
                        ),

                        // Settings Category
                        _SideMenuCategoryItem(
                          title: 'Settings',
                          icon: Icons.settings_rounded,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                          children: [
                            _SideMenuItem(
                              icon: Icons.app_settings_alt_rounded,
                              title: 'App Settings',
                              routeName: '/app-settings',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.vpn_key_rounded,
                              title: 'Admin Dashboard',
                              routeName: '/admin',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.card_giftcard_rounded,
                              title: 'Referral Program',
                              routeName: '/referral',
                              isCollapsed: isCurrentlyCollapsed,
                              expandAnimation: _expandAnimation,
                            ),
                          ],
                        ),

                        Divider(color: AppConstants.borderColor.withOpacity(0.2), height: AppConstants.spacingMedium),

                        // Logout Button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingSmall,
                            vertical: AppConstants.paddingExtraSmall,
                          ),
                          child: AnimatedBuilder(
                            animation: _expandAnimation,
                            builder: (context, child) {
                              final double expandFactor = _expandAnimation.value;
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    await authService.signOut();
                                    if (mounted) {
                                      context.go('/login'); // Redirect to login after logout
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppConstants.paddingMedium,
                                      vertical: AppConstants.paddingSmall,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.logout_rounded,
                                          color: logoutButtonColor,
                                          size: AppConstants.fontSizeExtraLarge,
                                        ),
                                        SizedBox(width: AppConstants.spacingMedium * expandFactor),
                                        Expanded(
                                          child: ClipRect(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: expandFactor,
                                              child: Opacity(
                                                opacity: expandFactor,
                                                child: Text(
                                                  'Logout',
                                                  style: TextStyle(
                                                    color: logoutButtonColor,
                                                    fontSize: AppConstants.fontSizeMedium,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}