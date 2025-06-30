import 'package:flutter/material.dart';

class PenaltyDisplayScreen extends StatelessWidget {
  const PenaltyDisplayScreen({super.key});

  final List<Map<String, dynamic>> _penalties = const [
    {
      'reason': 'Missed Date',
      'date': '2025-06-15',
      'penaltyPoints': 5,
    },
    {
      'reason': 'Late Arrival',
      'date': '2025-06-20',
      'penaltyPoints': 3,
    },
    {
      'reason': 'No Show',
      'date': '2025-06-25',
      'penaltyPoints': 10,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penalty Details'),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: _penalties.isEmpty
          ? const Center(
              child: Text(
                'No penalties recorded.',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _penalties.length,
              itemBuilder: (context, index) {
                final penalty = _penalties[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade800.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurpleAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        penalty['reason'] ?? 'Unknown Reason',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Date: ${penalty['date'] ?? 'Unknown'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Penalty Points: ${penalty['penaltyPoints'] ?? 0}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
