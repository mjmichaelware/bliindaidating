// lib/widgets/dashboard_shell/dashboard_side_menu.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase for logout

// Import the consolidated AppTheme and AppConstants
import 'package:bliindaidating/theme/app_theme.dart';
import 'package:bliindaidating/app_constants.dart';


// --- Side Menu Background Painter ---
class SideMenuGalaxyPainter extends CustomPainter {
  final Animation<double> animation;

  SideMenuGalaxyPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final gradient = RadialGradient(
      colors: [
        AppConstants.backgroundColor.withOpacity(0.9),
        Colors.black.withOpacity(0.95),
      ],
      stops: const [0.0, 1.0],
      center: Alignment.center,
      radius: 1.0,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint..shader = gradient);

    final starPaint = Paint()..color = Colors.white.withOpacity(0.8);
    final random = math.Random(1);

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + (animation.value * size.height * 0.1)) % size.height;
      final starSize = (random.nextDouble() * 1.0 + 0.2);
      canvas.drawCircle(Offset(x, y), starSize, starPaint);
    }

    final swirlPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final swirlColor = Color.lerp(AppTheme.primaryColor.withOpacity(0.4), AppTheme.accentColor.withOpacity(0.6), animation.value)!;
    final swirlGradient = RadialGradient(
      colors: [swirlColor, Colors.transparent],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.7, size.height * 0.9), radius: 60));
    
    canvas.save();
    canvas.translate(size.width * 0.7, size.height * 0.9);
    canvas.rotate(animation.value * 2 * math.pi);
    canvas.drawCircle(Offset.zero, 60, swirlPaint..shader = swirlGradient);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


// --- Side Menu User Profile Header ---
class SideMenuProfileHeader extends StatelessWidget {
  final Animation<double> animation;

  const SideMenuProfileHeader({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.7),
                      AppTheme.primaryColor.withOpacity(0.0),
                    ],
                    radius: 0.8 + 0.2 * math.sin(animation.value * math.pi * 2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.4 * animation.value),
                      blurRadius: 15,
                      spreadRadius: 5 * animation.value,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.cardColor,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/profile_placeholder.png',
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 60,
                        color: AppConstants.textColor.withOpacity(0.7), // Correct: Use AppConstants.textColor
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(
              opacity: animation,
              child: Text(
                'Astro Explorer',
                style: theme.textTheme.displaySmall?.copyWith(color: AppTheme.accentColor),
              ),
            ),
          ),
          const SizedBox(height: 5),
          FadeTransition(
            opacity: animation,
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(value),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successColor.withOpacity(value * 0.6),
                            blurRadius: 8 * value,
                            spreadRadius: 2 * value,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Online & Ready to Connect',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.successColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12, thickness: 1.0),
        ],
      ),
    );
  }
}

// --- Side Menu Navigation Item ---
class SideMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final bool hasNotification;
  final Animation<double> parentAnimation;

  const SideMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
    this.hasNotification = false,
    required this.parentAnimation,
  });

  @override
  State<SideMenuItem> createState() => _SideMenuItemState();
}

class _SideMenuItemState extends State<SideMenuItem> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemColor = widget.isSelected ? AppTheme.accentColor : AppConstants.textColor.withOpacity(0.8); // Correct: Use AppConstants.textColor
    final backgroundColor = widget.isSelected ? AppTheme.primaryColor.withOpacity(0.3) : Colors.transparent;

    return AnimatedBuilder(
      animation: widget.parentAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: widget.parentAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(-0.3 + (widget.parentAnimation.value * 0.1), 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: widget.parentAnimation, curve: Curves.easeOutCubic)),
            child: MouseRegion(
              onEnter: (_) => _hoverController.forward(),
              onExit: (_) => _hoverController.reverse(),
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: widget.isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.accentColor.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                  child: Row(
                    children: [
                      Icon(widget.icon, color: itemColor.withOpacity(0.8 + _hoverAnimation.value * 0.2), size: 28),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: itemColor.withOpacity(0.8 + _hoverAnimation.value * 0.2),
                            fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (widget.hasNotification)
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.8, end: 1.1),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.dangerColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
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

// --- Dynamic Theme Switcher Widget ---
class GalaxyThemeSwitcher extends StatefulWidget {
  final Animation<double> parentAnimation;
  const GalaxyThemeSwitcher({super.key, required this.parentAnimation});

  @override
  State<GalaxyThemeSwitcher> createState() => _GalaxyThemeSwitcherState();
}

class _GalaxyThemeSwitcherState extends State<GalaxyThemeSwitcher> {
  int _selectedThemeIndex = 0;

  final List<Map<String, dynamic>> _themes = [
    {'name': 'Default Galaxy', 'icon': Icons.brightness_auto, 'color': AppTheme.accentColor},
    {'name': 'Nebula Bloom', 'icon': Icons.flare, 'color': AppTheme.primaryColor},
    {'name': 'Deep Void', 'icon': Icons.dark_mode, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: widget.parentAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: widget.parentAnimation, curve: Curves.easeOutCubic),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Galaxy Themes', style: theme.textTheme.headlineMedium?.copyWith(color: AppConstants.textColor)), // Correct: Use AppConstants.textColor
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _themes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final themeData = entry.value;
                    final isSelected = index == _selectedThemeIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedThemeIndex = index;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Switched to ${themeData['name']}!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: isSelected ? themeData['color'].withOpacity(0.3) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? themeData['color'] : Colors.transparent,
                            width: isSelected ? 2.0 : 0.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: themeData['color'].withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Icon(themeData['icon'], size: 30, color: themeData['color']),
                            const SizedBox(height: 5),
                            Text(
                              themeData['name'],
                              style: theme.textTheme.bodySmall?.copyWith(color: themeData['color']),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Cosmic Credits Widget ---
class CosmicCreditsWidget extends StatelessWidget {
  final Animation<double> parentAnimation;
  const CosmicCreditsWidget({super.key, required this.parentAnimation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: parentAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: parentAnimation, curve: Curves.easeOutCubic),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.successColor.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Icon(Icons.monetization_on, size: 40, color: AppTheme.successColor),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cosmic Credits', style: theme.textTheme.headlineSmall?.copyWith(color: AppTheme.successColor)),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: 15423),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Text(
                            '$value CC',
                            style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.successColor, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: AppTheme.successColor, size: 30),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Adding credits... (simulated)')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// --- Main Side Menu Widget ---
class DashboardSideMenu extends StatefulWidget {
  final Animation<double> parentAnimation;

  const DashboardSideMenu({super.key, required this.parentAnimation});

  @override
  State<DashboardSideMenu> createState() => _DashboardSideMenuState();
}

class _DashboardSideMenuState extends State<DashboardSideMenu> { // Removed TickerProviderStateMixin
  int _selectedIndex = 0;

  // No initState needed to initialize _drawerAnimationController

  // Removed didChangeDependencies and dispose logic related to ModalRoute listeners
  // Removed _handleRouteChanged method

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigated to ${[
        'Dashboard', 'Messages', 'Connections', 'Events', 'Profile', 'Settings'
      ][_selectedIndex]}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width * 0.75;

    return Theme(
      data: AppTheme.galaxyTheme,
      child: Drawer(
        width: width,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: widget.parentAnimation, // Correct: Use widget.parentAnimation
                builder: (context, child) {
                  return CustomPaint(
                    painter: SideMenuGalaxyPainter(widget.parentAnimation), // Correct: Use widget.parentAnimation
                    child: Container(),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppConstants.backgroundColor.withOpacity(0.85),
                      AppConstants.backgroundColor.withOpacity(0.95),
                      Colors.black.withOpacity(0.98),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SideMenuProfileHeader(animation: widget.parentAnimation), // Correct: Use widget.parentAnimation
                SideMenuItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () => _onItemTapped(0),
                  isSelected: _selectedIndex == 0,
                  parentAnimation: widget.parentAnimation,
                ),
                SideMenuItem(
                  icon: Icons.message,
                  title: 'Messages',
                  onTap: () => _onItemTapped(1),
                  isSelected: _selectedIndex == 1,
                  hasNotification: true,
                  parentAnimation: widget.parentAnimation,
                ),
                SideMenuItem(
                  icon: Icons.group,
                  title: 'Connections',
                  onTap: () => _onItemTapped(2),
                  isSelected: _selectedIndex == 2,
                  parentAnimation: widget.parentAnimation,
                ),
                SideMenuItem(
                  icon: Icons.event,
                  title: 'Cosmic Events',
                  onTap: () => _onItemTapped(3),
                  isSelected: _selectedIndex == 3,
                  parentAnimation: widget.parentAnimation,
                ),
                SideMenuItem(
                  icon: Icons.person,
                  title: 'My Profile',
                  onTap: () => _onItemTapped(4),
                  isSelected: _selectedIndex == 4,
                  parentAnimation: widget.parentAnimation,
                ),
                const Divider(color: Colors.white12, thickness: 1.0, indent: 15, endIndent: 15),
                GalaxyThemeSwitcher(parentAnimation: widget.parentAnimation), // Correct: Use widget.parentAnimation
                CosmicCreditsWidget(parentAnimation: widget.parentAnimation), // Correct: Use widget.parentAnimation
                SideMenuItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navigating to Settings...')),
                    );
                  },
                  isSelected: _selectedIndex == 5,
                  parentAnimation: widget.parentAnimation,
                ),
                SideMenuItem(
                  icon: Icons.help_center,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening Help Center...')),
                    );
                  },
                  isSelected: _selectedIndex == 6,
                  parentAnimation: widget.parentAnimation,
                ),
                const Divider(color: Colors.white12, thickness: 1.0, indent: 15, endIndent: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                  child: AnimatedBuilder(
                    animation: widget.parentAnimation, // Correct: Use widget.parentAnimation
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: widget.parentAnimation, // Correct: Use widget.parentAnimation
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(
                            CurvedAnimation(parent: widget.parentAnimation, curve: Curves.easeOutCubic), // Correct: Use widget.parentAnimation
                          ),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: Text('Logout', style: theme.textTheme.labelLarge),
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Logging out... (simulated)')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.dangerColor.withOpacity(0.8),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                  child: Text(
                    'Version 1.0.0 (Galactic Core)',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

