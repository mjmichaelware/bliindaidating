// lib/models/newsfeed/newsfeed_item.dart

enum NewsfeedItemType {
  matchAnnouncement,
  eventAnnouncement,
  aiTip,
  userPost,
  successStory,
}

class NewsfeedItem {
  final String id;
  final NewsfeedItemType type;
  final DateTime timestamp;
  final String? title;
  final String? content;
  final String? username;
  final String? avatarUrl;
  final String? matchUsername;
  final String? location;
  final String? eventName;
  final DateTime? eventDate;
  final String? eventLocation;
  final String? partnerName;
  
  // A new property to hold the headline
  final String? headline; 
  // A new property to hold the summary
  final String? summary;
  // A new property to hold the image URL
  final String? imageUrl;

  NewsfeedItem({
    required this.id,
    required this.type,
    required this.timestamp,
    this.title,
    this.content,
    this.username,
    this.avatarUrl,
    this.matchUsername,
    this.location,
    this.eventName,
    this.eventDate,
    this.eventLocation,
    this.partnerName,
    this.headline, // Add headline to constructor
    this.summary, // Add summary to constructor
    this.imageUrl, // Add imageUrl to constructor
  });

  // Factory constructor to create a NewsfeedItem from a JSON map
  factory NewsfeedItem.fromJson(Map<String, dynamic> json) {
    return NewsfeedItem(
      id: json['id'] as String,
      type: NewsfeedItemType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NewsfeedItemType.userPost,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      title: json['title'] as String?,
      content: json['content'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      matchUsername: json['matchUsername'] as String?,
      location: json['location'] as String?,
      eventName: json['eventName'] as String?,
      eventDate: json['eventDate'] != null ? DateTime.parse(json['eventDate'] as String) : null,
      eventLocation: json['eventLocation'] as String?,
      partnerName: json['partnerName'] as String?,
      headline: json['headline'] as String?,
      summary: json['summary'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}