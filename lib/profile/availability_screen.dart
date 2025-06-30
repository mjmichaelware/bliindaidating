import 'package:flutter/material.dart';

class AvailabilityScreen extends StatelessWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Availability settings go here',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}
