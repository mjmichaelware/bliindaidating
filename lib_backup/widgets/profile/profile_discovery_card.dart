import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Ensure UserProfile has needed fields
import 'dart:ui'; // For ImageFilter.blur

class ProfileDiscoveryCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onLike; // Callback for when the like button is pressed
  final bool isDarkMode; // To adapt UI based on theme

  const ProfileDiscoveryCard({
    super.key,
    required this.profile,
    required this.onLike,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // You'll need to ensure your UserProfile model has a profilePictureUrl and
    // properties for public info like bio, interests, pet ownership, etc.
    final String? profileImageUrl = profile.profilePictureUrl;
    final String displayName = profile.displayName ?? profile.fullName ?? 'Mysterious User';
    final String bio = profile.bio ?? 'This user has not provided a bio yet.';
    final List<String> interests = profile.interests;
    // Assuming UserProfile has properties like ownsPets, isSmoker, etc.
    // final bool ownsPets = profile.ownsPets ?? false;
    // final bool isSmoker = profile.isSmoker ?? false;

    return Card(
      color: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      elevation: 4,
      clipBehavior: Clip.antiAlias, // Ensures content is clipped to borderRadius
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Blurred Image
                profileImageUrl != null && (profileImageUrl ?? []).isNotEmpty
                    ? Image.network(
                        profileImageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppConstants.primaryColor,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.person, size: 80, color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.person, size: 80, color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor),
                      ),
                // Apply blur filter
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), // Adjust blur intensity
                  child: Container(
                    color: Colors.black.withOpacity(0.2), // Optional overlay for better blur visibility
                  ),
                ),
                // "Like" button (can be positioned more prominently or as an overlay)
                Positioned(
                  bottom: AppConstants.spacingSmall,
                  right: AppConstants.spacingSmall,
                  child: FloatingActionButton(
                    heroTag: 'like_btn_${profile.id}', // Unique tag for hero animation
                    onPressed: onLike,
                    backgroundColor: AppConstants.primaryColor,
                    child: Icon(Icons.favorite, color: Colors.white, size: AppConstants.fontSizeExtraLarge),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    bio, // Displaying bio as public info
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppConstants.spacingSmall),
                  // Display interests as chips
                  if ((interests ?? []).isNotEmpty)
                    Wrap(
                      spacing: AppConstants.spacingExtraSmall,
                      runSpacing: AppConstants.spacingExtraSmall,
                      children: interests.take(3).map((interest) => Chip(
                        label: Text(interest, style: TextStyle(fontSize: AppConstants.fontSizeSmall)),
                        backgroundColor: isDarkMode ? AppConstants.secondaryColor.withOpacity(0.2) : AppConstants.lightSecondaryColor.withOpacity(0.5),
                        labelStyle: TextStyle(color: isDarkMode ? AppConstants.secondaryColor : AppConstants.secondaryColorShade900),
                      )).toList(),
                    ),
                  // You can add more public info here conditionally, e.g.:
                  // if (profile.ownsPets == true)
                  //   Text('🐶 Pet Owner', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis)),
                  // if (profile.isSmoker == false)
                  //   Text('🚭 Non-Smoker', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}