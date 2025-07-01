import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  String? _selectedGenderPreference;
  RangeValues _ageRange = const RangeValues(18, 50);
  double _maxDistance = 100;

  final List<String> _genderOptions = ['Male', 'Female', 'Non-binary', 'Any'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  void _savePreferences() async {
    print('Saving preferences: Gender: $_selectedGenderPreference, Age: ${_ageRange.start}-${_ageRange.end}, Distance: $_maxDistance km');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved (mock)!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dating Preferences', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text('Preferred Gender'),
                    trailing: DropdownButton<String>(
                      value: _selectedGenderPreference ?? 'Any',
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGenderPreference = newValue;
                        });
                      },
                      items: _genderOptions.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                    ),
                  ),
                  ListTile(
                    title: Text('Age Range: ${_ageRange.start.toInt()} - ${_ageRange.end.toInt()}'),
                    subtitle: RangeSlider(
                      values: _ageRange,
                      min: 18,
                      max: 99,
                      divisions: 81,
                      labels: RangeLabels(
                        _ageRange.start.toInt().toString(),
                        _ageRange.end.toInt().toString(),
                      ),
                      onChanged: (RangeValues newValues) {
                        setState(() {
                          _ageRange = newValues;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Max Distance: ${_maxDistance.toInt()} km'),
                    subtitle: Slider(
                      value: _maxDistance,
                      min: 10,
                      max: 500,
                      divisions: 49,
                      label: _maxDistance.toInt().toString(),
                      onChanged: (double newValue) {
                        setState(() {
                          _maxDistance = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _savePreferences,
                      child: const Text('Save Preferences'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
