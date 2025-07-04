// lib/models/newsfeed/newsfeed_item.dart
enum NewsfeedItemType {
  dateSuccess,
  matchAnnounce,
  eventNearby,
  publicPost,
  aiTip,
  unknown,
}

class NewsfeedItem {
  final String id;
  final NewsfeedItemType type;
  final DateTime timestamp;
  final bool isPublic;
  final String content;
  final String? avatarUrl; // Optional for AI tips, etc.
  final String? username; // Optional for AI tips, etc.
  final String? location; // Optional for AI tips, etc.
  final String? title; // <--- ADDED THIS LINE: The missing 'title' field

  // Specific fields for different types
  final String? partnerName; // For date_success
  final String? matchUsername; // For match_announce
  final String? eventName; // For event_nearby
  final DateTime? eventDate; // For event_nearby
  final String? eventLocation; // For event_nearby

  NewsfeedItem({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.isPublic,
    required this.content,
    this.avatarUrl,
    this.username,
    this.location,
    this.partnerName,
    this.matchUsername,
    this.eventName,
    this.eventDate,
    this.eventLocation,
    this.title, // <--- ADDED TO CONSTRUCTOR
  });

  factory NewsfeedItem.fromJson(Map<String, dynamic> json) {
    NewsfeedItemType type;
    switch (json['type']) {
      case 'date_success':
        type = NewsfeedItemType.dateSuccess;
        break;
      case 'match_announce':
        type = NewsfeedItemType.matchAnnounce;
        break;
      case 'event_nearby':
        type = NewsfeedItemType.eventNearby;
        break;
      case 'public_post':
        type = NewsfeedItemType.publicPost;
        break;
      case 'ai_tip':
        type = NewsfeedItemType.aiTip;
        break;
      default:
        type = NewsfeedItemType.unknown;
    }

    return NewsfeedItem(
      id: json['id'] as String,
      type: type,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isPublic: (json['isPublic'] ?? true) as bool, // Default to true if not specified
      content: json['content'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      username: json['username'] as String?,
      location: json['location'] as String?,
      partnerName: json['partnerName'] as String?,
      matchUsername: json['matchUsername'] as String?,
      eventName: json['eventName'] as String?,
      eventDate: json['eventDate'] != null ? DateTime.parse(json['eventDate'] as String) : null,
      eventLocation: json['eventLocation'] as String?,
      title: json['title'] as String?, // <--- ADDED FROM JSON PARSING
    );
  }
}