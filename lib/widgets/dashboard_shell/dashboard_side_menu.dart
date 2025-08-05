// lib/widgets/dashboard_shell/dashboard_side_menu.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/auth_service.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import all screens for GoRouter path lookup
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


final SupabaseClient supabaseClient = Supabase.instance.client;
final ProfileService profileService = ProfileService(supabaseClient);
final AuthService authService = AuthService(profileService);

// Side Menu Category Item
class SideMenuCategoryItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isCollapsed;
  final Animation<double> expandAnimation;
  final List<Widget> children;

  const SideMenuCategoryItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isCollapsed,
    required this.expandAnimation,
    required this.children,
  });

  @override
  State<SideMenuCategoryItem> createState() => _SideMenuCategoryItemState();
}

class _SideMenuCategoryItemState extends State<SideMenuCategoryItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final itemColor = isDarkMode ? AppConstants.textColor.withOpacity(0.9) : AppConstants.lightTextColor.withOpacity(0.9);
    final selectedItemColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingSmall,
              vertical: AppConstants.paddingExtraSmall,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.paddingMedium,
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: itemColor,
                  size: AppConstants.fontSizeLarge,
                ),
                Expanded(
                  child: AnimatedCrossFade(
                    duration: AppConstants.animationDurationMedium,
                    crossFadeState: widget.isCollapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Row(
                      children: [
                        const SizedBox(width: AppConstants.spacingMedium),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: itemColor,
                              fontSize: AppConstants.fontSizeMedium,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.25 : 0.0,
                          duration: AppConstants.animationDurationMedium,
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: itemColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: AppConstants.animationDurationMedium,
          crossFadeState: _isExpanded && !widget.isCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Column(children: widget.children),
        ),
      ],
    );
  }
}

// Side Menu Profile Header
class SideMenuProfileHeader extends StatelessWidget {
  final UserProfile? userProfile;
  final String? profilePictureUrl;
  final Animation<double> expandAnimation;
  final bool isCollapsed;

  const SideMenuProfileHeader({
    super.key,
    required this.userProfile,
    required this.profilePictureUrl,
    required this.expandAnimation,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
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


// Side Menu Item (Generic)
class SideMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isCollapsed;
  final bool showNotificationBadge;
  final int notificationCount;
  final bool isComingSoon;

  const SideMenuItem({
    super.key,
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
          color: isSelected ? selectedItemColor.withOpacity(0.2) : Colors.transparent,
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
      case 'Dashboard': return '/dashboard-overview';
      case 'Discovery': return '/discovery';
      case 'Matches': return '/matches';
      case 'Newsfeed': return '/newsfeed';
      case 'Daily Prompts': return '/daily-prompts';
      case 'Notifications': return '/notifications';
      case 'Profile Setup': return '/profile_setup';
      case 'AI Questionnaire': return '/questionnaire';
      case 'My Profile': return '/my-profile';
      case 'Scheduled Dates': return '/scheduled-dates-list';
      case 'Post-Date Feedback': return '/post-date-feedback';
      case 'Date Proposal': return '/date-proposal';
      case 'Compatibility Insights': return '/compatibility-results';
      case 'Daily Personality Question': return '/daily-personality-question';
      case 'Personality Quiz': return '/personality-quiz';
      case 'Local Events': return '/events';
      case 'Friends Match': return '/friends-match';
      case 'App Settings': return '/app-settings';
      case 'About Us': return '/about-us';
      case 'Privacy Policy': return '/privacy';
      case 'Terms & Conditions': return '/terms';
      case 'Feedback': return '/feedback';
      case 'Report User': return '/report';
      case 'Admin Dashboard': return '/admin';
      case 'Referral Program': return '/referral';
      case 'Activity Feed': return '/activity-feed';
      case 'Blocked Users': return '/blocked-users';
      case 'Date Ideas': return '/date-ideas';
      case 'Guided Tour': return '/guided-tour';
      case 'Safety Tips': return '/safety-tips';
      case 'User Progress': return '/user-progress';
      case 'Favorites': return '/favorites';
      case 'Match Display': return '/match-display';
      case 'Scheduled Date Details': return '/scheduled-date-details';
      default: return '';
    }
  }
}

// Main Side Menu Widget
class DashboardSideMenu extends StatelessWidget {
  final bool isCollapsed;
  final Animation<double> expandAnimation;
  final VoidCallback onToggleCollapse;
  final Widget profileHeader;
  final List<Widget> children;
  final bool isDrawerMode; // This parameter is now deprecated in this new design

  const DashboardSideMenu({
    super.key,
    required this.isCollapsed,
    required this.expandAnimation,
    required this.onToggleCollapse,
    required this.profileHeader,
    required this.children,
    this.isDrawerMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final dividerColor = isDarkMode ? AppConstants.borderColor : AppConstants.lightBorderColor;
    final textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;

    final Color backgroundColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightBackgroundColor;
    final double width = isCollapsed ? 80 : 250;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: width,
      child: Material(
        color: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            profileHeader,
            SideMenuItem(
              title: isCollapsed ? '' : 'Collapse Menu',
              icon: isCollapsed ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
              onTap: onToggleCollapse,
              isCollapsed: isCollapsed,
            ),
            Divider(color: dividerColor.withOpacity(0.5), height: 1),
            ...children,
            Divider(color: dividerColor.withOpacity(0.5), height: 1),
            SideMenuItem(
              icon: Icons.logout_rounded,
              title: 'Log Out',
              onTap: () async {
                await authService.signOut();
                if (context.mounted) {
                  context.go('/auth');
                }
              },
              isCollapsed: isCollapsed,
            ),
          ],
        ),
      ),
    );
  }
}