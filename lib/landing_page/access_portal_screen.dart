// lib/landing_page/access_portal_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';

class AccessPortalScreen extends StatelessWidget {
  const AccessPortalScreen({super.key});

  Widget _buildInfoCard(BuildContext context, {
    required String title,
    required String description,
    required String iconPath,
  }) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (iconPath.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: SvgPicture.asset(
                  iconPath,
                  height: 90,
                  width: 90,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                    BlendMode.srcIn,
                  ),
                  semanticsLabel: title,
                ),
              ),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(
                                blurRadius: 15.0,
                                color: Colors.pink.shade900.withOpacity(0.8),
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  _buildInfoCard(
                    context,
                    title: AppConstants.portalIntroTitle,
                    description: AppConstants.portalIntroDescription,
                    iconPath: AppConstants.svgAiCompatibility,
                  ),
                  const SizedBox(height: 30),

                  _buildInfoCard(
                    context,
                    title: AppConstants.aiPowerTitle,
                    description: AppConstants.aiPowerBody,
                    iconPath: AppConstants.svgHonesty,
                  ),
                  const SizedBox(height: 30),

                  _buildInfoCard(
                    context,
                    title: AppConstants.dateAutomationTitle,
                    description: AppConstants.dateAutomationBody,
                    iconPath: AppConstants.svgDatePlanning,
                  ),
                  const SizedBox(height: 30),

                  _buildInfoCard(
                    context,
                    title: AppConstants.privacyPromiseTitle,
                    description: AppConstants.privacyPromiseBody,
                    iconPath: AppConstants.svgPrivacyShield,
                  ),
                  const SizedBox(height: 60),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: ElevatedButton.icon(
                      onPressed: () => GoRouter.of(context).go('/login'),
                      icon: const Icon(Icons.login_rounded, color: Colors.white, size: 28),
                      label: Text(
                        AppConstants.loginButtonText,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: OutlinedButton.icon(
                      onPressed: () => GoRouter.of(context).go('/signup'),
                      icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 28),
                      label: Text(
                        AppConstants.signupButtonText,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                        side: const BorderSide(color: Colors.white, width: 2.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.4),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
