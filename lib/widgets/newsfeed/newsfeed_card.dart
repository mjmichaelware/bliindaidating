// lib/widgets/newsfeed/newsfeed_card.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';

class NewsfeedCard extends StatelessWidget {
  final String content;

  const NewsfeedCard({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      color: AppConstants.cardColor, // Use a consistent color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}