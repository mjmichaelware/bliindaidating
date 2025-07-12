import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
        title: const Text('Privacy Policy'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Privacy, Protected.', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'At Blind AI Dating, we hold your privacy in the highest regard. Your personal information is yours alone, and we commit to protecting it with the utmost care.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('Information We Collect', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'We collect only the data necessary to provide and improve our services, including:\n'
              '• Profile information you provide, like preferences and responses\n'
              '• Device data, app usage statistics, and error reports\n'
              '• Location data only if you explicitly allow it\n'
              '• Cookies and similar technologies for app functionality',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('How We Use Your Information', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'Your information is used to:\n'
              '• Personalize and enhance your matchmaking experience\n'
              '• Analyze and improve app performance\n'
              '• Protect the community from abuse or fraud\n'
              '• Communicate important updates and support',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('Data Security', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'We use advanced encryption and security protocols to safeguard your data. Our team regularly audits systems and practices to prevent unauthorized access, loss, or misuse.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('Your Rights', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'You can access, update, or delete your personal information anytime by contacting our support team. You can also adjust your device settings to control data collection preferences.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('Third-Party Sharing', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'We do not sell, rent, or trade your personal data. We may share limited data with trusted service providers solely to operate and improve the platform, under strict confidentiality agreements.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('Cookies and Tracking Technologies', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'Our app uses cookies and similar technologies to enable functionality and collect anonymous analytics. These do not store personally identifiable information and can be disabled via your device settings.',
              style: bodyStyle,
            ),
            const SizedBox(height: 32),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder: open email or support contact
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
                child: const Text('Contact Our Privacy Team'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
