// lib/screens/profile_setup/phase2_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';

// Import the main tabs for Phase 2
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_data_tab.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_questionnaire_tab.dart';

class Phase2SetupScreen extends StatefulWidget {
  const Phase2SetupScreen({super.key});

  @override
  State<Phase2SetupScreen> createState() => _Phase2SetupScreenState();
}

class _Phase2SetupScreenState extends State<Phase2SetupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserProfile _currentUserProfile;
  bool _isLoading = true;
  String? _errorMessage;

  // Animation controllers for the background elements
  late AnimationController _starTwinkleController;
  late Animation<double> _starTwinkleAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();

    // Initialize star twinkle animation
    _starTwinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(); // Repeat animation indefinitely

    _starTwinkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _starTwinkleController,
        curve: Curves.easeInOut,
      ),
    );

    // Listener for tab changes (optional, but good for potential auto-save or analytics)
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // You could trigger a save here if desired, or just rely on exit/explicit saves
        // print('Tab changed to: ${_tabController.index}');
      }
    });
  }

  // Fetches the current user profile from ProfileService
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final userProfile = await ProfileService.instance.getCurrentUserProfile();
      if (userProfile != null) {
        setState(() {
          _currentUserProfile = userProfile;
          _isLoading = false;
        });
      } else {
        // If no profile exists, create a basic one for the current user
        final currentUser = ProfileService.instance.auth.currentUser;
        if (currentUser != null && currentUser.email != null) {
          _currentUserProfile = UserProfile.fromSupabaseUser(currentUser);
          // Attempt to save this new basic profile to Supabase
          await ProfileService.instance.updateUserProfile(_currentUserProfile);
          setState(() {
            _isLoading = false;
          });
        } else {
          // This scenario should ideally not happen if user is authenticated
          setState(() {
            _errorMessage = 'User not authenticated or email missing.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  // Callback method passed to child widgets to update the UserProfile in the parent state
  void _updateUserProfile(UserProfile updatedProfile) {
    setState(() {
      _currentUserProfile = updatedProfile;
    });
  }

  // Saves changes to Supabase and navigates back to the dashboard
  Future<void> _saveAndExit() async {
    setState(() {
      _isLoading = true; // Show loading indicator during save
    });
    try {
      // Update the isPhase2Complete flag based on the current state of the profile
      // This will check if all required fields are filled as per UserProfile logic
      final updatedProfileWithStatus = _currentUserProfile.copyWith(
        isPhase2Complete: _currentUserProfile.isPhase2ProfileComplete,
        updatedAt: DateTime.now(), // Update timestamp on save
      );
      await ProfileService.instance.updateUserProfile(updatedProfileWithStatus);
      if (mounted) {
        context.go('/dashboard'); // Navigate back to the main dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e', style: TextStyle(color: AppConstants.textHighEmphasis)),
            backgroundColor: AppConstants.errorColor,
          ),
        );
        setState(() {
          _isLoading = false; // Stop loading on error
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _starTwinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final bool isDarkMode = themeController.isDarkMode;

    // Use AppConstants for all colors and dimensions
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color primaryColor = AppConstants.primaryColor;
    final Color accentColor = isDarkMode ? AppConstants.accentColor : AppConstants.lightAccentColor;
    final Color surfaceColor = isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final Color gradientStart = AppConstants.darkPurpleGradientStart;
    final Color gradientEnd = AppConstants.darkPurpleGradientEnd;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: gradientStart, // Start color for loading screen
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: _errorMessage != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: TextStyle(color: AppConstants.errorColor, fontSize: AppConstants.fontSizeLarge)),
                      const SizedBox(height: AppConstants.spacingMedium),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingLarge,
                            vertical: AppConstants.paddingMedium,
                          ),
                        ),
                        child: Text(
                          'Retry Profile Load',
                          style: TextStyle(
                            color: AppConstants.textHighEmphasis,
                            fontSize: AppConstants.fontSizeMedium,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  )
                : CircularProgressIndicator(color: accentColor),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to extend behind AppBar for full background effect
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(AppBar().preferredSize?.height + kToolbarHeight), // Height for AppBar + TabBar
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppConstants.borderRadiusLarge)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Frosted glass effect
            child: AppBar(
              backgroundColor: surfaceColor.withOpacity(0.1), // More transparent to show background
              elevation: AppConstants.elevationLarge,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppConstants.borderRadiusLarge),
                ),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.2), // Lighter, more ethereal
                      accentColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppConstants.borderRadiusLarge),
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phase 2 Profile',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AppConstants.fontSizeTitle,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 3.0,
                          color: primaryColor.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppConstants.appName, // "Blind AI Dating" title from AppConstants
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AppConstants.fontSizeSmall,
                      color: textColor.withOpacity(0.8),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: accentColor,
                unselectedLabelColor: textColor.withOpacity(0.7),
                indicatorColor: accentColor,
                indicatorWeight: AppConstants.borderThicknessMedium,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppConstants.fontSizeMedium,
                ),
                tabs: const [
                  Tab(text: 'My Data'),
                  Tab(text: 'Questionnaire'),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.exit_to_app_rounded, color: textColor, size: AppConstants.iconSizeLarge),
                  onPressed: _saveAndExit, // Call save and exit logic
                  tooltip: 'Save and Exit',
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background with subtle galaxy effect
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStart, gradientEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Animated stars
          AnimatedBuilder(
            animation: _starTwinkleController,
            builder: (context, child) {
              return CustomPaint(
                painter: StarPainter(
                  animationValue: _starTwinkleAnimation.value,
                  starColor: AppConstants.starColor,
                ),
                child: Container(), // Empty container to provide size for CustomPaint
              );
            },
          ),
          // Ensure content is not under the AppBar
          Padding(
            padding: EdgeInsets.only(top: AppBar().preferredSize?.height + kToolbarHeight),
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pass the current UserProfile and a callback for updates
                Phase2ProfileDataTab(
                  userProfile: _currentUserProfile,
                  onUpdate: _updateUserProfile,
                ),
                Phase2QuestionnaireTab(
                  userProfile: _currentUserProfile,
                  onUpdate: _updateUserProfile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for subtle star/galaxy background effect
class StarPainter extends CustomPainter {
  final double animationValue;
  final Color starColor;
  final int numberOfStars = 300; // Number of stars
  final double maxStarSize = 2.0; // Max size of a star

  StarPainter({required this.animationValue, required this.starColor});

  // Pre-calculate star positions to avoid recalculating on every paint
  // This list will hold [x, y, size, opacity] for each star
  static final List<List<double>> _starPositions = [];
  static final math.Random _random = math.Random();

  @override
  void paint(Canvas canvas, Size size) {
    if ((_starPositions ?? []).isEmpty) {
      // Initialize star positions once
      for (int i = 0; i < numberOfStars; i++) {
        _starPositions.add([
          _random.nextDouble() * size?.width, // x position
          _random.nextDouble() * size?.height, // y position
          _random.nextDouble() * maxStarSize + 0.5, // size
          _random.nextDouble() * 0.7 + 0.3, // base opacity
        ]);
      }
    }

    final Paint starPaint = Paint();
    for (final star in _starPositions) {
      final double x = star?[0];
      final double y = star?[1];
      final double size = star?[2];
      final double baseOpacity = star?[3];

      // Make stars twinkle based on animation value
      // A sine wave makes them fade in and out smoothly
      final double twinkleFactor = math.sin((animationValue + x / size?.width + y / size?.height) * math.pi * 2) * 0.5 + 0.5;
      final double currentOpacity = (baseOpacity * twinkleFactor).clamp(0.0, 1.0);

      starPaint.color = starColor.withOpacity(currentOpacity);
      canvas.drawCircle(Offset(x, y), size * twinkleFactor * 0.7 + 0.3, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint only if animation value changes, or if size changes (for initial calculation)
    return (oldDelegate as StarPainter).animationValue != animationValue;
  }
}