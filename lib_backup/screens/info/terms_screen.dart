import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
        title: const Text('Terms & Conditions'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome to Blind AI Dating', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'By using our app, you agree to these Terms and Conditions and our Privacy Policy. Please read them carefully. If you do not agree, please discontinue use immediately.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('Eligibility', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'You must be at least 18 years old to use this app. By using our service, you confirm you meet this requirement.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('User Conduct', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'You agree to use the platform respectfully and responsibly. Prohibited behaviors include harassment, fraud, impersonation, and any illegal activity. We reserve the right to suspend or terminate accounts violating these rules.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('Content Ownership', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'Content you provide remains your property. By submitting content, you grant Blind AI Dating a limited license to display and distribute it as necessary to provide the service.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('Limitation of Liability', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'Our service is provided "as is." We make no guarantees regarding matches or outcomes and are not liable for any damages resulting from use.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('Termination', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'We may terminate or suspend access for violations of terms or harmful conduct without prior notice.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            Text('Modifications to Terms', style: headingStyle),
            const SizedBox(height: 12),
            Text(
              'We reserve the right to update these terms at any time. Continued use after changes means acceptance.',
              style: bodyStyle,
            ),
            const SizedBox(height: 32),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder for downloading full PDF or opening external link
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
                child: const Text('Download Full Terms (PDF)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
