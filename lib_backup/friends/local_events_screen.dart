// lib/friends/local_events_screen.dart
import 'package:flutter/material.dart';

class LocalEventsScreen extends StatefulWidget {
  final List<dynamic> events; // ADDED: Required named parameter 'events'

  const LocalEventsScreen({super.key, required this.events}); // ADDED: required this.events

  @override
  State<LocalEventsScreen> createState() => _LocalEventsScreenState();
}

class _LocalEventsScreenState extends State<LocalEventsScreen> {
  List<String> displayEvents = [];

  @override
  void initState() {
    super.initState();
    if (widget.(events ?? []).isNotEmpty) {
      displayEvents = List<String>.from(widget.events);
    } else {
      // If no events are passed, maybe load some dummy data or from a service
      displayEvents = ['No upcoming events available.'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Events')),
      body: Center(
        child: (displayEvents ?? []).isEmpty
            ? const Text('No local events found.')
            : ListView.builder(
                itemCount: displayEvents.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(displayEvents[index]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}