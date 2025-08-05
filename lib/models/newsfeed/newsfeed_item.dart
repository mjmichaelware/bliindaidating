// lib/models/newsfeed/newsfeed_item.dart

import 'package:flutter/material.dart'; // Often needed for UI-related models, or remove if not.

/// Enum to define different types of newsfeed items.
enum NewsfeedItemType {
  general,
  match,
  profileUpdate,
  dailyPrompt,
  event,
  dateProposal,
  dateFeedback,
  adminMessage,
  // Add more types as needed
}

/// Represents a single item in the user's newsfeed.
class NewsfeedItem {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final NewsfeedItemType type;
  final String? relatedEntityId;
  
  // New fields to match the AI generated content structure
  final String? headline;
  final String? summary;
  final String? relatedUserId;

  NewsfeedItem({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    required this.type,
    this.relatedEntityId,
    // New fields
    this.headline,
    this.summary,
    this.relatedUserId,
  });

  // Factory constructor for creating a NewsfeedItem from a JSON map
  factory NewsfeedItem.fromJson(Map<String, dynamic> json) {
    return NewsfeedItem(
      // The backend doesn't provide these, so we'll use placeholder or mock data
      id: json['id'] as String? ?? 'temp-${json.hashCode}', 
      title: json['headline'] as String? ?? 'News Feed Item',
      content: json['summary'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      timestamp: DateTime.now(),
      type: NewsfeedItemType.general,
      relatedEntityId: json['related_user_id'] as String?,
      // Map new fields
      headline: json['headline'] as String?,
      summary: json['summary'] as String?,
      relatedUserId: json['related_user_id'] as String?,
    );
  }

  // Method for converting a NewsfeedItem to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'related_entity_id': relatedEntityId,
      'headline': headline,
      'summary': summary,
      'related_user_id': relatedUserId,
    };
  }
}