import 'package:flutter/material.dart';

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({super.key});

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  void _loadMatches() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Matches')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No matches yet! Keep exploring.', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.all(16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(radius: 40, backgroundImage: NetworkImage('https://placehold.co/80x80/000000/ffffff?text=Match1')),
                          SizedBox(height: 8),
                          Text('Match Name 1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Matched on: 2025-06-26', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          SizedBox(height: 16),
                          ElevatedButton(onPressed: () {}, child: const Text('View Profile')),
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
