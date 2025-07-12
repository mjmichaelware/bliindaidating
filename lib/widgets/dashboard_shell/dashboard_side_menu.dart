// lib/widgets/dashboard_shell/dashboard_side_menu.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile
import 'package:bliindaidating/services/auth_service.dart'; // Import AuthService for sign out

class DashboardSideMenu extends StatelessWidget {
  final UserProfile? userProfile;
  final String? profilePictureUrl;
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

    final Color menuBackgroundColor = isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color selectedItemColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color unselectedItemColor = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color dividerColor = isDarkMode ? AppConstants.borderColor.withOpacity(0.2) : AppConstants.lightBorderColor.withOpacity(0.5);
    final Color buttonColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;

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
          // User Profile Section
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                CircleAvatar(
                  radius: AppConstants.avatarRadius,
                  backgroundColor: selectedItemColor.withOpacity(0.2),
                  backgroundImage: profilePictureUrl != null
                      ? NetworkImage(profilePictureUrl!)
                      : null,
                  child: profilePictureUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          size: AppConstants.avatarRadius * 1.2,
                          color: unselectedItemColor,
                        )
                      : null,
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Text(
                  'Welcome, $displayName', // Correctly uses displayName
                  style: TextStyle(
                    color: textColor,
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                TextButton(
                  onPressed: () {
                    context.go('/my-profile'); // Correctly route to /my-profile
                  },
                  child: Text(
                    'View Profile',
                    style: TextStyle(
                      color: selectedItemColor,
                      fontSize: AppConstants.fontSizeSmall,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: dividerColor, height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  label: 'News Feed',
                  icon: Icons.article_rounded,
                  index: 0,
                  isSelected: selectedTabIndex == 0,
                  onTap: () => onTabSelected(0),
                  isDarkMode: isDarkMode,
                  isEnabled: true, // Always enabled
                ),
                _buildMenuItem(
                  context,
                  label: 'Matches',
                  icon: Icons.favorite_rounded,
                  index: 1,
                  isSelected: selectedTabIndex == 1,
                  onTap: () => onTabSelected(1),
                  isDarkMode: isDarkMode,
                  isEnabled: isPhase2Complete, // Enabled only if Phase 2 is complete
                ),
                _buildMenuItem(
                  context,
                  label: 'Discovery',
                  icon: Icons.explore_rounded,
                  index: 2,
                  isSelected: selectedTabIndex == 2,
                  onTap: () => onTabSelected(2),
                  isDarkMode: isDarkMode,
                  isEnabled: isPhase2Complete, // Enabled only if Phase 2 is complete
                ),
                _buildMenuItem(
                  context,
                  label: 'Questionnaire',
                  icon: Icons.quiz_rounded,
                  index: 3,
                  isSelected: selectedTabIndex == 3,
                  onTap: () => onTabSelected(3),
                  isDarkMode: isDarkMode,
                  isEnabled: true, // Always enabled, as it's the entry point to Phase 2
                ),
                // Phase 2 Questions tab - always enabled, and routes directly
                _buildMenuItem(
                  context,
                  label: 'Phase 2 Questions',
                  icon: Icons.psychology_alt_rounded,
                  index: 4,
                  isSelected: selectedTabIndex == 4,
                  onTap: () {
                    context.go('/questionnaire-phase2'); // Use context.go for main tab navigation
                    onTabSelected(4);
                  },
                  isDarkMode: isDarkMode,
                  isEnabled: true, // Always enabled
                ),
                // Add more menu items as needed
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: ElevatedButton.icon(
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) {
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

  Widget _buildMenuItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
    required bool isEnabled,
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
        color: isSelected
            ? selectedItemColor.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: isSelected
            ? Border.all(color: selectedItemColor.withOpacity(0.5), width: 1.0)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null, // Disable tap if not enabled
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
                      : disabledColor, // Apply disabled color
                  size: AppConstants.fontSizeExtraLarge,
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled
                        ? (isSelected ? textColor : unselectedItemColor)
                        : disabledColor, // Apply disabled color
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
}