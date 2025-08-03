// lib/widgets/dashboard_shell/dashboard_side_menu.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math; // For math.pi and other math functions
import 'package:provider/provider.dart'; // Import Provider to access the ThemeController

import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile
import 'package:bliindaidating/services/auth_service.dart'; // Import AuthService for sign out
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService for completion status
import 'package:supabase_flutter/supabase_flutter.dart';

// NEW IMPORTS for all screens and categories to be linked
import 'package:bliindaidating/profile/profile_setup_screen.dart';
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart';
import 'package:bliindaidating/screens/discovery/discover_people_screen.dart';
import 'package:bliindaidating/screens/matches/matches_list_screen.dart';
import 'package:bliindaidating/screens/daily/daily_prompts_screen.dart';
import 'package:bliindaidating/screens/notifications/notifications_screen.dart';
import 'package:bliindaidating/screens/profile_setup/phase2_setup_screen.dart';
import 'package:bliindaidating/screens/questionnaire/questionnaire_screen.dart';
import 'package:bliindaidating/friends/local_events_screen.dart';
import 'package:bliindaidating/friends/friends_match_screen.dart';
import 'package:bliindaidating/friends/event_details_screen.dart';
import 'package:bliindaidating/screens/dashboard/compatibility_results_screen.dart';
import 'package:bliindaidating/screens/dashboard/daily_personality_question_screen.dart';
import 'package:bliindaidating/screens/quiz/personality_quiz_screen.dart';
import 'package:bliindaidating/screens/date/scheduled_dates_list_screen.dart';
import 'package:bliindaidating/screens/date/post_date_feedback_screen.dart';
import 'package:bliindaidating/matching/date_proposal_screen.dart';
import 'package:bliindaidating/screens/info/activity_feed_screen.dart';
import 'package:bliindaidating/screens/info/blocked_users_screen.dart';
import 'package:bliindaidating/screens/info/date_ideas_screen.dart';
import 'package:bliindaidating/screens/info/guided_tour_screen.dart';
import 'package:bliindaidating/screens/info/privacy_screen.dart';
import 'package:bliindaidating/screens/info/safety_tips_screen.dart';
import 'package:bliindaidating/screens/info/terms_screen.dart';
import 'package:bliindaidating/screens/info/user_progress_screen.dart';
import 'package:bliindaidating/screens/feedback_report/feedback_screen.dart';
import 'package:bliindaidating/screens/feedback_report/report_screen.dart';
import 'package:bliindaidating/screens/info/about_us_screen.dart';
import 'package:bliindaidating/screens/settings/app_settings_screen.dart';
import 'package:bliindaidating/screens/admin/admin_dashboard_screen.dart';
import 'package:bliindaidating/screens/premium/referral_screen.dart';
import 'package:bliindaidating/screens/profile/my_profile_screen.dart';
import 'package:bliindaidating/screens/favorites/favorites_list_screen.dart';
import 'package:bliindaidating/matching/match_display_screen.dart';
import 'package:bliindaidating/screens/date/scheduled_date_details_screen.dart';
import 'package:bliindaidating/screens/newsfeed/newsfeed_screen.dart';
import 'package:bliindaidating/screens/dashboard/dashboard_overview_screen.dart';

// We now create global instances using a singleton pattern for services,
// but ThemeController is managed by Provider.
final SupabaseClient supabaseClient = Supabase.instance.client;
final ProfileService profileService = ProfileService(supabaseClient);
final AuthService authService = AuthService(profileService);


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
    // We use Consumer to listen for changes to the ThemeController.
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        final isDarkMode = themeController.isDarkMode;
        final Color headerAccentColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
        final Color headerTextColor = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
        final Color onlineIndicatorColor = AppConstants.successColor;

        final String displayName = userProfile?.displayName ?? userProfile?.fullLegalName ?? 'Stellar Traveler';

        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.paddingLarge,
            horizontal: AppConstants.paddingMedium,
          ),
          child: Column(
            children: [
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
              AnimatedCrossFade(
                duration: AppConstants.animationDurationMedium,
                crossFadeState: isCollapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: Container(width: 0, height: 0),
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
      },
    );
  }
}


// --- Side Menu Item (Generic) ---
class _SideMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isCollapsed;
  final bool showNotificationBadge;
  final int notificationCount;
  final bool isComingSoon;

  const _SideMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isCollapsed = false,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    // We get the theme state from the Provider
    final isDarkMode = Provider.of<ThemeController>(context).isDarkMode;

    final itemColor = isDarkMode ? AppConstants.textColor.withOpacity(0.9) : AppConstants.lightTextColor.withOpacity(0.9);
    final selectedItemColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final badgeColor = AppConstants.errorColor;

    final bool isSelected = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath == _getPathFromTitle(title);
    return InkWell(
      onTap: isComingSoon ? null : onTap,
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
              firstChild: const SizedBox.shrink(),
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
        return '/profile_setup';
      case 'AI Questionnaire':
        return '/questionnaire';
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
      case 'App Settings':
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
      case 'Match Display':
        return '/match-display';
      case 'Scheduled Date Details':
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
  final bool isPhase2Complete;
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

    // The ThemeController is now managed by Provider, so we don't need
    // to add/remove listeners manually in initState/dispose for it.
    // However, we still need to listen to our other services if they
    // are not managed by a provider.
    profileService.addListener(_onServiceChange);
    authService.addListener(_onServiceChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    profileService.removeListener(_onServiceChange);
    authService.removeListener(_onServiceChange);
    super.dispose();
  }

  void _onServiceChange() {
    if (mounted) {
      setState(() {});
    }
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
    // We get the theme controller from the Provider.
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final dividerColor = isDarkMode ? AppConstants.borderColor : AppConstants.lightBorderColor;

    final bool isPhase1Complete = profileService.userProfile?.isPhase1Complete ?? false;
    final bool isPhase2Complete = profileService.userProfile?.isPhase2Complete ?? false;
    final bool isProfileFullyComplete = isPhase1Complete && isPhase2Complete;


    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final Color backgroundColor = isDarkMode
            ? primaryColor.withOpacity(widget.isDrawerMode ? 1.0 : 0.9)
            : AppConstants.lightBackgroundColor;

        return Drawer(
          width: widget.isDrawerMode ? MediaQuery.of(context).size.width * 0.75 : (_isCollapsed ? 80 : 250),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _SideMenuProfileHeader(
                  userProfile: profileService.userProfile,
                  profilePictureUrl: profileService.userProfile?.profilePictureUrl,
                  expandAnimation: _expandAnimation,
                  isCollapsed: _isCollapsed,
                ),
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
                  icon: Icons.quiz_rounded,
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
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.send_rounded,
                  title: 'Date Proposal',
                  onTap: () {
                    context.go('/date-proposal');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.lightbulb_rounded,
                  title: 'Date Ideas',
                  onTap: () {
                    context.go('/date-ideas');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                Divider(color: dividerColor.withOpacity(0.5), height: 1),

                // --- Friends & Events ---
                _SideMenuItem(
                  icon: Icons.people_alt_rounded,
                  title: 'Friends Match',
                  onTap: () {
                    context.go('/friends-match');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.event_note_rounded,
                  title: 'Local Events',
                  onTap: () {
                    context.go('/events');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                Divider(color: dividerColor.withOpacity(0.5), height: 1),

                // --- Info & Support ---
                _SideMenuItem(
                  icon: Icons.settings_rounded,
                  title: 'App Settings',
                  onTap: () {
                    context.go('/app-settings');
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
                  icon: Icons.security_rounded,
                  title: 'Privacy Policy',
                  onTap: () {
                    context.go('/privacy');
                    if (widget.isDrawerMode) Navigator.of(context).pop();
                  },
                  isCollapsed: _isCollapsed,
                ),
                _SideMenuItem(
                  icon: Icons.gavel_rounded,
                  title: 'Terms & Conditions',
                  onTap: () {
                    context.go('/terms');
                    if (widget.isDrawerMode) Navigator.of(context).pop();
                  },
                  isCollapsed: _isCollapsed,
                ),
                _SideMenuItem(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Safety Tips',
                  onTap: () {
                    context.go('/safety-tips');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.feedback_rounded,
                  title: 'Feedback',
                  onTap: () {
                    context.go('/feedback');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.report_rounded,
                  title: 'Report User',
                  onTap: () {
                    context.go('/report');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Admin Dashboard',
                  onTap: () {
                    context.go('/admin');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.card_giftcard_rounded,
                  title: 'Referral Program',
                  onTap: () {
                    context.go('/referral');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.history_rounded,
                  title: 'Activity Feed',
                  onTap: () {
                    context.go('/activity-feed');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.block_rounded,
                  title: 'Blocked Users',
                  onTap: () {
                    context.go('/blocked-users');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.star_rounded,
                  title: 'Favorites',
                  onTap: () {
                    context.go('/favorites');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.tour_rounded,
                  title: 'Guided Tour',
                  onTap: () {
                    context.go('/guided-tour');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.trending_up_rounded,
                  title: 'User Progress',
                  onTap: () {
                    context.go('/user-progress');
                  },
                  isCollapsed: _isCollapsed,
                  isComingSoon: true,
                ),
                _SideMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Log Out',
                  onTap: () async {
                    await authService.signOut();
                    if (mounted) {
                      context.go('/auth');
                    }
                  },
                  isCollapsed: _isCollapsed,
                ),
                // End of menu items
              ],
            ),
          ),
        );
      },
    );
  }
}
