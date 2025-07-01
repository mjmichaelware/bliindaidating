// lib/screens/discovery/discovery_screen.dart
import 'package:flutter/material.dart';
import 'package:bliindaidating/shared/glowing_button.dart'; // Make sure this path is correct

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final List<String> interests = [
    'Art',
    'Music',
    'Travel',
    'Books',
    'Food',
    'Fitness',
    'Movies',
    'Technology',
    'Nature',
    'Gaming',
    'Cooking',
    'Photography',
  ];

  Set<String> selectedInterests = {};

  String searchQuery = '';

  List<String> get filteredInterests {
    if (searchQuery.isEmpty) return interests;
    return interests
        .where((i) => i.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  void saveInterests() {
    // TODO: Save to user profile preferences backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Interests saved: ${selectedInterests.join(', ')}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Interests'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade900,
      ),
      body: Stack(
        children: [
          // Background orb animation or color
          Container(color: Colors.black),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select your interests',
                    style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search interests...',
                      filled: true,
                      fillColor: Colors.deepPurple.shade800,
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: filteredInterests.isEmpty
                        ? Center(
                            child: Text(
                              'No interests found',
                              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white54),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 3,
                            ),
                            itemCount: filteredInterests.length,
                            itemBuilder: (context, index) {
                              final interest = filteredInterests[index];
                              final selected = selectedInterests.contains(interest);

                              return GestureDetector(
                                onTap: () => toggleInterest(interest),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.deepPurple.shade400
                                        : Colors.deepPurple.shade900.withAlpha(180),
                                    borderRadius: BorderRadius.circular(16),
                                    border: selected
                                        ? Border.all(color: Colors.pink.shade300, width: 2)
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    interest,
                                    style: TextStyle(
                                      color: selected ? Colors.white : Colors.white70,
                                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  GlowingButton(
                    icon: Icons.save_rounded,
                    text: 'Save Interests',
                    onPressed: selectedInterests.isEmpty ? null : saveInterests,
                    gradientColors: const [
                      Color(0xFF8E24AA),
                      Color(0xFFD32F2F),
                    ],
                    height: 48,
                    width: double.infinity,
                    textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                    disabled: selectedInterests.isEmpty, // This line is correct, fix is in GlowingButton.dart
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}