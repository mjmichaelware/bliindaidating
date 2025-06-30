import 'package:flutter/material.dart';
import 'package:bliindaidating/shared/glowing_button.dart';

class UpgradeToPremiumScreen extends StatelessWidget {
  const UpgradeToPremiumScreen({super.key});

  void _handleUpgrade(BuildContext context) {
    // TODO: Implement payment flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upgrade feature not implemented yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: Colors.deepPurple.shade900,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlock Premium Features',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Enjoy exclusive benefits such as:',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),

              const SizedBox(height: 16),

              ...[
                'See who favorited you',
                'Access premium-only events',
                'Get “Spotlight Me” profile boost',
                'Unlock advanced compatibility insights',
                'Priority support and more',
              ].map((feature) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Colors.pinkAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const Spacer(),

              GlowingButton(
                icon: Icons.upgrade_rounded,
                text: 'Upgrade Now',
                onPressed: () => _handleUpgrade(context),
                gradientColors: const [
                  Color(0xFF8E24AA),
                  Color(0xFFD32F2F),
                ],
                height: 52,
                width: double.infinity,
                textStyle: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
