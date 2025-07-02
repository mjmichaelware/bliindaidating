// lib/screens/profile_setup/widgets/identity_id_form.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File; // Import File only, conditionally used
import 'package:flutter/foundation.dart' show kIsWeb; // For kIsWeb

class IdentityIDForm extends StatefulWidget {
  final Function(XFile?) onImagePicked;
  final TextEditingController phoneNumberController;
  final TextEditingController addressZipController;
  final String? imagePreviewPath;
  final GlobalKey<FormState> formKey; // Receive the form key from parent

  const IdentityIDForm({
    super.key,
    required this.onImagePicked,
    required this.phoneNumberController,
    required this.addressZipController,
    this.imagePreviewPath,
    required this.formKey,
  });

  @override
  State<IdentityIDForm> createState() => _IdentityIDFormState();
}

class _IdentityIDFormState extends State<IdentityIDForm> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAnalysisPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        widget.onImagePicked(image); // Use callback to notify parent
      }
    } catch (e) {
      debugPrint('Error picking analysis photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form( // Each tab now has its own Form, but uses the parent's key
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Identity & Verification',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: _pickAnalysisPhoto,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                backgroundImage: widget.imagePreviewPath != null
                    ? (kIsWeb
                        ? NetworkImage(widget.imagePreviewPath!) as ImageProvider<Object>
                        : FileImage(File(widget.imagePreviewPath!)) as ImageProvider<Object>)
                    : null,
                child: widget.imagePreviewPath == null
                    ? Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Upload your face photo for AI analysis',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: widget.phoneNumberController,
            decoration: InputDecoration(
              labelText: 'Phone Number (for SMS Verification)',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.phone),
              hintText: '+1 (555) 123-4567',
              hintStyle: TextStyle(fontFamily: 'Inter', color: Theme.of(context).hintColor),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number.';
              }
              // TODO: Add more robust phone number validation (regex or package)
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.addressZipController,
            decoration: InputDecoration(
              labelText: 'Address or ZIP/Postal Code',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.location_on),
              hintText: 'City, State or ZIP Code',
              hintStyle: TextStyle(fontFamily: 'Inter', color: Theme.of(context).hintColor),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your location information.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Government-issued ID (e.g., Driver\'s License, Passport) upload will be requested here for full verification.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}