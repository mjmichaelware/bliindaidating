// lib/screens/profile_setup/widgets/consent_form.dart

import 'package:flutter/material.dart';

class ConsentForm extends StatefulWidget {
  final bool agreedToTerms;
  final bool agreedToCommunityGuidelines;
  final Function(bool?) onTermsChanged;
  final Function(bool?) onCommunityGuidelinesChanged;
  final GlobalKey<FormState> formKey; // Receive the form key from parent


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
  @override
  Widget build(BuildContext context) {
    return Form( // Each tab now has its own Form, but uses the parent's key
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agreements & Consent',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          CheckboxListTile(
            title: Text(
              'I agree to the Terms of Service and Privacy Policy.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
            ),
            value: widget.agreedToTerms,
            onChanged: widget.onTermsChanged,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Theme.of(context).colorScheme.secondary,
            // REMOVED VALIDATOR: Validation is handled by parent ProfileSetupScreen's _validateCurrentTab
            // validator: (value) {
            //   if (value == null || !value) {
            //     return 'You must agree to the Terms of Service.';
            //   }
            //   return null;
            // },
          ),
          CheckboxListTile(
            title: Text(
              'I agree to abide by the Community Guidelines and Code of Conduct.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
            ),
            value: widget.agreedToCommunityGuidelines,
            onChanged: widget.onCommunityGuidelinesChanged,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Theme.of(context).colorScheme.secondary,
            // REMOVED VALIDATOR: Validation is handled by parent ProfileSetupScreen's _validateCurrentTab
            // validator: (value) {
            //   if (value == null || !value) {
            //     return 'You must agree to the Community Guidelines.';
            //   }
            //   return null;
            // },
          ),
          const SizedBox(height: 24),
          Text(
            'By completing this profile, you confirm that all information provided is accurate and truthful.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}