import 'package:flutter/material.dart';

class SuggestedProfilesWidget extends StatefulWidget {
  const SuggestedProfilesWidget({super.key});

  @override
  State<SuggestedProfilesWidget> createState() => _SuggestedProfilesWidgetState();
}

class _SuggestedProfilesWidgetState extends State<SuggestedProfilesWidget> {
  // Simulated profiles data focusing on personality and public info
  final List<_Profile> profiles = List.generate(
    10,
    (index) => _Profile(
      id: index,
      name: 'User $index',
      age: 20 + index,
      personalityType: index % 3 == 0 ? 'INFJ' : 'ENFP',
      astrologySign: index % 2 == 0 ? 'Leo' : 'Sagittarius',
      hopesAndDreams: 'To travel the world and write a novel.',
      interests: ['Hiking', 'Jazz', 'Coffee', 'Reading'],
      compatibility: (70 + index * 2) % 100,
      isFavorited: false,
    ),
  );

  void _toggleFavorite(int id) {
    setState(() {
      final profile = profiles.firstWhere((p) => p.id == id);
      profile.isFavorited = !profile.isFavorited;
    });
  }

  Widget _buildInterestChips(List<String> interests) {
    return Wrap(
      spacing: 6,
      runSpacing: -4,
      children: interests.take(3).map((interest) {
        return Chip(
          label: Text(interest),
          labelStyle: const TextStyle(color: Colors.white),
          backgroundColor: Colors.deepPurple.shade700,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildProfileCard(_Profile profile) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade900.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name, Age, Favorite Button Row
          Row(
            children: [
              Expanded(
                child: Text(
                  '${profile.name}, ${profile.age}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  profile.isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: profile.isFavorited ? Colors.pink.shade400 : Colors.white70,
                  size: 28,
                ),
                onPressed: () => _toggleFavorite(profile.id),
                tooltip: profile.isFavorited ? 'Remove from favorites' : 'Add to favorites',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Personality Type and Astrology Sign
          Row(
            children: [
              _infoBadge('Personality', profile.personalityType),
              const SizedBox(width: 12),
              _infoBadge('Astrology', profile.astrologySign),
            ],
          ),

          const SizedBox(height: 16),

          // Hopes and Dreams snippet
          Text(
            'Hopes & Dreams:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.hopesAndDreams,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white60,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // Interests chips
          _buildInterestChips(profile.interests),

          const SizedBox(height: 20),

          // Compatibility badge and action button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _compatibilityBadge(profile.compatibility),

              ElevatedButton(
                onPressed: () {
                  // TODO: Trigger date proposal flow or view full personality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                  shadowColor: Colors.red.shade900,
                  minimumSize: const Size(120, 40),
                ),
                child: const Text('Propose Date'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade700,
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compatibilityBadge(int compatibility) {
    Color badgeColor;
    if (compatibility >= 80) {
      badgeColor = Colors.greenAccent.shade400;
    } else if (compatibility >= 50) {
      badgeColor = Colors.orangeAccent.shade400;
    } else {
      badgeColor = Colors.redAccent.shade400;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(
        'Compatibility: $compatibility%',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: profiles.length,
        itemBuilder: (context, index) => SizedBox(
          width: 300,
          child: _buildProfileCard(profiles[index]),
        ),
      ),
    );
  }
}

class _Profile {
  final int id;
  final String name;
  final int age;
  final String personalityType;
  final String astrologySign;
  final String hopesAndDreams;
  final List<String> interests;
  final int compatibility;
  bool isFavorited;

  _Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.personalityType,
    required this.astrologySign,
    required this.hopesAndDreams,
    required this.interests,
    required this.compatibility,
    this.isFavorited = false,
  });
}
