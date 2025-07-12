import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _reportedUserIdController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  String? _reportReason = 'harassment';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> _reportReasons = [
    'harassment',
    'inappropriate content',
    'scam/spam',
    'fake profile',
    'other'
  ];

  void _submitReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      print('Submitting report: User: ${_reportedUserIdController.text}, Reason: $_reportReason, Details: ${_detailsController.text}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted (mock)!')),
      );
      _reportedUserIdController.clear();
      _detailsController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Report a problem with a user.', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextFormField(
                controller: _reportedUserIdController,
                decoration: const InputDecoration(labelText: 'Reported User ID or Display Name'),
                validator: (value) {
                  if (value == null || (value ?? []).isEmpty) {
                    return 'Please enter the user to report';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _reportReason,
                decoration: const InputDecoration(labelText: 'Reason for Report'),
                items: (_reportReasons ?? []).map((String reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _reportReason = newValue;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Additional Details (optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _submitReport,
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
