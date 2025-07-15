// lib/models/newsfeed/newsfeed_item.dart

import 'package:flutter/material.dart'; // Often needed for UI-related models, or remove if not.

/// Enum to define different types of newsfeed items.
enum NewsfeedItemType {
  general,
  match, // Added
  profileUpdate, // Added
  dailyPrompt, // Added
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
  final String? imageUrl; // Added imageUrl
  final DateTime timestamp;
  final NewsfeedItemType type;
  final String? relatedEntityId; // ID of the related entity (e.g., match ID, prompt ID)

  NewsfeedItem({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl, // Made optional
    required this.timestamp,
    required this.type,
    this.relatedEntityId,
  });

  // Factory constructor for creating a NewsfeedItem from a JSON map
  factory NewsfeedItem.fromJson(Map<String, dynamic> json) {
    return NewsfeedItem(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?, // Map to 'image_url' from JSON
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: NewsfeedItemType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NewsfeedItemType.general, // Default to general if type not found
      ),
      relatedEntityId: json['related_entity_id'] as String?,
    );
  }

  // Method for converting a NewsfeedItem to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': imageUrl, // Map to 'image_url' for JSON
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'related_entity_id': relatedEntityId,
    };
  }
}