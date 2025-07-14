// lib/widgets/dashboard_shell/dashboard_side_menu.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math; // For math.pi and other math functions

import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile
import 'package:bliindaidating/services/auth_service.dart'; // Import AuthService for sign out
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService for completion status

// --- Custom Painter for Side Menu Background (Inspired by NebulaBackgroundPainter) ---
class SideMenuBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Offset> particles;
  final double particleMaxRadius;
  final bool isDrawerMode; // Added to control opacity

  SideMenuBackgroundPainter(
    this.animation,
    this.primaryColor,
    this.secondaryColor,
    this.particles,
    this.particleMaxRadius,
    this.isDrawerMode, // Added
  ) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Main gradient background
    final color1 = Color.lerp(primaryColor.withOpacity(0.4), secondaryColor.withOpacity(0.6), animation.value)!;
    final color2 = Color.lerp(secondaryColor.withOpacity(0.4), primaryColor.withOpacity(0.6), animation.value)!;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient( // Changed to Linear for side menu feel
          colors: [color1, color2, Colors.transparent],
          stops: const [0.0, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & size),
    );

    // Secondary subtle glow/nebula effect
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppConstants.textColor.withOpacity(0.05 + animation.value * 0.05),
            AppConstants.textColor.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
          center: Alignment(math.cos(animation.value * math.pi) * 0.7, math.sin(animation.value * math.pi) * 0.7),
          radius: 0.2 + 0.1 * animation.value,
        ).createShader(Offset.zero & size)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 * animation.value),
    );

    // Particles (inspired by ParticleFieldPainter)
    final particlePaint = Paint()
      ..color = AppConstants.textColor.withOpacity(0.2 + 0.3 * animation.value)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleMaxRadius * animation.value * 0.5);

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final driftX = math.sin(animation.value * math.pi * 2 + i * 0.1) * 3;
      final driftY = math.cos(animation.value * math.pi * 2 + i * 0.1) * 3;
      final currentPosition = Offset(particle.dx * size.width + driftX, particle.dy * size.height + driftY);
      canvas.drawCircle(currentPosition, particleMaxRadius * animation.value, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SideMenuBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.primaryColor != primaryColor ||
           oldDelegate.secondaryColor != secondaryColor ||
           oldDelegate.isDrawerMode != isDrawerMode; // Added
  }
}

// --- Side Menu Profile Header (Enhanced) ---
class _SideMenuProfileHeader extends StatelessWidget {
  final UserProfile? userProfile;
  final String? profilePictureUrl;
  final Animation<double> expandAnimation;
  final bool isCollapsed;

  const _SideMenuProfileHeader({
    super.key,
    required this.userProfile,
    required this.profilePictureUrl,
    required this.expandAnimation,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color headerAccentColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color headerTextColor = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color onlineIndicatorColor = AppConstants.successColor;

    final String displayName = userProfile?.displayName ?? userProfile?.fullLegalName ?? 'Stellar Traveler'; // Corrected to use fullLegalName

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.paddingLarge,
        horizontal: AppConstants.paddingMedium,
      ),
      child: Column(
        children: [
          // Profile Picture with Animated Glow
          AnimatedBuilder(
            animation: expandAnimation,
            builder: (context, child) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: expandAnimation, curve: Curves.easeOutBack),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: headerAccentColor.withOpacity(0.4 * expandAnimation.value),
                        blurRadius: 15 * expandAnimation.value,
                        spreadRadius: 5 * expandAnimation.value,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: AppConstants.avatarRadius,
                    backgroundColor: AppConstants.cardColor.withOpacity(0.8),
                    backgroundImage: profilePictureUrl != null
                        ? NetworkImage(profilePictureUrl!)
                        : null,
                    child: profilePictureUrl == null
                        ? Icon(
                            Icons.person_rounded,
                            size: AppConstants.avatarRadius * 1.2,
                            color: headerTextColor.withOpacity(0.7),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          // User Name and Status
          AnimatedCrossFade(
            duration: AppConstants.animationDurationMedium,
            crossFadeState: isCollapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Container(width: 0, height: 0), // Collapsed state
            secondChild: Column(
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    color: headerTextColor,
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: onlineIndicatorColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: onlineIndicatorColor.withOpacity(0.6),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: onlineIndicatorColor,
                        fontSize: AppConstants.fontSizeSmall,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextButton(
                  onPressed: () {
                    context.go('/my-profile');
                  },
                  child: Text(
                    'Manage Profile',
                    style: TextStyle(
                      color: headerAccentColor,
                      fontSize: AppConstants.fontSizeSmall,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: headerAccentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppConstants.borderColor.withOpacity(0.2), height: AppConstants.spacingMedium),
        ],
      ),
    );
  }
}

// --- Side Menu Item (Enhanced with Hover and Animation) ---
class _SideMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String routeName;
  final bool isSelected;
  final bool isEnabled;
  final bool isCollapsed;
  final ValueChanged<int>? onTabSelected; // For main dashboard tabs
  final int? tabIndex; // Corresponding tab index for onTabSelected
  final Animation<double> expandAnimation;

  const _SideMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.routeName,
    this.isSelected = false,
    this.isEnabled = true,
    required this.isCollapsed,
    this.onTabSelected,
    this.tabIndex,
    required this.expandAnimation,
  }) : super(key: key);

  @override
  State<_SideMenuItem> createState() => _SideMenuItemState();
}

class _SideMenuItemState extends State<_SideMenuItem> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationShort,
    );
    _hoverAnimation = CurvedAnimation(parent: _hoverController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color selectedItemColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color unselectedItemColor = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color disabledColor = isDarkMode ? AppConstants.textLowEmphasis.withOpacity(0.3) : AppConstants.lightTextLowEmphasis.withOpacity(0.3);

    final Color currentIconColor = widget.isEnabled
        ? (widget.isSelected ? selectedItemColor : unselectedItemColor)
        : disabledColor;
    final Color currentTextColor = widget.isEnabled
        ? (widget.isSelected ? textColor : unselectedItemColor)
        : disabledColor;

    return MouseRegion(
      onEnter: (_) {
        if (widget.isEnabled) _hoverController.forward();
      },
      onExit: (_) {
        if (widget.isEnabled) _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.isEnabled
            ? () {
                if (widget.onTabSelected != null && widget.tabIndex != null) {
                  widget.onTabSelected!(widget.tabIndex!);
                } else {
                  context.go(widget.routeName);
                }
              }
            : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.expandAnimation, _hoverAnimation]),
          builder: (context, child) {
            final double expandFactor = widget.expandAnimation.value;
            final double hoverFactor = _hoverAnimation.value;

            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingSmall,
                vertical: AppConstants.paddingExtraSmall,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected && widget.isEnabled
                    ? selectedItemColor.withOpacity(0.2 + 0.1 * hoverFactor)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: widget.isSelected && widget.isEnabled
                    ? Border.all(color: selectedItemColor.withOpacity(0.5 + 0.2 * hoverFactor), width: 1.0 + 0.5 * hoverFactor)
                    : null,
                boxShadow: [
                  if (widget.isSelected && widget.isEnabled)
                    BoxShadow(
                      color: selectedItemColor.withOpacity(0.2 * hoverFactor + 0.1),
                      blurRadius: 8 * hoverFactor + 4,
                      spreadRadius: 2 * hoverFactor + 1,
                    ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: Color.lerp(currentIconColor, selectedItemColor, hoverFactor),
                      size: AppConstants.fontSizeExtraLarge * (1.0 + 0.1 * hoverFactor),
                    ),
                    SizedBox(width: AppConstants.spacingMedium * expandFactor),
                    Expanded(
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: expandFactor,
                          child: Opacity(
                            opacity: expandFactor,
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                color: Color.lerp(currentTextColor, textColor, hoverFactor),
                                fontSize: AppConstants.fontSizeMedium,
                                fontFamily: 'Inter',
                                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- Side Menu Category Item (Enhanced ExpansionTile) ---
class _SideMenuCategoryItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isCollapsed;
  final Animation<double> expandAnimation;

  const _SideMenuCategoryItem({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    required this.isCollapsed,
    required this.expandAnimation,
  });

  @override
  State<_SideMenuCategoryItem> createState() => _SideMenuCategoryItemState();
}

class _SideMenuCategoryItemState extends State<_SideMenuCategoryItem> with SingleTickerProviderStateMixin {
  late AnimationController _expansionController;
  late Animation<double> _expansionAnimation;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expansionController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationMedium,
    );
    _expansionAnimation = CurvedAnimation(parent: _expansionController, curve: Curves.easeInOutCubic);

    _hoverController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationShort,
    );
    _hoverAnimation = CurvedAnimation(parent: _hoverController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color unselectedItemColor = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color selectedItemColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.expandAnimation, _hoverAnimation, _expansionAnimation]),
        builder: (context, child) {
          final double expandFactor = widget.expandAnimation.value;
          final double hoverFactor = _hoverAnimation.value;

          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingSmall,
              vertical: AppConstants.paddingExtraSmall,
            ),
            decoration: BoxDecoration(
              color: _isExpanded
                  ? selectedItemColor.withOpacity(0.15 + 0.05 * hoverFactor)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              border: _isExpanded
                  ? Border.all(color: selectedItemColor.withOpacity(0.3 + 0.1 * hoverFactor), width: 1.0)
                  : null,
              boxShadow: [
                if (_isExpanded)
                  BoxShadow(
                    color: selectedItemColor.withOpacity(0.1 * hoverFactor + 0.05),
                    blurRadius: 5 * hoverFactor + 2,
                    spreadRadius: 1 * hoverFactor + 0.5,
                  ),
              ],
            ),
            child: ClipRRect( // Clip to prevent overflow during collapse
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              child: Theme( // Override default ExpansionTile theme for custom styling
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  listTileTheme: ListTileThemeData(
                    iconColor: unselectedItemColor,
                    textColor: textColor,
                    selectedColor: selectedItemColor,
                    minLeadingWidth: AppConstants.fontSizeExtraLarge,
                  ),
                ),
                child: ExpansionTile(
                  key: ValueKey(widget.title), // Key to ensure state is reset when title changes
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _isExpanded = expanded;
                    });
                    if (expanded) {
                      _expansionController.forward();
                    } else {
                      _expansionController.reverse();
                    }
                  },
                  leading: Icon(
                    widget.icon,
                    color: Color.lerp(unselectedItemColor, selectedItemColor, hoverFactor),
                    size: AppConstants.fontSizeExtraLarge * (1.0 + 0.1 * hoverFactor),
                  ),
                  title: ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: expandFactor,
                      child: Opacity(
                        opacity: expandFactor,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: Color.lerp(unselectedItemColor, textColor, hoverFactor),
                            fontSize: AppConstants.fontSizeMedium,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  trailing: AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0.0, // Rotate arrow when expanded
                    duration: AppConstants.animationDurationMedium,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: unselectedItemColor.withOpacity(expandFactor),
                      size: AppConstants.fontSizeSmall * 1.5,
                    ),
                  ),
                  children: [
                    // Sub-items are only visible when expanded
                    Padding(
                      padding: EdgeInsets.only(left: AppConstants.paddingLarge * expandFactor),
                      child: SizeTransition(
                        sizeFactor: _expansionAnimation,
                        child: FadeTransition(
                          opacity: AlwaysStoppedAnimation<double>(_expansionAnimation.value),
                          child: Column(
                            children: widget.children.map<Widget>((child) {
                              // Ensure sub-items also respect the theme and expand factor
                              if (child is _SideMenuItem) {
                                return _SideMenuItem(
                                  key: child.key,
                                  icon: child.icon,
                                  title: child.title,
                                  routeName: child.routeName,
                                  isSelected: child.isSelected,
                                  isEnabled: child.isEnabled,
                                  isCollapsed: widget.isCollapsed, // Pass collapsed state
                                  onTabSelected: child.onTabSelected,
                                  tabIndex: child.tabIndex,
                                  expandAnimation: widget.expandAnimation, // Pass parent animation
                                );
                              }
                              return child;
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Dynamic Theme Switcher Widget (REMOVED due to persistent error) ---
// This widget has been removed as per your instruction to remove lines causing repeated errors.
// If you wish to re-implement theme switching, please ensure your ThemeController
// has a 'setTheme(bool isDark)' method or provide the ThemeController code.

// --- Cosmic Credits Widget (REMOVED as requested) ---
// This widget has been removed as per your instruction.

// --- Main Dashboard Side Menu Widget ---
class DashboardSideMenu extends StatefulWidget {
  final UserProfile? userProfile;
  final String? profilePictureUrl;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final bool isPhase2Complete;
  final ValueChanged<bool> onCollapseToggle;
  final bool isInitiallyCollapsed;
  final bool isDrawerMode; // NEW: Indicates if it's operating as a Drawer

  const DashboardSideMenu({
    super.key,
    this.userProfile,
    this.profilePictureUrl,
    required this.selectedTabIndex,
    required this.onTabSelected,
    this.isPhase2Complete = false,
    required this.onCollapseToggle,
    this.isInitiallyCollapsed = false,
    this.isDrawerMode = false, // Default to false (persistent sidebar)
  });

  @override
  State<DashboardSideMenu> createState() => _DashboardSideMenuState();
}

class _DashboardSideMenuState extends State<DashboardSideMenu> with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  bool _isCollapsed = false; // Internal state for collapsed/expanded

  final List<Offset> _backgroundParticles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    // If in drawer mode, force it to be expanded
    _isCollapsed = widget.isDrawerMode ? false : widget.isInitiallyCollapsed;

    _expandController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationMedium,
    );
    _expandAnimation = CurvedAnimation(parent: _expandController, curve: Curves.easeInOutCubic);

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // Slower animation for background
    )..repeat(reverse: true);
    _backgroundAnimation = CurvedAnimation(parent: _backgroundAnimationController, curve: Curves.linear);

    _generateParticles(50, _backgroundParticles);

    // Initial state of the animation controller based on _isCollapsed
    if (_isCollapsed) {
      _expandController.value = 0.0; // Fully collapsed
    } else {
      _expandController.value = 1.0; // Fully expanded
    }
  }

  void _generateParticles(int count, List<Offset> particleList) {
    for (int i = 0; i < count; i++) {
      particleList.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
      if (_isCollapsed) {
        _expandController.reverse();
      } else {
        _expandController.forward();
      }
    });
    widget.onCollapseToggle(_isCollapsed); // Notify parent of the change
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final authService = Provider.of<AuthService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context);

    final bool isPhase1Complete = profileService.userProfile?.isPhase1Complete ?? false;
    final bool isPhase2Complete = profileService.userProfile?.isPhase2Complete ?? false; // Corrected local variable name
    final bool isProfileFullyComplete = isPhase1Complete && isPhase2Complete;

    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color menuBackgroundColor = isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color unselectedItemColor = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color logoutButtonColor = AppConstants.errorColor; // Use error color for logout

    // Responsive width logic
    final double maxMenuWidth = AppConstants.dashboardSideMenuWidth;
    final double minMenuWidth = AppConstants.spacingXXL + AppConstants.paddingMedium; // Icon size + padding

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        // In drawer mode, width is always maxMenuWidth and it's never collapsed visually
        final double currentWidth = widget.isDrawerMode
            ? maxMenuWidth
            : minMenuWidth + (maxMenuWidth - minMenuWidth) * _expandAnimation.value;
        final bool isCurrentlyCollapsed = widget.isDrawerMode ? false : _expandAnimation.value < 0.5; // Visual check for collapsed state

        return Container(
          width: currentWidth,
          decoration: BoxDecoration(
            color: widget.isDrawerMode
                ? menuBackgroundColor.withOpacity(1.0) // Fully opaque in drawer mode
                : menuBackgroundColor, // Base color for persistent
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(5, 0),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated Background Painter
              Positioned.fill(
                child: CustomPaint(
                  painter: SideMenuBackgroundPainter(
                    _backgroundAnimation,
                    primaryColor,
                    secondaryColor,
                    _backgroundParticles,
                    AppConstants.spacingExtraSmall, // Particle size
                    widget.isDrawerMode, // Pass isDrawerMode to painter
                  ),
                ),
              ),
              // Overlay gradient for depth
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.isDrawerMode
                            ? menuBackgroundColor.withOpacity(1.0) // Fully opaque in drawer mode
                            : menuBackgroundColor.withOpacity(0.8),
                        widget.isDrawerMode
                            ? menuBackgroundColor.withOpacity(1.0) // Fully opaque in drawer mode
                            : menuBackgroundColor.withOpacity(0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              // Actual menu content
              Column(
                children: [
                  // Toggle Button (top right) - Only show for persistent sidebar, not for drawer
                  if (!widget.isDrawerMode)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingSmall),
                        child: IconButton(
                          icon: AnimatedRotation(
                            turns: isCurrentlyCollapsed ? 0.0 : 0.25, // Rotate 90 degrees when expanded
                            duration: AppConstants.animationDurationMedium,
                            child: Icon(
                              isCurrentlyCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                              color: textColor.withOpacity(0.7),
                              size: AppConstants.fontSizeLarge,
                            ),
                          ),
                          onPressed: _toggleCollapse,
                          tooltip: isCurrentlyCollapsed ? 'Expand Menu' : 'Collapse Menu',
                        ),
                      ),
                    ),
                  // Profile Header
                  _SideMenuProfileHeader(
                    userProfile: widget.userProfile,
                    profilePictureUrl: widget.profilePictureUrl,
                    expandAnimation: _expandAnimation,
                    isCollapsed: isCurrentlyCollapsed,
                  ),
                  Divider(color: AppConstants.borderColor.withOpacity(0.2), height: 1),

                  // Navigation Items (using ListView for scrollability)
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // Top Level Items
                        _SideMenuItem(
                          icon: Icons.dashboard,
                          title: 'Dashboard Overview',
                          routeName: '/home',
                          isSelected: widget.selectedTabIndex == 0,
                          isEnabled: isProfileFullyComplete, // Only enable if profile is complete
                          isCollapsed: isCurrentlyCollapsed,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 0,
                          expandAnimation: _expandAnimation,
                        ),
                        _SideMenuItem(
                          icon: Icons.favorite,
                          title: 'Matches',
                          routeName: '/matches',
                          isSelected: widget.selectedTabIndex == 1,
                          isEnabled: isProfileFullyComplete, // Only enable if profile is complete
                          isCollapsed: isCurrentlyCollapsed,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 1,
                          expandAnimation: _expandAnimation,
                        ),
                        _SideMenuItem(
                          icon: Icons.explore,
                          title: 'Discovery',
                          routeName: '/discovery',
                          isSelected: widget.selectedTabIndex == 2,
                          isEnabled: isProfileFullyComplete, // Only enable if profile is complete
                          isCollapsed: isCurrentlyCollapsed,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 2,
                          expandAnimation: _expandAnimation,
                        ),
                        _SideMenuItem(
                          icon: Icons.quiz,
                          title: 'Questionnaire',
                          routeName: '/questionnaire', // This route should lead to Phase2SetupScreen
                          isSelected: widget.selectedTabIndex == 3,
                          isEnabled: isPhase1Complete, // Enable if Phase 1 is complete
                          isCollapsed: isCurrentlyCollapsed,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 3,
                          expandAnimation: _expandAnimation,
                        ),
                        _SideMenuItem(
                          icon: Icons.person_add,
                          title: 'Profile Setup',
                          routeName: '/profile_setup', // This route should lead to Phase1SetupScreen
                          isSelected: widget.selectedTabIndex == 4,
                          isEnabled: true, // Always enabled for initial setup/re-visiting
                          isCollapsed: isCurrentlyCollapsed,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 4,
                          expandAnimation: _expandAnimation,
                        ),
                        _SideMenuItem(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          routeName: '/notifications',
                          isSelected: widget.selectedTabIndex == 5,
                          isEnabled: true, // Notifications might be accessible even if profile incomplete
                          isCollapsed: isCurrentlyCollapsed,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 5,
                          expandAnimation: _expandAnimation,
                        ),
                        _SideMenuItem(
                          icon: Icons.event,
                          title: 'Local Events',
                          routeName: '/events',
                          isSelected: widget.selectedTabIndex == 6,
                          isEnabled: isProfileFullyComplete, // Only enable if profile is complete
                          isCollapsed: isCurrentlyCollapsed,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 6,
                          expandAnimation: _expandAnimation,
                        ),
                        _SideMenuItem(
                          icon: Icons.gavel,
                          title: 'Penalties',
                          routeName: '/penalties',
                          isSelected: widget.selectedTabIndex == 7,
                          isEnabled: true, // Penalties might be accessible regardless of profile completion
                          isCollapsed: isCurrentlyCollapsed,
                          onTabSelected: widget.onTabSelected,
                          tabIndex: 7,
                          expandAnimation: _expandAnimation,
                        ),

                        // Settings and Feedback Category
                        _SideMenuCategoryItem(
                          title: 'App Management',
                          icon: Icons.settings,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                          children: [
                            _SideMenuItem(
                              icon: Icons.settings,
                              title: 'Settings',
                              routeName: '/settings',
                              isSelected: widget.selectedTabIndex == 8,
                              isEnabled: true,
                              isCollapsed: isCurrentlyCollapsed,
                              onTabSelected: widget.onTabSelected,
                              tabIndex: 8,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.feedback,
                              title: 'Feedback',
                              routeName: '/feedback',
                              isSelected: widget.selectedTabIndex == 9,
                              isEnabled: true,
                              isCollapsed: isCurrentlyCollapsed,
                              onTabSelected: widget.onTabSelected,
                              tabIndex: 9,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.flag,
                              title: 'Report Issue',
                              routeName: '/report',
                              isSelected: widget.selectedTabIndex == 10,
                              isEnabled: true,
                              isCollapsed: isCurrentlyCollapsed,
                              onTabSelected: widget.onTabSelected,
                              tabIndex: 10,
                              expandAnimation: _expandAnimation,
                            ),
                            if (authService.currentUser?.email == AppConstants.adminEmail) // Admin check
                              _SideMenuItem(
                                icon: Icons.admin_panel_settings,
                                title: 'Admin Panel',
                                routeName: '/admin',
                                isSelected: widget.selectedTabIndex == 11,
                                isEnabled: true,
                                isCollapsed: isCurrentlyCollapsed,
                                onTabSelected: widget.onTabSelected,
                                tabIndex: 11,
                                expandAnimation: _expandAnimation,
                              ),
                          ],
                        ),

                        // Information Category
                        _SideMenuCategoryItem(
                          title: 'Information',
                          icon: Icons.info,
                          isCollapsed: isCurrentlyCollapsed,
                          expandAnimation: _expandAnimation,
                          children: [
                            _SideMenuItem(
                              icon: Icons.info_outline,
                              title: 'About Us',
                              routeName: '/about-us',
                              isSelected: widget.selectedTabIndex == 12,
                              isEnabled: true,
                              isCollapsed: isCurrentlyCollapsed,
                              onTabSelected: widget.onTabSelected,
                              tabIndex: 12,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              routeName: '/privacy',
                              isSelected: widget.selectedTabIndex == 13,
                              isEnabled: true,
                              isCollapsed: isCurrentlyCollapsed,
                              onTabSelected: widget.onTabSelected,
                              tabIndex: 13,
                              expandAnimation: _expandAnimation,
                            ),
                            _SideMenuItem(
                              icon: Icons.gavel_outlined,
                              title: 'Terms of Service',
                              routeName: '/terms',
                              isSelected: widget.selectedTabIndex == 14,
                              isEnabled: true,
                              isCollapsed: isCurrentlyCollapsed,
                              onTabSelected: widget.onTabSelected,
                              tabIndex: 14,
                              expandAnimation: _expandAnimation,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await authService.signOut();
                        if (mounted) {
                          context.go('/'); // Redirect to landing page after logout
                        }
                      },
                      icon: Icon(Icons.logout, color: textColor),
                      label: AnimatedOpacity(
                        opacity: isCurrentlyCollapsed ? 0.0 : 1.0,
                        duration: AppConstants.animationDurationShort,
                        child: Text(
                          'Logout',
                          style: TextStyle(color: textColor, fontFamily: 'Inter'),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: logoutButtonColor,
                        foregroundColor: textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isCurrentlyCollapsed ? AppConstants.paddingSmall : AppConstants.paddingLarge,
                          vertical: AppConstants.paddingMedium,
                        ),
                        minimumSize: Size(isCurrentlyCollapsed ? 50 : double.infinity, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}