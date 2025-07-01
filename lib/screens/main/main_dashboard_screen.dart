import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:bliind_ai_dating/shared/glowing_button.dart';
import 'package:bliind_ai_dating/landing_page/landing_page.dart'; // For NebulaBackgroundPainter, ParticleFieldPainter
import 'package:bliind_ai_dating/widgets/dashboard_header.dart';
import 'package:bliind_ai_dating/widgets/dashboard_stat_card.dart';
import 'package:bliind_ai_dating/widgets/dashboard_penalty_section.dart';
import 'package:bliind_ai_dating/widgets/dashboard_info_card.dart';
import 'package:bliind_ai_dating/widgets/dashboard_menu_drawer.dart';
import 'package:bliind_ai_dating/widgets/animated_count.dart'; // Ensure this is correctly imported
import 'dart:math' as math;

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> with TickerProviderStateMixin {
  // --- Background Animations ---
  late AnimationController _backgroundNebulaController;
  late Animation<double> _backgroundNebulaAnimation;
  late AnimationController _orbGlowController;
  late Animation<double> _orbGlowAnimation;
  late AnimationController _textSparkleController;
  late Animation<double> _textSparkleAnimation;

  final List<Offset> _nebulaParticles = [];
  final List<Offset> _deepSpaceParticles = [];
  final math.Random _random = math.Random();

  // --- UI Animations ---
  late final AnimationController _fadeScaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  late final ScrollController _scrollController;

  // --- Dashboard Data (Mock) ---
  final int _totalDatesAttended = 7;
  final int _currentMatches = 3;
  final int _penaltyCount = 1;

  @override
  void initState() {
    super.initState();

    // Background animation controllers
    _backgroundNebulaController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _backgroundNebulaAnimation = CurvedAnimation(parent: _backgroundNebulaController, curve: Curves.linear);
    _orbGlowController = AnimationController(vsync: this, duration: const Duration(seconds: 5), reverseDuration: const Duration(seconds: 4))..repeat(reverse: true);
    _orbGlowAnimation = CurvedAnimation(parent: _orbGlowController, curve: Curves.easeInOutSine);
    _textSparkleController = AnimationController(vsync: this, duration: const Duration(seconds: 6), reverseDuration: const Duration(seconds: 5))..repeat(reverse: true);
    _textSparkleAnimation = CurvedAnimation(parent: _textSparkleController, curve: Curves.easeInOutCirc);

    // UI element entrance animations
    _fadeScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeScaleController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _fadeScaleController, curve: Curves.easeOutBack),
    );
    _fadeScaleController.forward();

    _scrollController = ScrollController();
    _generateParticles(100, _nebulaParticles);
    _generateParticles(80, _deepSpaceParticles);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(() {
        // Add any scroll-based effects here if needed (e.g., parallax)
      });
    });
  }

  void _generateParticles(int count, List<Offset> particleList) {
    for (int i = 0; i < count; i++) {
      particleList.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  @override
  void dispose() {
    _backgroundNebulaController.dispose();
    _orbGlowController.dispose();
    _textSparkleController.dispose();
    _fadeScaleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Dashboard'), // Corrected title
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu_rounded, size: 36, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer(); // Opens the EndDrawer (right side)
                },
              );
            },
          ),
        ],
      ),
      endDrawer: const DashboardMenuDrawer(), // The new menu drawer
      body: Stack(
        children: [
          // Background Orb and Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundNebulaController,
              builder: (context, child) {
                return CustomPaint(
                  painter: NebulaBackgroundPainter(
                    _backgroundNebulaAnimation,
                    Colors.deepPurple.shade900,
                    Colors.indigo.shade900,
                  ),
                  child: Container(),
                );
              },
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ParticleFieldPainter(
                _nebulaParticles,
                _textSparkleAnimation,
                1.0,
                Colors.cyanAccent,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ParticleFieldPainter(
                _deepSpaceParticles,
                _orbGlowAnimation,
                0.7,
                Colors.pinkAccent,
              ),
            ),
          ),

          // Overlay a subtle blur & shimmer layer to add depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.deepPurple.shade900.withOpacity(0.7),
                    Colors.black.withOpacity(0.85),
                  ],
                  center: Alignment.topLeft,
                  radius: 1.5,
                ),
              ),
            ),
          ),

          // Main Content Area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardHeader(
                        fadeAnimation: _fadeAnimation,
                        scaleAnimation: _scaleAnimation,
                        onMenuPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      ),
                      const SizedBox(height: 24),
                      DashboardPenaltySection(penaltyCount: _penaltyCount),
                      DashboardStatCard(
                        label: 'Dates Attended',
                        value: _totalDatesAttended,
                        icon: Icons.event_available_rounded,
                        iconColor: Colors.greenAccent.shade400,
                        pulseAnimation: _orbGlowAnimation,
                        fadeAnimation: _fadeAnimation,
                        scaleAnimation: _scaleAnimation,
                      ),
                      DashboardStatCard(
                        label: 'Current Matches',
                        value: _currentMatches,
                        icon: Icons.favorite_rounded,
                        iconColor: Colors.pink.shade400,
                        pulseAnimation: _orbGlowAnimation,
                        fadeAnimation: _fadeAnimation,
                        scaleAnimation: _scaleAnimation,
                      ),
                      const SizedBox(height: 24),
                      DashboardInfoCard(
                        title: 'Suggested Profiles',
                        icon: Icons.person_search_rounded,
                        iconColor: Colors.cyanAccent,
                        children: [
                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade800,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.pink.shade300.withOpacity(0.6),
                                          blurRadius: 14,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Profile ${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          shadows: [
                                            Shadow(
                                              color: Colors.pinkAccent,
                                              blurRadius: 8,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      DashboardInfoCard(
                        title: 'Daily Personality Question',
                        description: 'What’s your ideal way to spend a weekend?',
                        icon: Icons.question_answer_rounded,
                        iconColor: Colors.purpleAccent,
                        trailingWidget: GlowingButton(
                          icon: Icons.arrow_forward_rounded,
                          text: 'Answer Now',
                          onPressed: () {
                            // TODO: Navigate to daily prompts screen
                          },
                          gradientColors: const [Color(0xFF8E24AA), Color(0xFFD32F2F)],
                          height: 48,
                          width: 160,
                          textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      DashboardInfoCard(
                        title: 'Compatibility Score',
                        icon: Icons.star_rounded,
                        iconColor: Colors.amber,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.star_rounded, color: Colors.amber, size: 48),
                              SizedBox(width: 16),
                              Text(
                                '87%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'You both love deep conversations and outdoor adventures.',
                            style: TextStyle(color: Colors.white70, fontSize: 18),
                          ),
                        ],
                      ),
                      DashboardInfoCard(
                        title: 'Dating Intentions',
                        description: 'Looking for Long-term Relationship',
                        icon: Icons.flag_rounded,
                        iconColor: Colors.pinkAccent,
                        trailingWidget: GlowingButton(
                          icon: Icons.edit_rounded,
                          text: 'Edit',
                          onPressed: () {
                            // TODO: Navigate to intentions edit screen
                          },
                          gradientColors: const [Color(0xFF8E24AA), Color(0xFFD32F2F)],
                          height: 44,
                          width: 100,
                          textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      DashboardInfoCard(
                        title: 'Nearby Events',
                        icon: Icons.event_rounded,
                        iconColor: Colors.lightGreenAccent,
                        children: [
                          const Text('Speed Dating Night - June 30', style: TextStyle(color: Colors.white70, fontSize: 18)),
                          const Text('Singles Mixer - July 5', style: TextStyle(color: Colors.white70, fontSize: 18)),
                          const Text('Outdoor Hike Meetup - July 12', style: TextStyle(color: Colors.white70, fontSize: 18)),
                        ],
                      ),
                      DashboardInfoCard(
                        title: 'Premium Benefits',
                        description: 'Unlock profile boosts, advanced filters, and more!',
                        icon: Icons.workspace_premium_rounded,
                        iconColor: Colors.amberAccent,
                        trailingWidget: GlowingButton(
                          icon: Icons.upgrade_rounded,
                          text: 'Upgrade Now',
                          onPressed: () {
                            // TODO: Navigate to subscription screen
                          },
                          gradientColors: const [Color(0xFF8E24AA), Color(0xFFD32F2F)],
                          height: 52,
                          width: 180,
                          textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      DashboardInfoCard(
                        title: 'Weekly Insights',
                        icon: Icons.insights_rounded,
                        iconColor: Colors.blueAccent,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statIconLabel(Icons.visibility_rounded, 'Views', 45),
                              _statIconLabel(Icons.favorite_rounded, 'Favorites', 12),
                              _statIconLabel(Icons.favorite_border_rounded, 'New Matches', 3),
                            ],
                          ),
                        ],
                      ),
                      DashboardInfoCard(
                        title: 'Privacy Mode',
                        icon: Icons.lock_rounded,
                        iconColor: Colors.white70,
                        trailingWidget: StatefulBuilder(
                          builder: (context, setStateSB) {
                            bool privacyModeOn = false;
                            return Switch(
                              value: privacyModeOn,
                              activeColor: Colors.pink.shade400,
                              onChanged: (val) {
                                setStateSB(() {
                                  privacyModeOn = val;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      DashboardInfoCard(
                        title: 'Profile Boost',
                        icon: Icons.flash_on_rounded,
                        iconColor: Colors.yellowAccent,
                        trailingWidget: GlowingButton(
                          icon: Icons.flash_on_rounded,
                          text: 'Spotlight Me',
                          onPressed: () {
                            // TODO: Trigger profile boost
                          },
                          gradientColors: const [Color(0xFFD32F2F), Color(0xFF8E24AA)],
                          height: 52,
                          width: 180,
                          textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      DashboardInfoCard(
                        title: 'Date Ideas',
                        icon: Icons.lightbulb_outline_rounded,
                        iconColor: Colors.orangeAccent,
                        children: [
                          const Text('• Picnic in the park', style: TextStyle(color: Colors.white70, fontSize: 18)),
                          const Text('• Visit a local art gallery', style: TextStyle(color: Colors.white70, fontSize: 18)),
                          const Text('• Try a cooking class', style: TextStyle(color: Colors.white70, fontSize: 18)),
                          const Text('• Stargazing night', style: TextStyle(color: Colors.white70, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 40),
                      GlowingButton(
                        icon: Icons.edit_rounded,
                        text: 'Edit Profile',
                        onPressed: () {
                          // TODO: Navigate to profile setup/edit screen
                        },
                        gradientColors: const [
                          Color(0xFF8E24AA),
                          Color(0xFFD32F2F),
                        ],
                        height: 52,
                        width: double.infinity,
                        textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 24,
                              runSpacing: 12,
                              children: [
                                TextButton(onPressed: () {}, child: const Text('About Us', style: TextStyle(color: Colors.white70))),
                                TextButton(onPressed: () {}, child: const Text('Privacy Policy', style: TextStyle(color: Colors.white70))),
                                TextButton(onPressed: () {}, child: const Text('Terms of Service', style: TextStyle(color: Colors.white70))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '© 2025 Blind AI Dating.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statIconLabel(IconData icon, String label, int value) {
    return Column(
      children: [
        Icon(icon, color: Colors.pink.shade300, size: 34),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }
}
