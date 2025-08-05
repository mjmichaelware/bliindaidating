// lib/widgets/newsfeed/newsfeed_card.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';

class NewsfeedCard extends StatelessWidget {
  final NewsfeedItem content;

  const NewsfeedCard({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      elevation: AppConstants.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.headline ?? 'News Item',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              content.summary ?? 'No summary available.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (content.imageUrl != null && content.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppConstants.paddingSmall),
                child: Image.network(content.imageUrl!),
              ),
          ],
        ),
      ),
    );
  }
}