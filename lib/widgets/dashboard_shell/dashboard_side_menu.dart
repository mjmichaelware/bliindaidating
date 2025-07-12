import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile

class DashboardSideMenu extends StatelessWidget {
  final UserProfile? userProfile;
  final String? profilePictureUrl;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  // ADDED: Parameter to indicate if Phase 2 is complete
  final bool isPhase2Complete;


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

    return Container(
      width: 280, // Fixed width for the side menu
      color: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingExtraLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Section
          GestureDetector(
            onTap: () {
              context.go('/my-profile');
              debugPrint('Navigating to My Profile');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: AppConstants.avatarRadius,
                  backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
                  backgroundImage: profilePictureUrl != null
                      ? NetworkImage(profilePictureUrl!) as ImageProvider<Object>
                      : null,
                  child: profilePictureUrl == null
                      ? Icon(
                          Icons.account_circle,
                          size: AppConstants.avatarRadius * 1.2,
                          color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor,
                        )
                      : null,
                ),
                SizedBox(height: AppConstants.spacingMedium),
                Text(
                  'Welcome, ${userProfile?.displayName ?? userProfile?.fullName ?? 'User'}!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Inter',
                    color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  'View Profile',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontFamily: 'Inter',
                    color: isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.spacingExtraLarge),

          // Navigation Tabs
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildTabItem(
                  context,
                  icon: Icons.article_rounded,
                  title: 'Newsfeed',
                  index: 0,
                  isSelected: selectedTabIndex == 0,
                  onTap: () => onTabSelected(0),
                  isDarkMode: isDarkMode,
                ),
                _buildTabItem(
                  context,
                  icon: Icons.favorite_rounded,
                  title: 'My Matches',
                  index: 1,
                  isSelected: selectedTabIndex == 1,
                  onTap: () => onTabSelected(1),
                  isDarkMode: isDarkMode,
                ),
                _buildTabItem(
                  context,
                  icon: Icons.person_search_rounded,
                  title: 'Profile Discovery',
                  index: 2,
                  isSelected: selectedTabIndex == 2,
                  onTap: () => onTabSelected(2),
                  isDarkMode: isDarkMode,
                ),
                _buildTabItem(
                  context,
                  icon: Icons.quiz_rounded,
                  title: 'Questionnaire',
                  index: 3,
                  isSelected: selectedTabIndex == 3,
                  onTap: () => onTabSelected(3),
                  isDarkMode: isDarkMode,
                ),
                // NEW: Add Questionnaire Phase 2 link if Phase 2 is not complete
                if (!isPhase2Complete) // Only show if Phase 2 is NOT complete
                  _buildTabItem(
                    context,
                    icon: Icons.assignment_rounded, // A different icon for Phase 2 questions
                    title: 'Phase 2 Questions',
                    index: 4, // A new index for this item
                    isSelected: selectedTabIndex == 4,
                    onTap: () {
                      context.push('/questionnaire-phase2'); // Adjust this route as needed
                      onTabSelected(4);
                    },
                    isDarkMode: isDarkMode,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final Color itemColor = isSelected
        ? (isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor)
        : (isDarkMode ? AppConstants.textColor.withOpacity(0.8) : AppConstants.lightTextColor.withOpacity(0.8));
    final Color selectedBgColor = isDarkMode ? AppConstants.primaryColor.withOpacity(0.2) : AppConstants.lightPrimaryColor.withOpacity(0.2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        highlightColor: selectedBgColor,
        splashColor: selectedBgColor.withOpacity(0.5),
        child: AnimatedContainer(
          duration: AppConstants.animationDurationShort,
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            vertical: AppConstants.paddingSmall,
            horizontal: AppConstants.paddingMedium,
          ),
          decoration: BoxDecoration(
            color: isSelected ? selectedBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          ),
          child: Row(
            children: [
              Icon(icon, color: itemColor, size: AppConstants.fontSizeExtraLarge),
              SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Inter',
                    color: itemColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}