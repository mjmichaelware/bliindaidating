import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile
import 'package:bliindaidating/app_constants.dart'; // Import AppConstants for styling

class ProfileDiscoveryCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onLike;
  final bool isDarkMode;

  const ProfileDiscoveryCard({
    super.key,
    required this.profile,
    required this.onLike,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure interests is a non-nullable list for display purposes
    final List<String> interestsToDisplay = profile.hobbiesAndInterests ?? profile.interests ?? [];

    return GestureDetector(
      onTap: () {
        // Navigate to the full profile view screen
        context.push('/profile_view/${profile.userId}');
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        elevation: 8,
        shadowColor: isDarkMode ? Colors.black54 : Colors.grey.shade400,
        color: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Profile Picture
                  profile.profilePictureUrl != null && profile.profilePictureUrl!.isNotEmpty
                      ? Image.network(
                          profile.profilePictureUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.person,
                                size: 80,
                                color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor,
                          ),
                        ),
                  // Gradient Overlay for Text Readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            (isDarkMode ? Colors.black : Colors.black).withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Name and Age
                  Positioned(
                    bottom: AppConstants.paddingMedium,
                    left: AppConstants.paddingMedium,
                    right: AppConstants.paddingMedium,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName ?? profile.fullName ?? 'Unnamed User',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppConstants.textColor, // Always white on dark gradient
                          ),
                        ),
                        if (profile.dateOfBirth != null)
                          Text(
                            '${(DateTime.now().year - profile.dateOfBirth!.year)} years old',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: AppConstants.fontSizeSmall,
                              color: AppConstants.textLowEmphasis, // Lighter white
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Interests and Like Button
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (interestsToDisplay.isNotEmpty) // Use the non-nullable list
                    Text(
                      interestsToDisplay.join(', '), // Use the non-nullable list
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AppConstants.fontSizeSmall,
                        color: isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis,
                      ),
                    ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: onLike,
                      icon: Icon(Icons.favorite, color: AppConstants.textColor),
                      label: Text(
                        'Like Profile',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppConstants.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingSmall),
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
}