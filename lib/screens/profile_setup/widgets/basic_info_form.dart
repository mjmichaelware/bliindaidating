// lib/screens/profile_setup/widgets/basic_info_form.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class BasicInfoForm extends StatefulWidget {
  final TextEditingController fullNameController;
  final TextEditingController displayNameController;
  final TextEditingController heightController;
  final Function(DateTime?) onDateOfBirthSelected;
  final Function(String?) onGenderChanged;
  final DateTime? dateOfBirth;
  final String? gender;
  final GlobalKey<FormState> formKey; // Receive the form key from parent

  const BasicInfoForm({
    super.key,
    required this.fullNameController,
    required this.displayNameController,
    required this.heightController,
    required this.onDateOfBirthSelected,
    required this.onGenderChanged,
    this.dateOfBirth,
    this.gender,
    required this.formKey,
  });

  @override
  State<BasicInfoForm> createState() => _BasicInfoFormState();
}

class _BasicInfoFormState extends State<BasicInfoForm> {
  final List<String> _genders = [
    'Male', 'Female', 'Non-binary', 'Transgender Male', 'Transgender Female',
    'Genderqueer', 'Genderfluid', 'Agender', 'Bigender', 'Two-Spirit',
    'Demigirl', 'Demiboy', 'Intersex', 'Other', 'Prefer not to say'
  ];

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Must be at least 18
    );
    if (picked != null && picked != widget.dateOfBirth) {
      widget.onDateOfBirthSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form( // Each tab now has its own Form, but uses the parent's key
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: widget.fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Legal Name',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.badge),
              hintText: 'As per your legal documents',
              hintStyle: TextStyle(fontFamily: 'Inter', color: Theme.of(context).hintColor),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full legal name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.displayNameController,
            decoration: InputDecoration(
              labelText: 'Display Name (Nickname)',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
              hintText: 'How you want to appear in the app',
              hintStyle: TextStyle(fontFamily: 'Inter', color: Theme.of(context).hintColor),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a display name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(
              widget.dateOfBirth == null
                  ? 'Select Date of Birth (Age 18+ Required)'
                  : 'Date of Birth: ${DateFormat('yyyy-MM-dd').format(widget.dateOfBirth!)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Inter'),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDateOfBirth(context),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: widget.gender,
            decoration: InputDecoration(
              labelText: 'Gender Identity',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.transgender),
              hintStyle: TextStyle(fontFamily: 'Inter', color: Theme.of(context).hintColor),
            ),
            items: _genders.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender, style: const TextStyle(fontFamily: 'Inter')),
              );
            }).toList(),
            onChanged: (String? newValue) {
              widget.onGenderChanged(newValue);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your gender identity.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.heightController,
            decoration: InputDecoration(
              labelText: 'Height (in cm or inches)',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.height),
              hintText: 'e.g., 175 cm or 5\' 9"',
              hintStyle: TextStyle(fontFamily: 'Inter', color: Theme.of(context).hintColor),
            ),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your height.';
              }
              // A more robust height parser/validator can be added here if needed.
              return null;
            },
          ),
        ],
      ),
    );
  }
}