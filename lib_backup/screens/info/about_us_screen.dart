import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize?.width < 600;

    final TextStyle headingStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.bold,
      fontSize: isSmallScreen ? 24 : 32,
      color: Theme.of(context).colorScheme.primary,
    );

    final TextStyle bodyStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: isSmallScreen ? 16 : 18,
      height: 1.6,
      color: Colors.white70,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Our Mission', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'At Blind AI Dating, we believe that love transcends the superficial. '
              'Our mission is to create a safe, compassionate platform where meaningful connections can blossom—beyond looks, beyond first impressions. '
              'We leverage intelligent AI to help you discover the heart and soul beneath the surface, fostering relationships based on authenticity, trust, and deep compatibility.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Divider(color: Colors.white24),
            const SizedBox(height: 24),

            Text('Why We Exist', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'The modern dating landscape can be exhausting — a whirlwind of swipes, appearances, and fleeting interactions. '
              'We exist to change that narrative by shifting the focus to what truly matters: the connection of minds, hearts, and spirits. '
              'Our AI is designed to understand your values, personality, and desires, helping you find genuine companionship in an often superficial world.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('Our Core Values', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              '• Authenticity: Embrace your true self; no filters, no masks.\n'
              '• Compassion: Build connections with empathy and kindness.\n'
              '• Privacy: Your personal journey is sacred and secure.\n'
              '• Innovation: Using cutting-edge AI to foster deeper understanding.\n'
              '• Community: Cultivating a respectful and supportive environment.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('How We Work', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'Our platform gently guides you through personalized interactions and thought-provoking prompts. '
              'Unlike traditional dating apps, we do not rely on appearance-based swiping or superficial filters. Instead, our AI listens to your story, your values, and your heart’s voice to introduce you to truly compatible matches.',
              style: bodyStyle,
            ),
            const SizedBox(height: 32),

            Center(
              child: Icon(Icons.auto_awesome_rounded,
                  color: Theme.of(context).colorScheme.secondary, size: 48),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Ready to discover your true connection?',
                style: headingStyle.copyWith(fontSize: isSmallScreen ? 20 : 26),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
