import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final List<Map<String, String>> _recentReports = [
    {'id': 'R001', 'user': 'UserB', 'reason': 'Inappropriate content', 'status': 'Pending'},
    {'id': 'R002', 'user': 'UserC', 'reason': 'Spamming', 'status': 'Pending'},
  ];

  final List<Map<String, String>> _userStats = [
    {'metric': 'Total Users', 'value': '1,234'},
    {'metric': 'Active Users (24h)', 'value': '567'},
    {'metric': 'New Users (Today)', 'value': '42'},
    {'metric': 'Matches (Total)', 'value': '890'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: _userStats.length,
              itemBuilder: (context, index) {
                final stat = _userStats[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          stat['value']!,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stat['metric']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Text('Recent Reports', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            _recentReports.isEmpty
                ? const Text('No pending reports.', style: TextStyle(fontStyle: FontStyle.italic))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentReports.length,
                    itemBuilder: (context, index) {
                      final report = _recentReports[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text('Report ID: ${report['id']} - User: ${report['user']}'),
                          subtitle: Text('Reason: ${report['reason']} - Status: ${report['status']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () {
                              // View report details
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
