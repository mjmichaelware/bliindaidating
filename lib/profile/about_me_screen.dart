import 'package:flutter/material.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'About Me content goes here',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}
