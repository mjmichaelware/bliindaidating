// lib/screens/profile_setup/widgets/consent_form.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer

// Define the PolicyViewerDialog as a reusable widget
class PolicyViewerDialog extends StatelessWidget {
  final String title;
  final String content; // Content can be Markdown or plain text
  final bool isDarkMode;

  const PolicyViewerDialog({
    super.key,
    required this.title,
    required this.content,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;
    final cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;
    final activeColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;

    return AlertDialog(
      title: Text(title, style: textTheme.titleLarge?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: primaryTextColor)),
      backgroundColor: cardColor,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8, // Adjust width as needed
        height: MediaQuery.of(context).size.height * 0.6, // Adjust height
        constraints: const BoxConstraints(maxWidth: 800), // Max width for larger screens
        child: SingleChildScrollView(
          child: Text(
            content,
            style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: TextStyle(color: activeColor)),
        ),
      ],
    );
  }
}


class ConsentForm extends StatefulWidget {
  final bool agreedToTerms;
  final bool agreedToCommunityGuidelines;
  final Function(bool?) onTermsChanged;
  final Function(bool?) onCommunityGuidelinesChanged;
  final GlobalKey<FormState> formKey;

  const ConsentForm({
    super.key,
    required this.agreedToTerms,
    required this.agreedToCommunityGuidelines,
    required this.onTermsChanged,
    required this.onCommunityGuidelinesChanged,
    required this.formKey,
  });

  @override
  State<ConsentForm> createState() => _ConsentFormState();
}

class _ConsentFormState extends State<ConsentForm> {
  // Mock content for policies (in a real app, load from assets or backend)
  final String _termsContent = """
  ## Terms of Service for BliindAIDating

  Welcome to BliindAIDating! By accessing or using our service, you agree to be bound by these Terms of Service ("Terms"). Please read them carefully.

  **1. Acceptance of Terms:** By creating an account or using the BliindAIDating application, you signify that you have read, understood, and agree to be bound by these Terms, our Privacy Policy, and Community Guidelines. If you do not agree with any of these terms, you may not use the service.

  **2. Eligibility:** You must be at least 18 years old to use BliindAIDating. By using the service, you represent and warrant that you are 18 years of age or older and can form a binding contract with the Company.

  **3. Account Creation:** You agree to provide accurate, current, and complete information during the registration process and to update such information to keep it accurate, current, and complete. Your account is for your personal, non-commercial use only. You may not authorize others to use your account.

  **4. Privacy:** Your privacy is paramount. Please refer to our Privacy Policy for information on how we collect, use, and disclose information from our users.

  **5. AI Matching & Data Use:**
      * **Photo Analysis:** You consent to our AI analyzing your uploaded photo for facial features (e.g., golden ratio, symmetry) to generate a numerical score. This score is used **solely for matching compatibility** and is **never publicly displayed on your profile.**
      * **Profile Data:** The information you provide in your profile (e.g., bio, interests, preferences) may be used by our AI to learn your patterns and enhance match recommendations. You control the visibility of most of this data on your public profile via your settings.
      * **Learning:** Our AI learns from your interactions and profile data to continually improve its matching algorithms.

  **6. Community Guidelines:** You agree to adhere to our Community Guidelines, which prohibit harassment, hate speech, inappropriate content, and any unlawful activity. Violations may result in account suspension or termination.

  **7. Content You Post:** You are solely responsible for the content and information that you post, upload, publish, link to, transmit, record, display, or otherwise make available (hereinafter, "post") on the Service.

  **8. Safety & Security:** We implement security measures to protect your data, but no system is impenetrable. You are responsible for keeping your password confidential.

  **9. Termination:** We may terminate or suspend your access to the Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.

  **10. Disclaimers:** The Service is provided "as is" and "as available" without any warranties of any kind, either express or implied.

  **11. Limitation of Liability:** To the maximum extent permitted by applicable law, in no event shall the Company, its affiliates, agents, directors, employees, or suppliers be liable for any indirect, punitive, incidental, special, consequential, or exemplary damages.

  **12. Governing Law:** These Terms shall be governed by the laws of [Your State/Country], without regard to its conflict of law provisions.

  **13. Changes to Terms:** We reserve the right, at our sole discretion, to modify or replace these Terms at any time.

  **Contact Us:** If you have any questions about these Terms, please contact us at support@bliindaidating.com.

  ---
  """;

  final String _privacyContent = """
  ## Privacy Policy for BliindAIDating

  **Last Updated: July 2, 2025**

  BliindAIDating ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy describes how we collect, use, disclose, and safeguard your information when you use our mobile application or website (the "Service").

  **1. Information We Collect:**
      * **Personal Information You Provide:**
          * **Identity:** Full legal name, date of birth, gender identity, display name.
          * **Contact:** Email address, phone number, address/ZIP code.
          * **Profile Data:** Bio, height, sexual orientation, relationship preferences ("looking for"), interests, marital status, children preference, relocation willingness, monogamy/polyamory preference, love/relationship goals, dealbreakers/boundaries, astrological sign, attachment style, communication style, mental health disclosures, pet ownership, travel frequency/destinations, political views, religion/beliefs, diet, smoking/drinking habits, exercise frequency, sleep schedule, personality traits.
          * **Photos:** Face photo for AI analysis.
          * **Account Credentials:** Encrypted password.
          * **Consent Records:** Your agreement to Terms of Service, Privacy Policy, and Community Guidelines.
      * **Information Collected Automatically:**
          * **Usage Data:** IP address, browser type, operating system, device information, app usage patterns, access times, pages viewed.
          * **Location Data:** City/state/ZIP code derived from IP or provided by you. Optional real-time location if granted.
          * **AI-Derived Data:** Numerical ratios/scores generated from photo analysis, AI insights from bio/interests.
      * **Information from Third Parties:** If you link third-party accounts (e.g., Google login), we may receive information from those services.

  **2. How We Use Your Information:**
      * **Provide and Maintain the Service:** Account creation, login, profile management.
      * **Matching:** Use AI-derived data and profile information to suggest compatible matches.
      * **Personalization:** Tailor your experience, content, and features.
      * **Communication:** Send transactional emails (e.g., account verification), service updates, and (with your consent) promotional messages.
      * **Improve the Service:** Analyze usage patterns to enhance features, troubleshoot issues, and develop new offerings.
      * **Safety & Security:** Verify identity, prevent fraud, enforce policies, and ensure compliance with laws.
      * **Analytics & Research:** Understand user demographics and behavior (anonymized or aggregated where possible).

  **3. How We Share Your Information:**
      * **With Matches:** When you match, certain profile information (e.g., display name, selected visible profile data) is shared. Your face photo and full legal name are **never publicly shared.**
      * **With Service Providers:** We may share data with third-party vendors who perform services on our behalf (e.g., cloud hosting (Supabase, Firebase), analytics, email sending, AI analysis services). These providers are contractually obligated to protect your data.
      * **For Legal Reasons:** If required by law, court order, or government request.
      * **Business Transfers:** In connection with a merger, acquisition, or asset sale.
      * **With Your Consent:** For any other purpose with your explicit consent.

  **4. Your Choices & Rights:**
      * **Profile Visibility:** You have granular control in Settings over which profile fields are publicly visible.
      * **Access & Update:** You can access and update your profile information at any time.
      * **Data Download:** You can request a copy of your personal data we hold.
      * **Data Deletion:** You can request permanent deletion of your account and data.
      * **Notifications:** You can manage notification preferences in Settings.
      * **Cookie & Tracking Technologies:** Manage through your browser settings.

  **5. Data Security:**
  We implement robust technical and organizational measures (e.g., encryption, access controls) to protect your data from unauthorized access, alteration, disclosure, or destruction. However, no internet transmission is entirely secure.

  **6. International Data Transfers:**
  Your information may be stored and processed in countries outside of your own, where data protection laws may differ. We ensure appropriate safeguards (e.g., standard contractual clauses) are in place for such transfers.

  **7. Children's Privacy:**
  Our Service is not directed to individuals under the age of 18. We do not knowingly collect personal information from children.

  **8. Changes to This Privacy Policy:**
  We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.

  **9. Contact Us:**
  If you have any questions about this Privacy Policy, please contact us at support@bliindaidating.com.

  ---
  """;

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;
    final Color activeColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;


    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container( // Wrap with Container for custom background/shadows
        decoration: BoxDecoration(
          color: cardColor, // Background of the form panel
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: activeColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: LinearGradient( // Subtle gradient for vibrancy
            colors: [
              cardColor.withOpacity(0.9),
              cardColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24.0), // Inner padding for content
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Agreements & Consent',
                      style: textTheme.headlineSmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: primaryTextColor),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/svg/DrawKit Vector Illustration Love & Dating (9).svg', // Example SVG for Consent/Security
                    height: 50,
                    semanticsLabel: 'Consent Icon',
                    colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'To use BliindAIDating and ensure a safe community for all, please review and agree to the following important documents:',
                style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: RichText(
                  text: TextSpan(
                    style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: primaryTextColor),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: activeColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => PolicyViewerDialog(
                                title: 'Terms of Service',
                                content: _termsContent, // Use internal content
                                isDarkMode: isDarkMode,
                              ),
                            );
                            debugPrint('View Terms of Service in dialog.');
                          },
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy.',
                        style: TextStyle(
                          color: activeColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => PolicyViewerDialog(
                                title: 'Privacy Policy',
                                content: _privacyContent, // Use internal content
                                isDarkMode: isDarkMode,
                              ),
                            );
                            debugPrint('View Privacy Policy in dialog.');
                          },
                      ),
                    ],
                  ),
                ),
                value: widget.agreedToTerms,
                onChanged: widget.onTermsChanged,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: activeColor,
                checkColor: isDarkMode ? Colors.black : Colors.white,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: Text(
                  'I agree to abide by the Community Guidelines and Code of Conduct.',
                  style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: primaryTextColor),
                ),
                value: widget.agreedToCommunityGuidelines,
                onChanged: widget.onCommunityGuidelinesChanged,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: activeColor,
                checkColor: isDarkMode ? Colors.black : Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'By completing this profile, you confirm that all information provided is accurate and truthful.',
                style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', fontStyle: FontStyle.italic, color: secondaryTextColor.withOpacity(0.6)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}