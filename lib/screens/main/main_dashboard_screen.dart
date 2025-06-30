import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:bliindaidating/shared/glowing_button.dart';
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';
import 'dart:math';

class DashboardScreen extends StatefulWidget {
  final int totalDatesAttended;
  final int currentMatches;
  final int penaltyCount;

  const DashboardScreen({
    super.key,
    required this.totalDatesAttended,
    required this.currentMatches,
    required this.penaltyCount,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  late final AnimationController _fadeScaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeScaleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _animatedStatCard({
    required String label,
    required int value,
    required IconData icon,
    required Color iconColor,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade900.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.6),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Icon(icon, size: 48, color: iconColor),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      letterSpacing: 0.9,
                    ),
                  ),
                  AnimatedCount(
                    count: value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedPenaltySection() {
    final penaltyCount = widget.penaltyCount;

    if (penaltyCount <= 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.green.shade900.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.greenAccent,
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.check_circle_rounded, size: 40, color: Colors.white),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                'You have no penalties! Keep up the great cosmic harmony.',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),
          ],
        ),
      );
    }

    final displayCount = penaltyCount.clamp(1, 10);

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade700.withOpacity(0.75),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.white),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'Penalty Alert: You have $penaltyCount date turn-down${penaltyCount > 1 ? 's' : ''}!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Row(
            children: List.generate(displayCount, (index) {
              final delay = index * 150;
              return AnimatedPenaltyCross(delay: delay);
            }),
          ),
        ],
      ),
    );
  }

  Widget _suggestedProfiles() {
    List<String> dummyProfiles = ['Alex', 'Jamie', 'Taylor', 'Jordan', 'Morgan'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested Profiles',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dummyProfiles.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final profile = dummyProfiles[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.85, end: 1.0),
                  duration: Duration(milliseconds: 600 + index * 150),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
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
                        profile,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dailyPersonalityQuestion() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade700.withOpacity(0.8),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Personality Question',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'What’s your ideal way to spend a weekend?',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: GlowingButton(
              icon: Icons.question_answer_rounded,
              text: 'Answer Now',
              onPressed: () {
                // TODO: Implement question answering flow
              },
              gradientColors: const [Color(0xFF8E24AA), Color(0xFFD32F2F)],
              height: 48,
              width: 160,
              textStyle: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _compatibilityScore() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade700.withOpacity(0.8),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compatibility Score',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Icon(Icons.star_rounded, color: Colors.amber, size: 48),
              SizedBox(width: 16),
              Text(
                '87%',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 40),
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
    );
  }

  Widget _datingIntentions() {
    const String intention = 'Looking for Long-term Relationship';

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade700.withOpacity(0.8),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, size: 44, color: Colors.pinkAccent),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              intention,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          GlowingButton(
            icon: Icons.edit_rounded,
            text: 'Edit',
            onPressed: () {
              // TODO: Implement edit intentions navigation
            },
            gradientColors: const [Color(0xFF8E24AA), Color(0xFFD32F2F)],
            height: 44,
            width: 100,
            textStyle: const TextStyle(fontSize: 16, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _nearbyEvents() {
    List<String> dummyEvents = [
      'Speed Dating Night - June 30',
      'Singles Mixer - July 5',
      'Outdoor Hike Meetup - July 12',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Events',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...dummyEvents.map(
          (event) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade800.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.shade700.withOpacity(0.7),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Text(
              event,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _premiumBenefits() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFF8E24AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade700.withOpacity(0.9),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Premium Benefits',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Unlock profile boosts, advanced filters, and more!',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 20),
          GlowingButton(
            icon: Icons.upgrade_rounded,
            text: 'Upgrade Now',
            onPressed: () {
              // TODO: Navigate to subscription screen
            },
            gradientColors: const [Color(0xFF8E24AA), Color(0xFFD32F2F)],
            height: 52,
            width: double.infinity,
            textStyle: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _weeklyInsights() {
    final views = 45;
    final favorites = 12;
    final newMatches = 3;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade300.withOpacity(0.7),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Insights',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statIconLabel(Icons.visibility_rounded, 'Views', views),
              _statIconLabel(Icons.favorite_rounded, 'Favorites', favorites),
              _statIconLabel(Icons.favorite_border_rounded, 'New Matches', newMatches),
            ],
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

  Widget _privacyToggle() {
    bool privacyModeOn = false; // Ideally from state or service

    return StatefulBuilder(builder: (context, setStateSB) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade800.withOpacity(0.75),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.shade900.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_rounded, size: 36, color: Colors.white70),
            const SizedBox(width: 20),
            const Expanded(
              child: Text(
                'Privacy Mode',
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
            ),
            Switch(
              value: privacyModeOn,
              activeColor: Colors.pink.shade400,
              onChanged: (val) {
                setStateSB(() {
                  privacyModeOn = val;
                  // TODO: Persist privacy mode state & trigger haptics
                });
              },
            )
          ],
        ),
      );
    });
  }

  Widget _profileBoostButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: GlowingButton(
        icon: Icons.flash_on_rounded,
        text: 'Spotlight Me',
        onPressed: () {
          // TODO: Trigger profile boost with animation & feedback
        },
        gradientColors: const [Color(0xFFD32F2F), Color(0xFF8E24AA)],
        height: 52,
        width: double.infinity,
        textStyle: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget _dateIdeas() {
    List<String> ideas = [
      'Picnic in the park',
      'Visit a local art gallery',
      'Try a cooking class',
      'Stargazing night',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Ideas',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...ideas.map(
          (idea) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '• $idea',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()),

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

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // Could add parallax effect or lazy load animations
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with glow and parallax shadow
                      Text(
                        'Profile Dashboard',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          shadows: const [
                            Shadow(
                              color: Colors.redAccent,
                              blurRadius: 18,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _animatedPenaltySection(),

                      _animatedStatCard(
                        label: 'Dates Attended',
                        value: widget.totalDatesAttended,
                        icon: Icons.event_available_rounded,
                        iconColor: Colors.greenAccent.shade400,
                      ),

                      _animatedStatCard(
                        label: 'Current Matches',
                        value: widget.currentMatches,
                        icon: Icons.favorite_rounded,
                        iconColor: Colors.pink.shade400,
                      ),

                      const SizedBox(height: 24),

                      _suggestedProfiles(),

                      _dailyPersonalityQuestion(),

                      _compatibilityScore(),

                      _datingIntentions(),

                      _nearbyEvents(),

                      _premiumBenefits(),

                      _weeklyInsights(),

                      _privacyToggle(),

                      _profileBoostButton(),

                      const SizedBox(height: 24),

                      _dateIdeas(),

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
                        textStyle:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),

                      const SizedBox(height: 40),
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
}

/// Animated count widget for numbers with smooth counting animation.
class AnimatedCount extends StatefulWidget {
  final int count;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCount({
    Key? key,
    required this.count,
    this.style,
    this.duration = const Duration(milliseconds: 900),
  }) : super(key: key);

  @override
  State<AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<AnimatedCount> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = IntTween(begin: 0, end: widget.count).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCount oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.count != widget.count) {
      _animation = IntTween(begin: _animation.value, end: widget.count).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Text(
          '${_animation.value}',
          style: widget.style,
        );
      },
    );
  }
}

/// Animated cross icon for penalty indicators with fade & scale effect.
class AnimatedPenaltyCross extends StatefulWidget {
  final int delay;

  const AnimatedPenaltyCross({Key? key, this.delay = 0}) : super(key: key);

  @override
  State<AnimatedPenaltyCross> createState() => _AnimatedPenaltyCrossState();
}

class _AnimatedPenaltyCrossState extends State<AnimatedPenaltyCross> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.close_rounded, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}
