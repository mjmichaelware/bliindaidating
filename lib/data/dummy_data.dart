// lib/data/dummy_data.dart

import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';
import 'package:bliindaidating/models/questionnaire/question.dart'; // Ensure this path is correct and file exists
import 'package:bliindaidating/models/user_profile.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

final Uuid _uuid = const Uuid();

// --- Dummy Newsfeed Items ---
List<NewsfeedItem> dummyNewsfeedItems = [
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.matchAnnounce,
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    isPublic: true,
    title: 'New Match Found!',
    content: 'You just matched with a fascinating profile! Head over to your matches to see who it is and start a conversation.',
    username: 'BlindAI System',
    avatarUrl: 'https://placehold.co/100x100/007bff/ffffff?text=AI', // Placeholder for system avatar
    matchUsername: 'MysteryMatch',
  ),
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.eventNearby,
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    isPublic: true,
    title: 'Local Event: Coffee & Convos!',
    content: 'A "Coffee & Convos" meetup is happening this Saturday at Downtown Cafe. A great chance to meet new people!',
    username: 'Community Events',
    location: 'Downtown Cafe, Snyderville',
    eventName: 'Coffee & Convos',
    eventDate: DateTime.now().add(const Duration(days: 3)),
    eventLocation: 'Snyderville',
  ),
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.aiTip,
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    isPublic: true,
    title: 'AI Tip: Deep Dive Questions',
    content: 'Try asking "What makes you truly passionate about [their interest]?" to uncover deeper connections and shared values. Curiosity sparks connection!',
    username: 'BlindAI Assistant',
    avatarUrl: 'https://placehold.co/100x100/8E24AA/ffffff?text=AI', // Placeholder for AI avatar
  ),
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.publicPost,
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isPublic: true,
    title: 'Thought of the Day',
    content: 'Just had an amazing conversation about the future of space exploration! So many brilliant minds out there. #BlindAIDating #DeepTalks',
    username: 'CuriousExplorer',
    avatarUrl: 'https://picsum.photos/id/237/100/100', // Dummy user avatar
  ),
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.dateSuccess,
    timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    isPublic: true,
    title: 'Date Success Story!',
    content: 'Had a wonderful first date with Alex last night! Our shared love for indie films made for endless conversation. Feeling hopeful! ❤️',
    username: 'HappyDater',
    partnerName: 'Alex',
    avatarUrl: 'https://picsum.photos/id/238/100/100', // Dummy user avatar
  ),
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.aiTip,
    timestamp: DateTime.now().subtract(const Duration(days: 4)),
    isPublic: true,
    title: 'AI Tip: Active Listening',
    content: 'Show genuine interest by summarizing what your match said and asking, "Did I understand that correctly?" It builds rapport!',
    username: 'BlindAI Assistant',
    avatarUrl: 'https://placehold.co/100x100/8E24AA/ffffff?text=AI',
  ),
  NewsfeedItem(
    id: _uuid.v4(),
    type: NewsfeedItemType.publicPost,
    timestamp: DateTime.now().subtract(const Duration(hours: 20)),
    isPublic: true,
    title: 'Weekend Vibes',
    content: 'Spent the afternoon volunteering at the local animal shelter. So rewarding! Anyone else love giving back? #CommunityLove',
    username: 'KindHeart',
    avatarUrl: 'https://picsum.photos/id/239/100/100',
  ),
];

// --- Dummy Questionnaire Questions (Open-ended) ---
List<Question> dummyQuestionnaireQuestions = [
  Question(
    id: 'q1',
    text: 'If you could master any skill instantly, what would it be and how would you use it?',
    type: 'text_input',
  ),
  Question(
    id: 'q2',
    text: 'What is a book, movie, or piece of music that deeply impacted you, and why?',
    type: 'text_input',
  ),
  Question(
    id: 'q3',
    text: 'Describe a place you\'ve visited (or dream of visiting) that truly captured your imagination.',
    type: 'text_input',
  ),
  Question(
    id: 'q4',
    text: 'What\'s one small thing that always brightens your day?',
    type: 'text_input',
  ),
  Question(
    id: 'q5',
    text: 'If you had unlimited resources, what passion project would you pursue?',
    type: 'text_input',
  ),
  Question(
    id: 'q6',
    text: 'What\'s a personal value that you live by, and how does it influence your decisions?',
    type: 'text_input',
  ),
  Question(
    id: 'q7',
    text: 'Tell me about a time you stepped out of your comfort zone and what you learned from it.',
    type: 'text_input',
  ),
  Question(
    id: 'q8',
    text: 'What\'s your favorite way to relax and recharge after a busy week?',
    type: 'text_input',
  ),
];

// --- Dummy User Profiles for Discovery (20 profiles) ---
List<UserProfile> dummyDiscoveryProfiles = [
  // Profile 1
  UserProfile(
    userId: _uuid.v4(),
    email: 'user1@example.com',
    fullLegalName: 'Alice Wonderland', // New field, explicitly setting
    displayName: 'WonderAlice',
    profilePictureUrl: 'https://picsum.photos/id/1005/200/300',
    bio: 'An avid reader and aspiring writer, always looking for new stories and adventures. Loves deep conversations and exploring hidden cafes.',
    lookingFor: 'Long-term relationship',
    // NEW REQUIRED FIELDS:
    agreedToTerms: true,
    agreedToCommunityGuidelines: true,
    isPhase1Complete: true,
    isPhase2Complete: true,
    genderIdentity: 'Female', // RENAMED from 'gender'
    dateOfBirth: DateTime(1995, 3, 15),
    phoneNumber: '+15551234567',
    locationCity: 'Salt Lake City', // Added for completeness, inferred from zip
    locationState: 'UT', // Added for completeness, inferred from zip
    locationZipCode: '84101', // RENAMED from 'addressZip'
    hobbiesAndInterests: ['Books', 'Writing', 'Coffee', 'Philosophy', 'Hiking'], // Corrected to List<String>
    sexualOrientation: 'Straight',
    heightCm: 165.0, // RENAMED from 'height'
    // New Phase 2 fields (example values)
    governmentIdFrontUrl: 'https://example.com/id_alice_front.jpg',
    governmentIdBackUrl: 'https://example.com/id_alice_back.jpg',
    ethnicity: 'Caucasian',
    languagesSpoken: ['English', 'Spanish'], // Corrected to List<String>
    desiredOccupation: 'Writer',
    educationLevel: 'Master\'s Degree',
    loveLanguages: ['Quality Time', 'Words of Affirmation'], // Corrected to List<String>
    favoriteMedia: ['Dune', 'The Witcher', 'Studio Ghibli films'], // Corrected to List<String>
    maritalStatus: 'Single',
    hasChildren: false,
    wantsChildren: true,
    relationshipGoals: 'Build a family and travel the world',
    dealbreakers: ['Dishonesty', 'lack of ambition'], // Corrected to List<String>
    // Phase 3 fields (example values)
    religionOrSpiritualBeliefs: 'Spiritual but not religious',
    politicalViews: 'Liberal',
    diet: 'Vegetarian',
    smokingHabits: 'Never',
    drinkingHabits: 'Socially',
    exerciseFrequencyOrFitnessLevel: '3 times a week',
    sleepSchedule: 'Early bird',
    personalityTraits: ['Introverted', 'empathetic', 'curious'], // Corrected to List<String>
    willingToRelocate: true,
    monogamyVsPolyamoryPreferences: 'Monogamy',
    astrologicalSign: 'Pisces',
    attachmentStyle: 'Secure',
    communicationStyle: 'Direct and open',
    mentalHealthDisclosures: 'None',
    petOwnership: 'Dog owner',
    travelFrequencyOrFavoriteDestinations: 'Quarterly, prefer Asia',
    profileVisibilityPreferences: 'Public',
    pushNotificationPreferences: {'messages': true, 'matches': true, 'events': false},

    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    // Keeping deprecated fields for compatibility.
    fullName: 'Alice Wonderland',
    gender: 'Female',
    addressZip: '84101',
    interests: ['Books', 'Writing'], // Corrected to List<String>
    height: 165.0,
  ),
  // Profile 2
  UserProfile(
    userId: _uuid.v4(),
    email: 'user2@example.com',
    fullLegalName: 'Bob The Builder',
    displayName: 'BobBuilds',
    profilePictureUrl: 'https://picsum.photos/id/1006/200/300',
    bio: 'Passionate about building things, from software to furniture. Enjoys problem-solving and a good challenge. Loves indie music and quiet evenings.',
    lookingFor: 'Friendship',
    // NEW REQUIRED FIELDS:
    agreedToTerms: true,
    agreedToCommunityGuidelines: true,
    isPhase1Complete: true,
    isPhase2Complete: true,
    genderIdentity: 'Male',
    dateOfBirth: DateTime(1990, 7, 22),
    phoneNumber: '+15552345678',
    locationCity: 'Salt Lake City',
    locationState: 'UT',
    locationZipCode: '84102',
    hobbiesAndInterests: ['Coding', 'Woodworking', 'Indie Music', 'Gaming', 'Cooking'], // Corrected to List<String>
    sexualOrientation: 'Straight',
    heightCm: 180.0,
    // New Phase 2 fields
    governmentIdFrontUrl: 'https://example.com/id_bob_front.jpg',
    governmentIdBackUrl: 'https://example.com/id_bob_back.jpg',
    ethnicity: 'Asian',
    languagesSpoken: ['English', 'Japanese'], // Corrected to List<String>
    desiredOccupation: 'Software Engineer',
    educationLevel: 'Bachelor\'s Degree',
    loveLanguages: ['Acts of Service', 'Physical Touch'], // Corrected to List<String>
    favoriteMedia: ['Sci-fi movies', 'rock music'], // Corrected to List<String>
    maritalStatus: 'Divorced',
    hasChildren: true,
    wantsChildren: false,
    relationshipGoals: 'Meaningful connections',
    dealbreakers: ['Lack of humor', 'dishonesty'], // Corrected to List<String>
    // Phase 3 fields (example values)
    religionOrSpiritualBeliefs: 'None',
    politicalViews: 'Centrist',
    diet: 'Omnivore',
    smokingHabits: 'Occasionally',
    drinkingHabits: 'Often',
    exerciseFrequencyOrFitnessLevel: 'Daily',
    sleepSchedule: 'Night owl',
    personalityTraits: ['Extroverted', 'logical', 'adventurous'], // Corrected to List<String>
    willingToRelocate: false,
    monogamyVsPolyamoryPreferences: 'Monogamy',
    astrologicalSign: 'Cancer',
    attachmentStyle: 'Anxious-preoccupied',
    communicationStyle: 'Assertive',
    mentalHealthDisclosures: 'None',
    petOwnership: 'None',
    travelFrequencyOrFavoriteDestinations: 'Rarely, prefer US',
    profileVisibilityPreferences: 'Public',
    pushNotificationPreferences: {'messages': true, 'matches': false, 'events': true},

    createdAt: DateTime.now().subtract(const Duration(days: 45)),
    updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    // Keeping deprecated fields for compatibility
    fullName: 'Bob The Builder',
    gender: 'Male',
    addressZip: '84102',
    interests: ['Coding', 'Woodworking'], // Corrected to List<String>
    height: 180.0,
  ),
  // Profile 3
  UserProfile(
    userId: _uuid.v4(),
    email: 'user3@example.com',
    fullLegalName: 'Charlie Chaplin',
    displayName: 'SilentFilmFan',
    profilePictureUrl: 'https://picsum.photos/id/1008/200/300',
    bio: 'Old soul with a love for classic cinema and jazz. Enjoys long walks, photography, and exploring historical sites. Values authenticity.',
    lookingFor: 'Something open',
    // NEW REQUIRED FIELDS:
    agreedToTerms: true,
    agreedToCommunityGuidelines: true,
    isPhase1Complete: true,
    isPhase2Complete: true,
    genderIdentity: 'Male',
    dateOfBirth: DateTime(1988, 11, 30),
    phoneNumber: '+15553456789',
    locationCity: 'Salt Lake City',
    locationState: 'UT',
    locationZipCode: '84103',
    hobbiesAndInterests: ['Movies', 'Jazz Music', 'Photography', 'History', 'Walking'], // Corrected to List<String>
    sexualOrientation: 'Bisexual',
    heightCm: 175.0,
    // New Phase 2 fields (example values)
    governmentIdFrontUrl: 'https://example.com/id_charlie_front.jpg',
    governmentIdBackUrl: 'https://example.com/id_charlie_back.jpg',
    ethnicity: 'Hispanic',
    languagesSpoken: ['English', 'French'], // Corrected to List<String>
    desiredOccupation: 'Historian',
    educationLevel: 'Ph.D.',
    loveLanguages: ['Physical Touch', 'Quality Time'], // Corrected to List<String>
    favoriteMedia: ['Classic films', 'Jazz'], // Corrected to List<String>
    maritalStatus: 'Single',
    hasChildren: false,
    wantsChildren: false,
    relationshipGoals: 'Meaningful connection and intellectual companionship',
    dealbreakers: ['Superficiality'], // Corrected to List<String>
    // Phase 3 fields (example values)
    religionOrSpiritualBeliefs: 'Christian',
    politicalViews: 'Moderate',
    diet: 'Pescatarian',
    smokingHabits: 'Never',
    drinkingHabits: 'Rarely',
    exerciseFrequencyOrFitnessLevel: 'Walking daily',
    sleepSchedule: 'Flexible',
    personalityTraits: ['Calm', 'thoughtful', 'artistic'], // Corrected to List<String>
    willingToRelocate: true,
    monogamyVsPolyamoryPreferences: 'Monogamy',
    astrologicalSign: 'Sagittarius',
    attachmentStyle: 'Dismissive-avoidant',
    communicationStyle: 'Reserved',
    mentalHealthDisclosures: 'None',
    petOwnership: 'None',
    travelFrequencyOrFavoriteDestinations: 'Annually, prefer Europe',
    profileVisibilityPreferences: 'Friends Only',
    pushNotificationPreferences: {'messages': true, 'matches': true, 'events': true},

    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    // Keeping deprecated fields for compatibility
    fullName: 'Charlie Chaplin',
    gender: 'Male',
    addressZip: '84103',
    interests: ['Movies', 'Jazz Music'], // Corrected to List<String>
    height: 175.0,
  ),
  // Profile 4
  UserProfile(
    userId: _uuid.v4(),
    email: 'user4@example.com',
    fullLegalName: 'Diana Prince',
    displayName: 'WonderWoman',
    profilePictureUrl: 'https://picsum.photos/id/1011/200/300',
    bio: 'Fitness enthusiast and outdoor adventurer. Loves hiking, climbing, and anything that gets the adrenaline pumping. Seeks a partner in crime for life\'s adventures.',
    lookingFor: 'Long-term relationship',
    // NEW REQUIRED FIELDS:
    agreedToTerms: true,
    agreedToCommunityGuidelines: true,
    isPhase1Complete: true,
    isPhase2Complete: true,
    genderIdentity: 'Female',
    dateOfBirth: DateTime(1992, 9, 1),
    phoneNumber: '+15554567890',
    locationCity: 'Salt Lake City',
    locationState: 'UT',
    locationZipCode: '84104',
    hobbiesAndInterests: ['Fitness', 'Hiking', 'Climbing', 'Travel', 'Healthy Eating'], // Corrected to List<String>
    sexualOrientation: 'Straight',
    heightCm: 170.0,
    // New Phase 2 fields
    governmentIdFrontUrl: 'https://example.com/id_diana_front.jpg',
    governmentIdBackUrl: 'https://example.com/id_diana_back.jpg',
    ethnicity: 'Mixed',
    languagesSpoken: ['English'], // Corrected to List<String>
    desiredOccupation: 'Personal Trainer',
    educationLevel: 'Associate Degree',
    loveLanguages: ['Acts of Service', 'Physical Touch'], // Corrected to List<String>
    favoriteMedia: ['Action movies', 'pop music'], // Corrected to List<String>
    maritalStatus: 'Single',
    hasChildren: false,
    wantsChildren: true,
    relationshipGoals: 'Active partnership and adventure',
    dealbreakers: ['Laziness', 'negativity'], // Corrected to List<String>
    // Phase 3 fields
    religionOrSpiritualBeliefs: 'Atheist',
    politicalViews: 'Independent',
    diet: 'Keto',
    smokingHabits: 'Never',
    drinkingHabits: 'Rarely',
    exerciseFrequencyOrFitnessLevel: 'Daily',
    sleepSchedule: 'Consistent',
    personalityTraits: ['Energetic', 'confident', 'direct'], // Corrected to List<String>
    willingToRelocate: false,
    monogamyVsPolyamoryPreferences: 'Monogamy',
    astrologicalSign: 'Virgo',
    attachmentStyle: 'Secure',
    communicationStyle: 'Direct',
    mentalHealthDisclosures: 'None',
    petOwnership: 'Dog owner',
    travelFrequencyOrFavoriteDestinations: 'Annually, prefer mountains',
    profileVisibilityPreferences: 'Public',
    pushNotificationPreferences: {'messages': true, 'matches': true, 'events': false},

    createdAt: DateTime.now().subtract(const Duration(days: 25)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    // Keeping deprecated fields for compatibility
    fullName: 'Diana Prince',
    gender: 'Female',
    addressZip: '84104',
    interests: ['Fitness', 'Hiking'], // Corrected to List<String>
    height: 170.0,
  ),
  // Profile 5
  UserProfile(
    userId: _uuid.v4(),
    email: 'user5@example.com',
    fullLegalName: 'Eve Adams',
    displayName: 'GardenEve',
    profilePictureUrl: 'https://picsum.photos/id/1012/200/300',
    bio: 'Gardener by day, stargazer by night. Finds beauty in nature\'s smallest details. Loves quiet evenings, classical music, and a good cup of tea.',
    lookingFor: 'Friendship',
    // NEW REQUIRED FIELDS:
    agreedToTerms: true,
    agreedToCommunityGuidelines: true,
    isPhase1Complete: true,
    isPhase2Complete: true,
    genderIdentity: 'Female',
    dateOfBirth: DateTime(1985, 4, 20),
    phoneNumber: '+15555678901',
    locationCity: 'Salt Lake City',
    locationState: 'UT',
    locationZipCode: '84105',
    hobbiesAndInterests: ['Gardening', 'Astronomy', 'Classical Music', 'Tea', 'Nature'], // Corrected to List<String>
    sexualOrientation: 'Bisexual',
    heightCm: 160.0,
    // New Phase 2 fields
    governmentIdFrontUrl: 'https://example.com/id_eve_front.jpg',
    governmentIdBackUrl: 'https://example.com/id_eve_back.jpg',
    ethnicity: 'Caucasian',
    languagesSpoken: ['English'], // Corrected to List<String>
    desiredOccupation: 'Botanist',
    educationLevel: 'Bachelor\'s Degree',
    loveLanguages: ['Quality Time', 'Gifts'], // Corrected to List<String>
    favoriteMedia: ['Documentaries', 'instrumental music'], // Corrected to List<String>
    maritalStatus: 'Single',
    hasChildren: false,
    wantsChildren: false,
    relationshipGoals: 'Deep, intellectual connection',
    dealbreakers: ['Loud environments', 'superficiality'], // Corrected to List<String>
    // Phase 3 fields
    religionOrSpiritualBeliefs: 'Spiritual',
    politicalViews: 'Liberal',
    diet: 'Vegan',
    smokingHabits: 'Never',
    drinkingHabits: 'Rarely',
    exerciseFrequencyOrFitnessLevel: 'Yoga',
    sleepSchedule: 'Early to bed',
    personalityTraits: ['Calm', 'observant', 'creative'], // Corrected to List<String>
    willingToRelocate: false,
    monogamyVsPolyamoryPreferences: 'Monogamy',
    astrologicalSign: 'Taurus',
    attachmentStyle: 'Secure',
    communicationStyle: 'Gentle and thoughtful',
    mentalHealthDisclosures: 'None',
    petOwnership: 'Cat owner',
    travelFrequencyOrFavoriteDestinations: 'Rarely, prefer local parks',
    profileVisibilityPreferences: 'Public',
    pushNotificationPreferences: {'messages': true, 'matches': true, 'events': true},

    createdAt: DateTime.now().subtract(const Duration(days: 50)),
    updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    // Keeping deprecated fields for compatibility
    fullName: 'Eve Adams',
    gender: 'Female',
    addressZip: '84105',
    interests: ['Gardening', 'Astronomy'], // Corrected to List<String>
    height: 160.0,
  ),
  // Profile 6
  UserProfile(
    userId: _uuid.v4(),
    email: 'user6@example.com',
    fullLegalName: 'Frank Ocean',
    displayName: 'OceanVibes',
    profilePictureUrl: 'https://picsum.photos/id/1015/200/300',
    bio: 'Musician and a free spirit. Loves spending time by the ocean, composing melodies, and exploring new cultures through food. Looking for someone to share creative journeys with.',
    lookingFor: 'Casual dating',
    // NEW REQUIRED FIELDS:
    agreedToTerms: true,
    agreedToCommunityGuidelines: true,
    isPhase1Complete: true,
    isPhase2Complete: true,
    genderIdentity: 'Male',
    dateOfBirth: DateTime(1993, 8, 10),
    phoneNumber: '+15556789012',
    locationCity: 'Salt Lake City',
    locationState: 'UT',
    locationZipCode: '84106',
    hobbiesAndInterests: ['Music', 'Travel', 'Cooking', 'Beach', 'Culture'], // Corrected to List<String>
    sexualOrientation: 'Gay',
    heightCm: 178.0,
    // New Phase 2 fields
    governmentIdFrontUrl: 'https://example.com/id_frank_front.jpg',
    governmentIdBackUrl: 'https://example.com/id_frank_back.jpg',
    ethnicity: 'African American',
    languagesSpoken: ['English', 'Portuguese'], // Corrected to List<String>
    desiredOccupation: 'Musician',
    educationLevel: 'Some College',
    loveLanguages: ['Acts of Service', 'Words of Affirmation'], // Corrected to List<String>
    favoriteMedia: ['Soul music', 'documentaries'], // Corrected to List<String>
    maritalStatus: 'Single',
    hasChildren: false,
    wantsChildren: false,
    relationshipGoals: 'Creative partnership',
    dealbreakers: ['Close-mindedness', 'negativity'], // Corrected to List<String>
    // Phase 3 fields
    religionOrSpiritualBeliefs: 'None',
    politicalViews: 'Liberal',
    diet: 'Omnivore',
    smokingHabits: 'Never',
    drinkingHabits: 'Socially',
    exerciseFrequencyOrFitnessLevel: 'Occasionally',
    sleepSchedule: 'Flexible',
    personalityTraits: ['Creative', 'laid-back', 'empathetic'], // Corrected to List<String>
    willingToRelocate: true,
    monogamyVsPolyamoryPreferences: 'Open Relationship',
    astrologicalSign: 'Leo',
    attachmentStyle: 'Fearful-avoidant',
    communicationStyle: 'Indirect',
    mentalHealthDisclosures: 'Anxiety',
    petOwnership: 'None',
    travelFrequencyOrFavoriteDestinations: 'Frequent, prefer South America',
    profileVisibilityPreferences: 'Public',
    pushNotificationPreferences: {'messages': true, 'matches': true, 'events': true},

    createdAt: DateTime.now().subtract(const Duration(days: 35)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    // Keeping deprecated fields for compatibility
    fullName: 'Frank Ocean',
    gender: 'Male',
    addressZip: '84106',
    interests: ['Music', 'Travel'], // Corrected to List<String>
    height: 178.0,
  ),
  // Profile 7
  UserProfile(
    userId: _uuid.v4(),
    email: 'user7@example.com',
    fullLegalName: 'Grace Hopper',
    displayName: 'CodeGrace',
    profilePictureUrl: 'https://picsum.photos/id/1018/200/300',
    bio: 'Software engineer passionate about clean code and innovative solutions. Enjoys sci-fi, hiking, and a good cup of coffee. Always learning.',
    lookingFor: 'Long-term relationship',
    // NEW REQUIRED FIELDS:
    agreedToTerms: true,
    agreedToCommunityGuidelines: true,
    isPhase1Complete: true,
    isPhase2Complete: true,
    genderIdentity: 'Female',
    dateOfBirth: DateTime(1991, 1, 25),
    phoneNumber: '+15557890123',
    locationCity: 'Salt Lake City',
    locationState: 'UT',
    locationZipCode: '84107',
    hobbiesAndInterests: ['Technology', 'Coding', 'Sci-Fi', 'Hiking', 'Coffee'], // Corrected to List<String>
    sexualOrientation: 'Straight',
    heightCm: 168.0,
    // New Phase 2 fields
    governmentIdFrontUrl: 'https://example.com/id_grace_front.jpg',
    governmentIdBackUrl: 'https://example.com/id_grace_back.jpg',
    ethnicity: 'Asian',
    languagesSpoken: ['English', 'Mandarin'], // Corrected to List<String>
    desiredOccupation: 'Data Scientist',
    educationLevel: 'Master\'s Degree',
    loveLanguages: ['Acts of Service', 'Quality Time'], // Corrected to List<String>
    favoriteMedia: ['Sci-fi series', 'electronic music'], // Corrected to List<String>
    maritalStatus: 'Single',
    hasChildren: false,
    wantsChildren: false,
    relationshipGoals: 'Intellectual partnership and shared growth',
    dealbreakers: ['Resistance to learning', 'dishonesty'], // Corrected to List<String>
    // Phase 3 fields
    religionOrSpiritualBeliefs: 'Agnostic',
    politicalViews: 'Liberal',
    diet: 'Omnivore',
    smokingHabits: 'Never',
    drinkingHabits: 'Rarely',
    exerciseFrequencyOrFitnessLevel: 'Occasionally',
    sleepSchedule: 'Late to bed',
    personalityTraits: ['Analytical', 'curious', 'introverted'], // Corrected to List<String>
    willingToRelocate: false,
    monogamyVsPolyamoryPreferences: 'Monogamy',
    astrologicalSign: 'Aquarius',
    attachmentStyle: 'Secure',
    communicationStyle: 'Direct',
    mentalHealthDisclosures: 'None',
    petOwnership: 'None',
    travelFrequencyOrFavoriteDestinations: 'Rarely, prefer quiet getaways',
    profileVisibilityPreferences: 'Public',
    pushNotificationPreferences: {'messages': true, 'matches': true, 'events': true},

    createdAt: DateTime.now().subtract(const Duration(days: 20)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    // Keeping deprecated fields for compatibility
    fullName: 'Grace Hopper',
    gender: 'Female',
    addressZip: '84107',
    interests: ['Technology', 'Coding'], // Corrected to List<String>
    height: 168.0,
  ),
  // Add more dummy users as needed, ensuring all required fields are provided
  // and renamed fields are updated.
];