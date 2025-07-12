// lib/widgets/dashboard_shell/dashboard_side_menu.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile
import 'package:bliindaidating/services/auth_service.dart'; // Import AuthService for sign out
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService for completion status

// NO DIRECT SCREEN IMPORTS HERE. The DashboardSideMenu only needs to
// define the menu structure and navigate using GoRouter paths.
// The screens themselves are imported in main.dart.


class DashboardSideMenu extends StatelessWidget {
  final UserProfile? userProfile;
  final String? profilePictureUrl;
  // selectedTabIndex and onTabSelected are for internal tab views if MainDashboardScreen
  // uses a TabBar. If not, these can be removed and navigation will be purely via GoRouter.
  // For now, I'll keep them as they were in your provided code, assuming a potential tab integration.
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final bool isPhase2Complete; // Parameter to indicate if Phase 2 is complete

  const DashboardSideMenu({
    super.key,
    this.userProfile,
    this.profilePictureUrl,
    required this.selectedTabIndex,
    required this.onTabSelected,
    this.isPhase2Complete = false, // Default to false if not provided
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    final authService = Provider.of<AuthService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context); // Access ProfileService for profile completion

    // Use profileService's state for completion checks
    final bool isPhase1Complete = profileService.userProfile?.isPhase1Complete ?? false;
    final bool _isPhase2Complete = profileService.userProfile?.isPhase2Complete ?? false; // Use internal variable name to avoid conflict with parameter
    final bool isProfileFullyComplete = isPhase1Complete && _isPhase2Complete;


    // Using AppConstants for colors to make it immersive
    final Color menuBackgroundColor = isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color selectedItemColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color unselectedItemColor = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color dividerColor = isDarkMode ? AppConstants.borderColor.withOpacity(0.2) : AppConstants.lightBorderColor.withOpacity(0.5);
    final Color buttonColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;

    // Colors for the immersive DrawerHeader
    final Color headerBackgroundColor = isDarkMode ? AppConstants.primaryColorShade900 : AppConstants.lightPrimaryColorShade400; // Deep pink/light pink
    final Color headerTextColor = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color headerAccentColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;

    // Determine the display name
    final String displayName = userProfile?.displayName ?? userProfile?.fullName ?? 'User';

    return Container(
      width: AppConstants.dashboardSideMenuWidth, // Using constant for width
      decoration: BoxDecoration(
        color: menuBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Immersive User Profile Header Section (Drawer Header)
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [headerBackgroundColor, headerBackgroundColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: AppConstants.avatarRadius,
                  backgroundColor: headerAccentColor.withOpacity(0.2), // Use an accent color
                  backgroundImage: profilePictureUrl != null
                      ? NetworkImage(profilePictureUrl!)
                      : null,
                  child: profilePictureUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          size: AppConstants.avatarRadius * 1.2,
                          color: headerTextColor.withOpacity(0.7), // Lighter icon
                        )
                      : null,
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Text(
                  'Welcome, $displayName',
                  style: TextStyle(
                    color: headerTextColor, // Use header text color
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                // Directly go to My Profile screen for editing/full view
                TextButton(
                  onPressed: () {
                    // This is for the user to go to their profile and make changes
                    context.go('/my-profile'); // Correct route based on main.dart
                  },
                  child: Text(
                    'Manage My Profile', // Changed text for clarity
                    style: TextStyle(
                      color: headerAccentColor, // Use header accent color
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
          Divider(color: dividerColor, height: 1),

          // Navigation Items (using ListView for scrollability)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Top Level Items
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard Overview',
                  routeName: '/home', // Correct route based on main.dart
                ),

                // Discovery Category
                _buildExpansionTile(
                  context,
                  title: 'Discovery',
                  icon: Icons.search,
                  children: [
                    _buildDrawerItem(
                      context,
                      title: 'Discover People',
                      routeName: '/discovery', // Correct route for DiscoveryScreen
                      isEnabled: isProfileFullyComplete, // Enable only if profile is complete
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Suggested Profiles',
                      routeName: '/dashboard/suggested_profiles',
                      isEnabled: isProfileFullyComplete,
                    ),
                  ],
                ),

                // Matches & Connections Category
                _buildExpansionTile(
                  context,
                  title: 'Matches & Connections',
                  icon: Icons.favorite,
                  children: [
                    _buildDrawerItem(
                      context,
                      title: 'My Matches',
                      routeName: '/matches', // Correct route for MatchesListScreen
                      isEnabled: isProfileFullyComplete,
                    ),
                    // Removed: 'Match Insights', 'Date Proposals' as their screens do not exist in tree
                    _buildDrawerItem(
                      context,
                      title: 'Penalty Status',
                      routeName: '/penalties', // Correct route for PenaltyDisplayScreen
                      isEnabled: isProfileFullyComplete,
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Compatibility Results',
                      routeName: '/dashboard/compatibility_results',
                      isEnabled: isProfileFullyComplete,
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'My Favorites',
                      routeName: '/favorites/list',
                      isEnabled: isProfileFullyComplete,
                    ),
                  ],
                ),

                // News Feed (Direct Item)
                _buildDrawerItem(
                  context,
                  icon: Icons.article_rounded,
                  title: 'News Feed',
                  routeName: '/newsfeed',
                  // `onTabSelected` logic (if News Feed is a main tab in the dashboard shell)
                  isSelected: selectedTabIndex == 0,
                  onTap: () {
                    context.go('/newsfeed');
                    onTabSelected(0);
                  },
                  isDarkMode: isDarkMode,
                  isEnabled: isProfileFullyComplete,
                ),

                // Daily Engagement Category
                _buildExpansionTile(
                  context,
                  title: 'Daily Engagement',
                  icon: Icons.quiz,
                  children: [
                    _buildDrawerItem(
                      context,
                      title: 'Daily Prompts',
                      routeName: '/daily/prompts',
                      isEnabled: isProfileFullyComplete,
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Daily Personality Question',
                      routeName: '/dashboard/daily_personality_question',
                      isEnabled: isProfileFullyComplete,
                    ),
                    _buildDrawerItem(
                      context,
                      // The "Questionnaire" from your list maps to Phase 2 Setup
                      title: 'Questionnaire', // Renamed from "Questions"
                      routeName: '/questionnaire-phase2', // Correct route for Phase2SetupScreen
                      isEnabled: isPhase1Complete, // Enable if Phase 1 is done, as this is Phase 2
                    ),
                  ],
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  routeName: '/notifications',
                  isEnabled: isProfileFullyComplete,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.visibility_rounded, // Distinct icon for viewing profile as others see it
                  title: 'View Profile As Guest', // More descriptive label
                  routeName: '/profile/:userId', // Needs user ID. This is complex for a direct menu item.
                  // For a simplified direct link, maybe link to their own public profile view.
                  // If 'profile_view_screen.dart' is intended for *any* user's profile view,
                  // then '/my-profile' or '/profile/${authService.currentUser!.id}' should be used.
                  // For now, removing this direct link from side menu for simplicity, as it needs a dynamic ID.
                  // Instead, 'Manage My Profile' (which goes to /my-profile) is sufficient.
                  // Or we can add a placeholder like this:
                  isEnabled: false, // Default to false as it needs a dynamic ID
                ),

                // Friends & Events Category
                _buildExpansionTile(
                  context,
                  title: 'Friends & Events',
                  icon: Icons.people,
                  children: [
                    // Removed 'Friends Match' as friends_match_screen.dart does not exist
                    _buildDrawerItem(
                      context,
                      title: 'Local Events',
                      routeName: '/events', // Correct route for LocalEventsScreen
                      isEnabled: isProfileFullyComplete,
                    ),
                  ],
                ),

                // Premium Category
                _buildExpansionTile(
                  context,
                  title: 'Premium',
                  icon: Icons.star,
                  children: [
                    // Removed 'Premium Membership' as premium_membership_screen.dart does not exist
                    _buildDrawerItem(
                      context,
                      title: 'Referral Program',
                      routeName: '/premium/referral',
                      isEnabled: true, // Generally accessible
                    ),
                  ],
                ),

                // Help & Support Category
                _buildExpansionTile(
                  context,
                  title: 'Help & Support',
                  icon: Icons.help,
                  children: [
                    _buildDrawerItem(
                      context,
                      title: 'Send Feedback',
                      routeName: '/feedback', // Correct route
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Report User',
                      routeName: '/report', // Correct route
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Safety Tips',
                      routeName: '/info/safety_tips',
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Guided Tour',
                      routeName: '/info/guided_tour',
                    ),
                  ],
                ),

                // Information Category
                _buildExpansionTile(
                  context,
                  title: 'Information',
                  icon: Icons.info,
                  children: [
                    _buildDrawerItem(
                      context,
                      title: 'About Us',
                      routeName: '/about-us', // Correct route
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Terms & Conditions',
                      routeName: '/terms', // Correct route
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Privacy Policy',
                      routeName: '/privacy', // Correct route
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Date Ideas',
                      routeName: '/info/date_ideas',
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Activity Feed',
                      routeName: '/info/activity_feed',
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'User Progress',
                      routeName: '/info/user_progress',
                    ),
                  ],
                ),

                // Settings (Direct Link to hub screen)
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  routeName: '/settings', // Correct route
                ),

                // REMOVED: Conditional Admin Dashboard button - as requested.
                // If you need admin functionality, it should be placed in a screen accessible only
                // after verifying admin status within that screen's logic or router guard.
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: ElevatedButton.icon(
              onPressed: () async {
                // No need to pass context here
                await authService.signOut(); // <--- CORRECTED THIS LINE
                if (context.mounted) {
                  // Ensure context is still valid before navigating
                  context.go('/login'); // Redirect to login after sign out
                }
              },
              icon: Icon(Icons.logout_rounded, color: textColor),
              label: Text(
                'Logout',
                style: TextStyle(
                  color: textColor,
                  fontSize: AppConstants.fontSizeMedium,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: textColor,
                minimumSize: const Size(double.infinity, 50), // Full width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                elevation: 5,
                shadowColor: buttonColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for building a regular ListTile menu item
  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    IconData? icon,
    required String routeName,
    bool isEnabled = true, // Default to enabled
    bool isSelected = false, // Default to not selected
    VoidCallback? onTap, // Optional onTap for specific actions (like tab selection)
    bool isDarkMode = false, // Pass dark mode for consistent styling
  }) {
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color selectedItemColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color unselectedItemColor = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color disabledColor = isDarkMode ? AppConstants.textLowEmphasis.withOpacity(0.3) : AppConstants.lightTextLowEmphasis.withOpacity(0.3);

    return AnimatedContainer(
      duration: AppConstants.animationDurationShort,
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSmall,
        vertical: AppConstants.paddingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: isSelected && isEnabled // Only apply selected color if enabled
            ? selectedItemColor.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: isSelected && isEnabled
            ? Border.all(color: selectedItemColor.withOpacity(0.5), width: 1.0)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled
              ? () {
                  Navigator.of(context).pop(); // Close the drawer
                  if (onTap != null) {
                    onTap(); // Call specific onTap if provided (e.g., for tab change)
                  } else {
                    context.go(routeName); // Default navigation via go_router
                  }
                }
              : null, // Disable tap if not enabled
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isEnabled
                      ? (isSelected ? selectedItemColor : unselectedItemColor)
                      : disabledColor,
                  size: AppConstants.fontSizeExtraLarge,
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Text(
                  title,
                  style: TextStyle(
                    color: isEnabled
                        ? (isSelected ? textColor : unselectedItemColor)
                        : disabledColor,
                    fontSize: AppConstants.fontSizeMedium,
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for building an ExpansionTile menu item
  Widget _buildExpansionTile(BuildContext context,
      {required String title, IconData? icon, required List<Widget> children}) {
    // Determine the text and icon colors based on the theme
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    final Color unselectedItemColor = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;

    return Theme( // Use Theme to override ListTileThemeData for ExpansionTile
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent, // Remove default ExpansionTile divider
        listTileTheme: ListTileThemeData(
          iconColor: unselectedItemColor, // Default icon color for expansion tile header
          textColor: textColor, // Default text color for expansion tile header
          selectedColor: AppConstants.secondaryColor, // Color when expanded/selected
          minLeadingWidth: AppConstants.fontSizeExtraLarge, // Align leading icon size
        ),
      ),
      child: ExpansionTile(
        leading: icon != null ? Icon(icon) : null,
        title: Text(
          title,
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontFamily: 'Inter',
            fontWeight: FontWeight.normal,
            color: textColor,
          ),
        ),
        children: children,
      ),
    );
  }
}