import 'package:flutter/material.dart';
import 'package:bliindaidating/shared/glowing_button.dart';
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';

class DashboardScreen extends StatelessWidget {
  final int totalDatesAttended;
  final int currentMatches;
  final int penaltyCount; // Number of big Xs

  const DashboardScreen({
    super.key,
    required this.totalDatesAttended,
    required this.currentMatches,
    required this.penaltyCount,
  });

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        // FIX: Replaced withOpacity with withAlpha
        color: Colors.deepPurple.shade900.withAlpha((255 * 0.75).round()),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // FIX: Replaced withOpacity with withAlpha
            color: Colors.red.shade900.withAlpha((255 * 0.6).round()),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 38, color: iconColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltySection(BuildContext context, int penaltyCount) {
    if (penaltyCount <= 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          // FIX: Replaced withOpacity with withAlpha
          color: Colors.deepPurple.shade800.withAlpha((255 * 0.7).round()),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 36),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'You have no penalties! Keep up the great cosmic harmony.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    // Show big red Xs equal to penalty count (capped for UI)
    int displayCount = penaltyCount.clamp(1, 10);

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        // FIX: Replaced withOpacity with withAlpha
        color: Colors.red.shade900.withAlpha((255 * 0.75).round()),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // FIX: Replaced withOpacity with withAlpha
            color: Colors.red.shade700.withAlpha((255 * 0.6).round()),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Penalty Alert: You have $penaltyCount date turn-down${penaltyCount > 1 ? 's' : ''}!',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: List.generate(displayCount, (index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Icon(Icons.close_rounded, color: Colors.white, size: 28),
            )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Dashboard',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          color: Colors.redAccent,
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Penalty section
                  _buildPenaltySection(context, penaltyCount),

                  // Stats cards
                  _buildStatCard(
                    label: 'Dates Attended',
                    value: '$totalDatesAttended',
                    icon: Icons.event_available_rounded,
                    iconColor: Colors.greenAccent.shade400,
                  ),

                  _buildStatCard(
                    label: 'Current Matches',
                    value: '$currentMatches',
                    icon: Icons.favorite_rounded,
                    iconColor: Colors.pink.shade400,
                  ),

                  Expanded(child: Container()),

                  GlowingButton(
                    icon: Icons.edit_rounded,
                    text: 'Edit Profile',
                    onPressed: () {
                      // Navigate to profile setup/edit screen
                      // GoRouter.of(context).go('/profileSetup'); // Using GoRouter for consistency
                    },
                    gradientColors: const [
                      Color(0xFF8E24AA),
                      Color(0xFFD32F2F),
                    ],
                    height: 48,
                    width: double.infinity,
                    // FIX: Replaced textSize with textStyle
                    textStyle: const TextStyle(fontSize: 18, color: Colors.white), // Added color for text
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
