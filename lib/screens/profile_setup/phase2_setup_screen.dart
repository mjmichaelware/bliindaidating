// lib/screens/profile_setup/phase2_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'dart:math' as math;
import 'dart:ui'; // For ImageFilter
import 'package:go_router/go_router.dart'; // Import go_router for navigation
import 'package:supabase_flutter/supabase_flutter.dart'; // For Supabase and User
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService

// Import remaining 5 sub-tab form files (assuming these are widgets, not full screens)
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/education_and_career_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/family_and_background_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/lifestyle_and_values_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/personality_and_self_reflection_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/physical_attributes_and_health_form.dart';

// Removed: import 'package:bliindaidating/profile/ai_profile_generator_widget.dart';


// --- Custom Painter for Animated Nebula Background (similar to landing page but adapted) ---
class Phase2NebulaBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDarkMode;

  Phase2NebulaBackgroundPainter(this.animation, this.primaryColor, this.secondaryColor, this.isDarkMode)
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Dynamic colors for the nebula effect
    final Color color1 = Color.lerp(primaryColor.withOpacity(isDarkMode ? 0.4 : 0.2), secondaryColor.withOpacity(isDarkMode ? 0.6 : 0.4), animation.value)!;
    final Color color2 = Color.lerp(secondaryColor.withOpacity(isDarkMode ? 0.4 : 0.2), primaryColor.withOpacity(isDarkMode ? 0.6 : 0.4), animation.value)!;

    // Main radial gradient for the nebula
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [color1, color2, Colors.transparent],
          stops: const [0.0, 0.6, 1.0],
          center: Alignment(math.sin(animation.value * math.pi * 2) * 0.5, math.cos(animation.value * math.pi * 2) * 0.5),
          radius: 0.8 + 0.2 * animation.value,
        ).createShader(Offset.zero & size),
    );

    // Secondary, more subtle glow/blur layer
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            (isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor).withOpacity(0.1 + animation.value * 0.1),
            (isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor).withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
          center: Alignment(math.cos(animation.value * math.pi) * 0.7, math.sin(animation.value * math.pi) * 0.7),
          radius: 0.2 + 0.1 * animation.value,
        ).createShader(Offset.zero & size)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20.0 * animation.value),
    );
  }

  @override
  bool shouldRepaint(covariant Phase2NebulaBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.primaryColor != primaryColor || oldDelegate.secondaryColor != secondaryColor || oldDelegate.isDarkMode != isDarkMode;
  }
}

// --- Custom Painter for Dynamic Particle Field (similar to landing page) ---
class Phase2ParticleFieldPainter extends CustomPainter {
  final List<Offset> particles;
  final Animation<double> animation;
  final double maxRadius;
  final Color baseColor;

  Phase2ParticleFieldPainter(this.particles, this.animation, this.maxRadius, this.baseColor)
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = baseColor.withOpacity(0.3 + 0.7 * animation.value)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, maxRadius * animation.value * 0.5);

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final driftX = math.sin(animation.value * math.pi * 2 + i * 0.1) * 5;
      final driftY = math.cos(animation.value * math.pi * 2 + i * 0.1) * 5;
      final currentPosition = Offset(particle.dx * size.width + driftX, particle.dy * size.height + driftY);
      canvas.drawCircle(currentPosition, maxRadius * animation.value, paint);
    }
  }

  @override
  bool shouldRepaint(covariant Phase2ParticleFieldPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.baseColor != baseColor || oldDelegate.maxRadius != maxRadius || oldDelegate.particles != particles;
  }
}

// --- Phase2SetupScreen: The Immersive Container for Profile Setup ---
class Phase2SetupScreen extends StatefulWidget {
  const Phase2SetupScreen({super.key});

  @override
  State<Phase2SetupScreen> createState() => _Phase2SetupScreenState();
}

class _Phase2SetupScreenState extends State<Phase2SetupScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSaving = false; // New state to manage saving process

  // Animation controllers for background and UI elements
  late AnimationController _globalFadeInController;
  late Animation<double> _globalFadeInAnimation;

  late AnimationController _backgroundNebulaController;
  late Animation<double> _backgroundNebulaAnimation;

  late AnimationController _particleFieldController;
  late Animation<double> _particleFieldAnimation;

  late AnimationController _progressGlowController;
  late Animation<double> _progressGlowAnimation;

  final List<Offset> _nebulaParticles = [];
  final List<Offset> _deepSpaceParticles = [];
  final math.Random _random = math.Random();

  // List of the 5 sub-tab form widgets (UPDATED)
  // Removed AiProfileGeneratorWidget() as it does not exist.
  final List<Widget> _phase2SubForms = const [
    EducationAndCareerForm(),
    FamilyAndBackgroundForm(),
    LifestyleAndValuesForm(),
    PersonalityAndSelfReflectionForm(),
    PhysicalAttributesAndHealthForm(),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize background particles
    _generateParticles(100, _nebulaParticles);
    _generateParticles(80, _deepSpaceParticles);

    // Global fade-in for the screen content
    _globalFadeInController = AnimationController(vsync: this, duration: AppConstants.animationDurationLong);
    _globalFadeInAnimation = CurvedAnimation(parent: _globalFadeInController, curve: Curves.easeOutQuart);

    // Animated background elements
    _backgroundNebulaController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _backgroundNebulaAnimation = CurvedAnimation(parent: _backgroundNebulaController, curve: Curves.linear);

    _particleFieldController = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
    _particleFieldAnimation = CurvedAnimation(parent: _particleFieldController, curve: Curves.linear);

    // Progress bar glow animation
    _progressGlowController = AnimationController(vsync: this, duration: const Duration(seconds: 3), reverseDuration: const Duration(seconds: 2))..repeat(reverse: true);
    _progressGlowAnimation = CurvedAnimation(parent: _progressGlowController, curve: Curves.easeInOutSine);

    // Start global fade-in after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _globalFadeInController.forward();
      }
    });
  }

  void _generateParticles(int count, List<Offset> particleList) {
    for (int i = 0; i < count; i++) {
      particleList.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _globalFadeInController.dispose();
    _backgroundNebulaController.dispose();
    _particleFieldController.dispose();
    _progressGlowController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _phase2SubForms.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationDurationMedium,
        curve: Curves.easeInOutCubic, // More dynamic curve
      );
    } else {
      _submitPhase2Completion(); // All tabs completed
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.animationDurationMedium,
        curve: Curves.easeInOutCubic, // More dynamic curve
      );
    }
  }

  Future<void> _submitPhase2Completion() async {
    setState(() {
      _isSaving = true; // Indicate saving in progress
    });

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in!')),
        );
        context.go('/login');
      }
      setState(() { _isSaving = false; });
      return;
    }

    final profileService = Provider.of<ProfileService>(context, listen: false);

    try {
      // 1. Fetch the existing user profile
      UserProfile? existingProfile = await profileService.fetchUserProfile(id: currentUser.id);

      if (existingProfile == null) {
        throw Exception('User profile not found. Cannot complete Phase 2.');
      }

      // 2. Create an updated UserProfile object using copyWith
      final UserProfile updatedProfile = existingProfile.copyWith(
        isPhase2Complete: true,
      );

      // 3. Call updateProfile with the new UserProfile object
      // CORRECTED LINE: Use named argument 'profile'
      await profileService.updateProfile(profile: updatedProfile); // Line 246

      debugPrint('Phase 2 Profile Setup Complete for user ${currentUser.id}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Phase 2 Complete!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to the main dashboard
        context.go('/home');
      }
    } on PostgrestException catch (e) {
      debugPrint('Supabase Postgrest Error completing Phase 2: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Database error: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('Error completing Phase 2: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete Phase 2: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    final size = MediaQuery.of(context).size;

    // Determine if it's a small screen (mobile)
    final bool isSmallScreen = size.width < 600;

    // Theme-dependent colors
    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color textMediumEmphasis = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color surfaceColor = isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;

    return Scaffold(
      backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Complete Your Profile: Phase 2',
          style: TextStyle(
            color: textColor,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            // Adjust font size based on screen size
            fontSize: isSmallScreen ? AppConstants.fontSizeLarge : AppConstants.fontSizeExtraLarge,
          ),
          overflow: TextOverflow.ellipsis, // Prevent text overflow on small screens
        ),
        backgroundColor: Colors.transparent, // Make app bar transparent to show background
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor).withOpacity(0.8),
                (isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor).withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Added the Exit/Close Button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.paddingMedium),
            child: TextButton(
              onPressed: _isSaving ? null : () {
                // Assuming you want to allow closing and seeing dashboard
                // This will pop the current route, but the main.dart redirect
                // might still push it back if the logic isn't relaxed.
                context.go('/home'); // Navigate to home instead of pop, to handle redirect logic
              },
              style: TextButton.styleFrom(
                foregroundColor: textColor,
                backgroundColor: (isDarkMode ? AppConstants.primaryColorShade700 : AppConstants.lightPrimaryColorShade400).withOpacity(0.7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- Animated Background Elements ---
          // Nebula Background
          Positioned.fill(
            child: CustomPaint(
              painter: Phase2NebulaBackgroundPainter(
                _backgroundNebulaAnimation,
                isDarkMode ? AppConstants.primaryColorShade900 : AppConstants.lightPrimaryColorShade400,
                isDarkMode ? AppConstants.secondaryColorShade900 : AppConstants.lightSecondaryColorShade400,
                isDarkMode,
              ),
            ),
          ),
          // Particle Field
          Positioned.fill(
            child: CustomPaint(
              painter: Phase2ParticleFieldPainter(
                _deepSpaceParticles,
                _particleFieldAnimation,
                isSmallScreen ? 1.5 : 2.5, // Max radius for particles
                isDarkMode ? AppConstants.textColor.withOpacity(0.8) : AppConstants.lightTextColor.withOpacity(0.8),
              ),
            ),
          ),

          // --- Main Content (Fade In Transition) ---
          FadeTransition(
            opacity: _globalFadeInAnimation,
            child: ScaleTransition(
              scale: _globalFadeInAnimation.drive(Tween<double>(begin: 0.95, end: 1.0)),
              child: Padding(
                // Adjust padding based on screen size
                padding: EdgeInsets.all(isSmallScreen ? AppConstants.paddingSmall : AppConstants.paddingMedium),
                child: Column(
                  children: [
                    // Progress Indicator with Glow
                    AnimatedBuilder(
                      animation: _progressGlowAnimation,
                      builder: (context, child) {
                        final double glowValue = _progressGlowAnimation.value;
                        final Color glowColor = Color.lerp(
                          secondaryColor.withOpacity(0.5),
                          secondaryColor.withOpacity(1.0),
                          glowValue,
                        )!;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                            boxShadow: [
                              BoxShadow(
                                color: glowColor.withOpacity(0.4 + 0.3 * glowValue),
                                blurRadius: 15.0 + 10.0 * glowValue,
                                spreadRadius: 2.0 + 3.0 * glowValue,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: LinearProgressIndicator(
                            value: (_currentPage + 1) / _phase2SubForms.length,
                            backgroundColor: surfaceColor,
                            color: secondaryColor,
                            minHeight: AppConstants.spacingSmall,
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),

                    // Current Page Text Indicator
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppConstants.paddingSmall, bottom: AppConstants.paddingSmall),
                        child: Text(
                          'Section ${_currentPage + 1} of ${_phase2SubForms.length}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? AppConstants.fontSizeSmall : AppConstants.fontSizeMedium,
                            color: textMediumEmphasis,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Main Content Area for Sub-Tabs (with subtle card styling)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.8), // Semi-transparent card
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: (isDarkMode ? AppConstants.borderColor : AppConstants.lightBorderColor).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect( // Clip content to rounded corners
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _phase2SubForms.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return SingleChildScrollView( // Ensure content inside each tab is scrollable
                                padding: EdgeInsets.all(isSmallScreen ? AppConstants.paddingMedium : AppConstants.paddingLarge), // Adjust padding inside tab
                                child: _phase2SubForms[index],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),

                    // Navigation Buttons with Custom Styling and Animation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous Button
                        if (_currentPage > 0)
                          _buildAnimatedButton(
                            context,
                            label: 'Previous',
                            icon: Icons.arrow_back_ios_new_rounded,
                            onPressed: _isSaving ? null : _goToPreviousPage, // Disable during saving
                            isPrimary: false, // Not the main action
                            isDarkMode: isDarkMode,
                            isSmallScreen: isSmallScreen, // Pass screen size info
                          ),

                        // Spacer to push buttons to ends if only one is visible
                        if (_currentPage == 0 && _phase2SubForms.length > 1)
                          const Spacer(),

                        // Next / Complete Button
                        _buildAnimatedButton(
                          context,
                          label: _currentPage == _phase2SubForms.length - 1
                              ? 'Complete Phase 2'
                              : 'Next',
                          icon: _currentPage == _phase2SubForms.length - 1
                              ? Icons.done_all_rounded
                              : Icons.arrow_forward_ios_rounded,
                          onPressed: _isSaving ? null : _goToNextPage, // Disable during saving
                          isPrimary: true, // Main action button
                          isDarkMode: isDarkMode,
                          isSmallScreen: isSmallScreen, // Pass screen size info
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading Overlay
          if (_isSaving)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: secondaryColor),
                      const SizedBox(height: AppConstants.spacingMedium),
                      Text(
                        'Completing Phase 2...',
                        style: TextStyle(
                          color: textColor,
                          fontFamily: 'Inter',
                          fontSize: isSmallScreen ? AppConstants.fontSizeLarge : AppConstants.fontSizeExtraLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to build animated buttons
  Widget _buildAnimatedButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback? onPressed, // Make onPressed nullable
    required bool isPrimary,
    required bool isDarkMode,
    required bool isSmallScreen, // New parameter for responsive buttons
  }) {
    final Color buttonColor = isPrimary
        ? (isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor)
        : (isDarkMode ? AppConstants.primaryColorShade700 : AppConstants.lightPrimaryColorShade400);
    final Color buttonTextColor = isPrimary
        ? (isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor)
        : (isDarkMode ? AppConstants.textColor.withOpacity(0.9) : AppConstants.lightTextColor.withOpacity(0.9));

    // Adjust padding and font size for buttons based on screen size
    final double horizontalPadding = isSmallScreen ? AppConstants.paddingMedium : AppConstants.paddingLarge;
    final double verticalPadding = isSmallScreen ? AppConstants.paddingSmall : AppConstants.paddingMedium;
    final double fontSize = isSmallScreen ? AppConstants.fontSizeMedium : AppConstants.fontSizeLarge;
    final double iconSize = isSmallScreen ? AppConstants.fontSizeLarge : AppConstants.fontSizeExtraLarge;


    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: AppConstants.animationDurationMedium,
      curve: Curves.easeInOutQuad,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + 0.02 * value, // Subtle scale effect on rebuild
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              boxShadow: [
                BoxShadow(
                  color: buttonColor.withOpacity(0.4 * value),
                  blurRadius: 15.0 * value,
                  spreadRadius: 3.0 * value,
                  offset: const Offset(0, 5),
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  buttonColor.withOpacity(0.9),
                  Color.lerp(buttonColor, isPrimary ? AppConstants.tertiaryColor : AppConstants.complementaryColor2, 0.3)!.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed, // Use the nullable onPressed directly
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: buttonTextColor, size: iconSize),
                      SizedBox(width: AppConstants.spacingSmall),
                      Text(
                        label,
                        style: TextStyle(
                          color: buttonTextColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}