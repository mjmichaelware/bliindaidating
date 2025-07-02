import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File; // Required for FileImage on non-web platforms
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bliindaidating/app_constants.dart'; // For colors/theming
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG assets
import 'package:cross_file/cross_file.dart'; // Import XFile

class IdentityIDForm extends StatefulWidget {
  final Function(XFile? image) onImagePicked; // Corrected to accept XFile?
  final TextEditingController phoneNumberController;
  final TextEditingController addressZipController;
  final String? imagePreviewPath;
  final GlobalKey<FormState> formKey;
  // Added the picked XFile directly as a parameter for display
  final XFile? pickedImageFile;

  const IdentityIDForm({
    super.key,
    required this.onImagePicked,
    required this.phoneNumberController,
    required this.addressZipController,
    this.imagePreviewPath,
    required this.formKey,
    this.pickedImageFile, // New parameter
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
        // Pass the XFile directly to the callback
        widget.onImagePicked(image);
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
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;
    final Color activeColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;

    // Determine the image provider based on available data
    ImageProvider<Object>? currentImageProvider;
    if (widget.pickedImageFile != null) {
      // If a new image was picked (XFile is available)
      if (kIsWeb) {
        currentImageProvider = NetworkImage(widget.pickedImageFile!.path);
      } else {
        // For non-web, XFile.path can be used with File for display
        currentImageProvider = FileImage(File(widget.pickedImageFile!.path));
      }
    } else if (widget.imagePreviewPath != null) {
      // If no new image picked, but there's an existing network URL
      currentImageProvider = NetworkImage(widget.imagePreviewPath!);
    }


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
                      'Identity & Connection',
                      style: textTheme.headlineSmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: primaryTextColor),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/svg/DrawKit Vector Illustration Love & Dating (10).svg', // Example SVG for Identity
                    height: 50,
                    semanticsLabel: 'Identity Icon',
                    colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Provide essential contact information and an optional photo for AI analysis.',
                style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
              ),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      // Use the determined image provider
                      backgroundImage: currentImageProvider,
                      child: currentImageProvider == null
                          ? SvgPicture.asset(
                              'assets/svg/DrawKit Vector Illustration Love & Dating (6).svg', // Use an SVG icon/illustration
                              height: 80,
                              semanticsLabel: 'Upload Photo',
                              colorFilter: ColorFilter.mode(secondaryTextColor, BlendMode.srcIn), // Themed color
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAnalysisPhoto,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: activeColor,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 10)], // Add glow
                          ),
                          child: Icon(Icons.add_a_photo, color: isDarkMode ? Colors.black : Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Upload your photo for AI analysis (Optional)',
                  style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Why your photo matters for AI matching:',
                style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: primaryTextColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Your photo is analyzed by our AI to understand certain facial features (like golden ratio and symmetry). This data helps create **deeply compatible matches** by factoring in scientifically-backed elements of attraction. This information is **converted into a numerical ratio and is NEVER publicly displayed on your profile.** Your privacy is paramount, and this data is solely for enhancing your match quality.',
                style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: widget.phoneNumberController,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Phone Number (for Login/Recovery)',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true, // Use filled for background color
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), // Subtle background
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.phone, color: secondaryTextColor),
                  hintText: '+1 (555) 123-4567',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.addressZipController,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Address or ZIP/Postal Code',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true, // Use filled for background color
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), // Subtle background
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.location_on, color: secondaryTextColor),
                  hintText: 'City, State or ZIP Code',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
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
                'Government-issued ID verification (e.g., Driver\'s License, Passport) is **not required for initial setup.** It may be requested at a later stage for certain advanced features or enhanced trust and safety measures.',
                style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}