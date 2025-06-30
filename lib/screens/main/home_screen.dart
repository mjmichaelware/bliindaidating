import 'package:flutter/material.dart';
import 'package:bliindaidating/shared/glowing_button.dart';
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final String userName = "Michael";
  final String userStatus = "Exploring new cosmic connections";
  final String userProfilePic = "assets/images/user_avatar.png";

  final List<Map<String, String>> featuredMatches = [
    {
      'name': 'Isabel',
      'age': '28',
      'location': 'Salt Lake City',
      'image': 'assets/images/match1.png',
    },
    {
      'name': 'Rafa',
      'age': '32',
      'location': 'Denver',
      'image': 'assets/images/match2.png',
    },
    {
      'name': 'Jaz',
      'age': '26',
      'location': 'Phoenix',
      'image': 'assets/images/match3.png',
    },
  ];

  final List<Map<String, String>> upcomingEvents = [
    {
      'title': 'Coffee Date with Isabel',
      'date': 'July 1, 7:00 PM',
      'location': 'Downtown Cafe',
    },
    {
      'title': 'Hiking Adventure',
      'date': 'July 3, 9:00 AM',
      'location': 'Big Mountain Trail',
    },
  ];

  final List<Map<String, String>> datingTips = [
    {
      'title': 'Build Trust with Open Communication',
      'content': 'Honesty is the cornerstone of meaningful relationships. Share your feelings openly and listen actively.',
    },
    {
      'title': 'Embrace Your Authentic Self',
      'content': 'The right person will love you for who you truly are, not for who you pretend to be.',
    },
  ];

  int _currentTipIndex = 0;

  late final AnimationController _tipFadeController;
  late final Animation<double> _tipFadeAnimation;

  @override
  void initState() {
    super.initState();
    _tipFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _tipFadeAnimation = CurvedAnimation(parent: _tipFadeController, curve: Curves.easeInOut);
    _tipFadeController.forward();
  }

  @override
  void dispose() {
    _tipFadeController.dispose();
    super.dispose();
  }

  void _nextTip() async {
    await _tipFadeController.reverse();
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % datingTips.length;
    });
    await _tipFadeController.forward();
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade800.withOpacity(0.9), Colors.red.shade700.withOpacity(0.9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.shade900.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 34),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(Map<String, String> match) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade900.withOpacity(0.85), Colors.purple.shade700.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade900.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              match['image']!,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${match['name']}, ${match['age']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      match['location']!,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, String> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade900.withOpacity(0.8), Colors.deepPurple.shade700.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade800.withOpacity(0.45),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available_rounded, color: Colors.redAccent, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event['date']!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  event['location']!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatingTip(Map<String, String> tip) {
    return FadeTransition(
      opacity: _tipFadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700.withOpacity(0.85), Colors.purple.shade600.withOpacity(0.85)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade700.withOpacity(0.5),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tip['title']!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tip['content']!,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: _nextTip,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                child: const Text('Next Tip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 600;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 48 : 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header + profile info + edit button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundImage: AssetImage(userProfilePic),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, $userName!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              userStatus,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GlowingButton(
                        icon: Icons.edit_rounded,
                        text: 'Edit Profile',
                        onPressed: () {
                          // TODO: Navigate to profile setup
                        },
                        gradientColors: [Colors.purple.shade700, Colors.red.shade700],
                        height: 44,
                        width: 130,
                        textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Quick Actions
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildQuickAction(
                          icon: Icons.search_rounded,
                          label: 'Search',
                          onTap: () {
                            // TODO: Navigate to discovery
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.favorite_rounded,
                          label: 'Matches',
                          onTap: () {
                            // TODO: Navigate to matches
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.person_rounded,
                          label: 'Profile',
                          onTap: () {
                            // TODO: Navigate to profile
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Featured Matches
                  Text(
                    'Featured Matches',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredMatches.length,
                      itemBuilder: (_, i) => _buildMatchCard(featuredMatches[i]),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Upcoming Events
                  Text(
                    'Upcoming Dates & Events',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...upcomingEvents.map(_buildEventCard).toList(),

                  const SizedBox(height: 40),

                  // Daily Tip
                  Text(
                    'Daily Dating Tip',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDatingTip(datingTips[_currentTipIndex]),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

