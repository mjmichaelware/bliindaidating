import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _feedbackType = 'general';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> _feedbackTypes = ['general', 'bug', 'feature_request'];

  void _submitFeedback() async {
    if (_formKey.currentState?.validate() ?? false) {
      print('Submitting feedback: Type: $_feedbackType, Message: ${_messageController.text}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted (mock)!')),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Help us improve!', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _feedbackType,
                decoration: const InputDecoration(labelText: 'Feedback Type'),
                items: _feedbackTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _feedbackType = newValue;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Your Message',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Message cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text('Submit Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
