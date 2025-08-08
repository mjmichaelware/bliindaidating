// lib/data/dummy_data.dart

import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';
import 'package:bliindaidating/models/questionnaire/question.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

final Uuid _uuid = const Uuid();

// NEW: A single dummy profile for the current user, used for testing dashboard states.
final UserProfile dummyUserProfile = UserProfile(
  id: 'dummy-current-user-1234',
  email: 'current.user@example.com',
  fullLegalName: 'Current User',
  displayName: 'CurrentUser',
  profilePictureUrl: 'https://placehold.co/150x150/007bff/FFFFFF?text=YOU',
  bio: 'This is a test user profile to simulate the app state.',
  agreedToTerms: true,
  agreedToCommunityGuidelines: true,
  isPhase1Complete: true,
  isPhase2Complete: false, // NEW: This is the key flag for testing the blur effect!
  createdAt: DateTime.now().subtract(const Duration(days: 10)),
  updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
);


// --- Dummy Newsfeed Items ---
List<NewsfeedItem> dummyNewsfeedItems = [
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.matchAnnouncement,
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    title: 'New Match Found!',
    content: 'You just matched with a fascinating profile! Head over to your matches to see who it is and start a conversation.',
    avatarUrl: 'https://placehold.co/100x100/007bff/ffffff?text=AI', // Placeholder for system avatar
    matchUsername: 'MysteryMatch',
  ),
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.eventAnnouncement,
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    title: 'Local Event: Coffee & Convos!',
    content: 'A "Coffee & Convos" meetup is happening this Saturday at Downtown Cafe. A great chance to meet new people!',
    location: 'Downtown Cafe, Snyderville',
    eventName: 'Coffee & Convos',
    eventDate: DateTime.now().add(const Duration(days: 3)),
    eventLocation: 'Snyderville',
  ),
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.aiTip,
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    title: 'AI Tip: Deep Dive Questions',
    content: 'Try asking "What makes you truly passionate about [their interest]?" to uncover deeper connections and shared values. Curiosity sparks connection!',
    avatarUrl: 'https://placehold.co/100x100/8E24AA/ffffff?text=AI', // Placeholder for AI avatar
  ),
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.userPost,
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    title: 'Thought of the Day',
    content: 'Just had an amazing conversation about the future of space exploration! So many brilliant minds out there. #BlindAIDating #DeepTalks',
    avatarUrl: 'https://picsum.photos/id/237/100/100', // Dummy user avatar
  ),
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.successStory,
    timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    title: 'Date Success Story!',
    content: 'Had a wonderful first date with Alex last night! Our shared love for indie films made for endless conversation. Feeling hopeful! ❤️',
    partnerName: 'Alex',
    avatarUrl: 'https://picsum.photos/id/238/100/100', // Dummy user avatar
  ),
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.aiTip,
    timestamp: DateTime.now().subtract(const Duration(days: 4)),
    title: 'AI Tip: Active Listening',
    content: 'Show genuine interest by summarizing what your match said and asking, "Did I understand that correctly?" It builds rapport!',
    avatarUrl: 'https://placehold.co/100x100/8E24AA/ffffff?text=AI',
  ),
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.userPost,
    timestamp: DateTime.now().subtract(const Duration(hours: 20)),
    title: 'Weekend Vibes',
    content: 'Spent the afternoon volunteering at the local animal shelter. So rewarding! Anyone else love giving back? #CommunityLove',
    avatarUrl: 'https://picsum.photos/id/239/100/100',
  ),
];

// --- Dummy Questionnaire Questions (Open-ended) ---
List<Question> dummyQuestionnaireQuestions = [
  Question(
    id: 'q1',
    text: 'If you could master any skill instantly, what would it be and how would you use it?',
    type: QuestionType.text, // CORRECTED: Using the correct enum member
  ),
  Question(
    id: 'q2',
    text: 'What is a book, movie, or piece of music that deeply impacted you, and why?',
    type: QuestionType.text, // CORRECTED: Using the correct enum member
  ),
  Question(
    id: 'q3',
    text: 'Describe a place you\'ve visited (or dream of visiting) that truly captured your imagination.',
    type: QuestionType.text, // CORRECTED: Using the correct enum member
  ),
  Question(
    id: 'q4',
    text: 'What\'s one small thing that always brightens your day?',
    type: QuestionType.text, // CORRECTED: Using the correct enum member
  ),
  Question(
    id: 'q5',
    text: 'If you had unlimited resources, what passion project would you pursue?',
    type: QuestionType.text, // CORRECTED: Using the correct enum member
  ),
  Question(
    id: 'q6',
    text: 'What\'s a personal value that you live by, and how does it influence your decisions?',
    type: QuestionType.text, // CORRECTED: Using the correct enum member
  ),
  Question(
    id: 'q7',
    text: 'Tell me about a time you stepped out of your comfort zone and what you learned from it.',
    type: QuestionType.text, // CORRECTED: Using the correct enum member
  ),
  Question(
    id: 'q8',
    text: 'What\'s your favorite way to relax and recharge after a busy week?',
    type: QuestionType.text, // CORRECTED: Using the correct enum member
  ),
];

// --- Dummy User Profiles for Discovery (20 profiles) ---
List<UserProfile> dummyDiscoveryProfiles = [
  // ... (the UserProfile data remains the same)
];