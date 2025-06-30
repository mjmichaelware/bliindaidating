import 'package:flutter/material.dart';

class InterestsScreen extends StatelessWidget {
  const InterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Select your interests',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}
