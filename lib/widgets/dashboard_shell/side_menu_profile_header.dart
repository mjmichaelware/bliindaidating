// lib/widgets/dashboard_shell/side_menu_profile_header.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile

/// Side Menu Profile Header (Enhanced)
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
    final themeController = Provider.of<ThemeController>(context);
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