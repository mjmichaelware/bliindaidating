// lib/screens/main/main_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' show radians; // Keep if actually used, otherwise can be removed

// Import the consolidated AppTheme and AppConstants
import 'package:bliindaidating/theme/app_theme.dart';
import 'package:bliindaidating/app_constants.dart';
// FIX: Corrected import path for dashboard_side_menu.dart based on file tree
import 'package:bliindaidating/widgets/dashboard_shell/dashboard_side_menu.dart'; // Import the side menu

// Re-creating an enhanced GalaxyBackgroundPainter
class GalaxyBackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  GalaxyBackgroundPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final gradient = RadialGradient(
      colors: [
        AppConstants.backgroundColor.withOpacity(0.8),
        AppConstants.backgroundColor.withOpacity(1.0),
        Colors.black.withOpacity(0.9),
      ],
      stops: const [0.0, 0.5, 1.0],
      center: Alignment.center,
      radius: 0.8,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint..shader = gradient);

    final starPaint = Paint()..color = Colors.white;
    final random = math.Random(0);

    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = (random.nextDouble() * 1.5 + 0.5) * animation.value;
      canvas.drawCircle(Offset(x, y), starSize, starPaint);
    }

    final nebulaPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    final nebulaColor1 = Color.lerp(AppTheme.primaryColor.withOpacity(0.3), AppTheme.accentColor.withOpacity(0.5), animation.value)!;
    final nebulaColor2 = Color.lerp(AppTheme.accentColor.withOpacity(0.2), AppTheme.primaryColor.withOpacity(0.4), 1.0 - animation.value)!;

    final nebulaGradient = RadialGradient(
      colors: [nebulaColor1, nebulaColor2, Colors.transparent],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.2, size.height * 0.1), radius: 150 + 50 * animation.value));
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.1), 150 + 50 * animation.value, nebulaPaint..shader = nebulaGradient);

    final nebulaGradient2 = RadialGradient(
      colors: [nebulaColor2, nebulaColor1, Colors.transparent],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.8, size.height * 0.9), radius: 120 + 40 * (1.0 - animation.value)));
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.9), 120 + 40 * (1.0 - animation.value), nebulaPaint..shader = nebulaGradient2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// A more complex App Bar with dynamic elements
class CustomAppBarGalaxy extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuPressed;
  final double scrollOffset;

  const CustomAppBarGalaxy({
    super.key,
    required this.title,
    required this.onMenuPressed,
    this.scrollOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = (1.0 - (scrollOffset / 200).clamp(0.0, 1.0));

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor?.withOpacity(0.8 - (scrollOffset / 300).clamp(0.0, 0.8)),
      elevation: 0,
      leading: AnimatedOpacity(
        opacity: opacity,
        duration: AppConstants.animationDurationNormal, // Correct: AppConstants.animationDurationNormal is a Duration
        child: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenuPressed,
          color: theme.iconTheme.color,
        ),
      ),
      title: Transform.translate(
        offset: Offset(0, -scrollOffset * 0.5),
        child: AnimatedOpacity(
          opacity: opacity,
          duration: AppConstants.animationDurationNormal, // Correct: AppConstants.animationDurationNormal is a Duration
          child: Text(
            title,
            style: theme.appBarTheme.titleTextStyle,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.notifications, color: theme.iconTheme.color),
                if (true)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.5, end: 1.2),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppTheme.dangerColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.dangerColor.withOpacity(0.5),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            onPressed: () {
              // Handle notifications
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: Icon(Icons.search, color: theme.iconTheme.color),
            onPressed: () {
              // Handle search
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


// --- Complex Dashboard Widgets (Simulated) ---

class AnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final Curve animationCurve;
  final double initialDelay;

  const AnimatedCardWrapper({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationCurve = Curves.easeOutCubic,
    this.initialDelay = 0.0,
  });

  @override
  State<AnimatedCardWrapper> createState() => _AnimatedCardWrapperState();
}

class _AnimatedCardWrapperState extends State<AnimatedCardWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.animationCurve),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.animationCurve),
    );

    Future.delayed(Duration(milliseconds: (widget.initialDelay * 1000).toInt()), () {
      if (mounted) {
        _controller.forward();
      }
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
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}


class MatchCarouselWidget extends StatelessWidget {
  const MatchCarouselWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedCardWrapper(
      initialDelay: 0.1,
      child: Card(
        color: theme.cardColor.withOpacity(0.7),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Orbital Matches', style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.accentColor)),
              const SizedBox(height: 15),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                              child: Icon(Icons.person, size: 50, color: AppTheme.accentColor.withOpacity(0.7)),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Star Seeker ${index + 1}',
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            LinearProgressIndicator(
                              value: (index + 3) * 0.1,
                              backgroundColor: AppTheme.cardColor.withOpacity(0.5),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successColor),
                            ),
                            Text(
                              '${((index + 3) * 10)}% Match',
                              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All Matches >',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.accentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityFeedWidget extends StatelessWidget {
  const ActivityFeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedCardWrapper(
      initialDelay: 0.2,
      child: Card(
        color: theme.cardColor.withOpacity(0.7),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cosmic Activity Feed', style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.accentColor)),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    IconData icon;
                    String activityText;
                    Color iconColor;

                    if (index == 0) {
                      icon = Icons.message;
                      activityText = 'New message from AstroGirl22!';
                      iconColor = AppTheme.successColor;
                    } else if (index == 1) {
                      icon = Icons.group_add;
                      activityText = 'You connected with GalaxyNavigator.';
                      iconColor = AppTheme.primaryColor;
                    } else if (index == 2) {
                      icon = Icons.visibility;
                      activityText = 'Your profile was viewed by 5 new explorers.';
                      iconColor = AppTheme.accentColor;
                    } else {
                      icon = Icons.event;
                      activityText = 'Upcoming event: "Nebula Nexus Meetup" tonight!';
                      iconColor = AppTheme.dangerColor;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(icon, color: iconColor, size: 28),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              activityText,
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'View Full Activity Log >',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.accentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PersonalizedInsightsCard extends StatelessWidget {
  const PersonalizedInsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedCardWrapper(
      initialDelay: 0.3,
      child: Card(
        color: theme.cardColor.withOpacity(0.7),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Cosmic Insights', style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.accentColor)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInsightMetric(context, 'Connections', '125', Icons.people_alt, AppTheme.successColor),
                  _buildInsightMetric(context, 'Engagements', '8.7K', Icons.star, AppTheme.primaryColor),
                  _buildInsightMetric(context, 'Profile Views', '450', Icons.remove_red_eye, AppTheme.accentColor),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Tip: Your recent engagement is up by 15% this week! Keep exploring new galaxies to find more connections.',
                style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Dive DAppConstants.textColoreeper >',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.accentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightMetric(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 5),
        Text(value, style: theme.textTheme.displaySmall?.copyWith(color: color)),
        Text(title, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class TrendingCosmicEvents extends StatelessWidget {
  const TrendingCosmicEvents({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedCardWrapper(
      initialDelay: 0.4,
      child: Card(
        color: theme.cardColor.withOpacity(0.7),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trending Cosmic Events', style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.accentColor)),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    String eventName;
                    String eventDate;
                    String location;
                    Color color;
                    IconData icon; // FIX: Declare icon here and initialize it

                    if (index == 0) {
                      eventName = 'Meteor Shower Watch Party';
                      eventDate = 'July 25, 2025';
                      location = 'Virtual Galaxy Meetup';
                      color = AppTheme.successColor;
                      icon = Icons.star; // Example icon
                    } else if (index == 1) {
                      eventName = 'Planetary Alignment Seminar';
                      eventDate = 'August 1, 2025';
                      location = 'Cosmic Convention Center';
                      color = AppTheme.primaryColor;
                      icon = Icons.public; // Example icon
                    } else {
                      eventName = 'Black Hole Physics Lecture';
                      eventDate = 'August 10, 2025';
                      location = 'Online Webinar';
                      color = AppTheme.dangerColor;
                      icon = Icons.school; // Example icon
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 28), // FIX: Use the local 'icon' variable
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(eventName, style: theme.textTheme.headlineSmall),
                                Text('$eventDate - $location', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color.withOpacity(0.7),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text('RSVP'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Explore More Events >',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.accentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Main Dashboard Screen ---

class MainDashboardScreen extends StatefulWidget {
  // Constructor is correct, no changes needed here.
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> with TickerProviderStateMixin {
  late AnimationController _galaxyAnimationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _galaxyAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _galaxyAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.galaxyTheme,
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        // Correct: Pass the animation controller to DashboardSideMenu
        endDrawer: DashboardSideMenu(parentAnimation: _galaxyAnimationController),
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _galaxyAnimationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: GalaxyBackgroundPainter(_galaxyAnimationController),
                    child: Container(),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppConstants.backgroundColor.withOpacity(0.7),
                      AppConstants.backgroundColor.withOpacity(0.9),
                      Colors.black.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            CustomAppBarGalaxy(
              title: 'Cosmic Connect',
              onMenuPressed: _openEndDrawer,
              scrollOffset: _scrollOffset,
            ),
            Positioned.fill(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  return false;
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        height: 80.0 + _scrollOffset * 0.1,
                        child: Center(
                          child: Opacity(
                            opacity: (1.0 - (_scrollOffset / 100).clamp(0.0, 1.0)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Welcome, Stellar Traveler!',
                                  style: Theme.of(context).textTheme.displayMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Explore the cosmos and connect with kindred spirits.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            const MatchCarouselWidget(),
                            const SizedBox(height: AppConstants.paddingMedium),
                            const ActivityFeedWidget(),
                            const SizedBox(height: AppConstants.paddingMedium),
                            const PersonalizedInsightsCard(),
                            const SizedBox(height: AppConstants.paddingMedium),
                            SizedBox(
                              height: 300,
                              child: const TrendingCosmicEvents(),
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),
                            Center(
                              child: Text(
                                'More cosmic journeys await...',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontStyle: FontStyle.italic),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
