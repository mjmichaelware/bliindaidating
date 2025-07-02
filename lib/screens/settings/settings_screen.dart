// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

// Import the new modular settings widgets explicitly
import 'package:bliindaidating/screens/settings/widgets/dating_preferences_form.dart';
import 'package:bliindaidating/screens/settings/widgets/profile_visibility_settings.dart';
import 'package:bliindaidating/screens/settings/widgets/account_settings_form.dart';
import 'package:bliindaidating/screens/settings/widgets/notification_settings.dart';
import 'package:bliindaidating/screens/settings/widgets/privacy_data_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<GlobalKey<FormState>> _formKeys = List.generate(5, (_) => GlobalKey<FormState>());
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;

  // --- Dating Preferences State ---
  String? _preferredGender;
  RangeValues _ageRange = const RangeValues(18, 50);
  double _maxDistance = 100; // in miles

  // --- Profile Visibility State ---
  bool _showFullName = false;
  bool _showDisplayName = true;
  bool _showAge = true;
  bool _showGender = true;
  bool _showBio = true;
  bool _showSexualOrientation = true;
  bool _showHeight = true;
  bool _showInterests = true;
  bool _showLookingFor = true;
  bool _showLocation = true;

  // Tab Definitions
  static const List<Tab> _settingsTabs = <Tab>[
    Tab(text: 'Dating Preferences', icon: Icon(Icons.favorite)),
    Tab(text: 'Profile Visibility', icon: Icon(Icons.visibility)),
    Tab(text: 'Account', icon: Icon(Icons.manage_accounts)),
    Tab(text: 'Notifications', icon: Icon(Icons.notifications)),
    Tab(text: 'Privacy & Data', icon: Icon(Icons.security)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _settingsTabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadPreferences();
  }

  void _handleTabChange() {
    setState(() {});
  }

  Future<void> _loadPreferences() async {
    setState(() { _isLoading = true; });
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        debugPrint('SettingsScreen: No current user, redirecting to login.');
        context.go('/login');
      }
      return;
    }

    try {
      final UserProfile? userProfile = await _profileService.fetchUserProfile(currentUser.id);
      if (userProfile != null) {
        _preferredGender = 'Any';
        _ageRange = const RangeValues(20, 40);
        _maxDistance = 50;

        _showFullName = false;
        _showDisplayName = true;
        _showAge = true;
        _showGender = true;
        _showBio = true;
        _showSexualOrientation = true;
        _showHeight = true;
        _showInterests = true;
        _showLookingFor = true;
        _showLocation = true;
      }
      debugPrint('SettingsScreen: Preferences loaded (mock/initial)');
    } catch (e) {
      debugPrint('SettingsScreen: Error loading preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load settings: ${e.toString()}')),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _savePreferences() async {
    if (!_formKeys[_tabController.index].currentState!.validate()) {
      debugPrint('SettingsScreen: Validation failed for current tab.');
      return;
    }

    setState(() { _isLoading = true; });
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in!')),
        );
        context.go('/login');
      }
      setState(() { _isLoading = false; });
      return;
    }

    try {
      debugPrint('SettingsScreen: Saving preferences...');
      debugPrint('  Dating: Preferred Gender: $_preferredGender, Age: ${_ageRange.start.toInt()}-${_ageRange.end.toInt()}, Distance: ${_maxDistance.toInt()} miles');
      debugPrint('  Visibility: FullName: $_showFullName, DisplayName: $_showDisplayName, Age: $_showAge, etc.');

      await Future.delayed(const Duration(seconds: 1));
      debugPrint('SettingsScreen: Preferences saved successfully (mock)!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
      }
    } catch (e) {
      debugPrint('SettingsScreen: Error saving preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: ${e.toString()}')),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _onPreferredGenderChanged(String? newValue) { setState(() { _preferredGender = newValue; }); }
  void _onAgeRangeChanged(RangeValues newValues) { setState(() { _ageRange = newValues; }); }
  void _onMaxDistanceChanged(double newValue) { setState(() { _maxDistance = newValue; }); }

  void _onShowFullNameChanged(bool newValue) { setState(() { _showFullName = newValue; }); }
  void _onShowDisplayNameChanged(bool newValue) { setState(() { _showDisplayName = newValue; }); }
  void _onShowAgeChanged(bool newValue) { setState(() { _showAge = newValue; }); }
  void _onShowGenderChanged(bool newValue) { setState(() { _showGender = newValue; }); }
  void _onShowBioChanged(bool newValue) { setState(() { _showBio = newValue; }); }
  void _onShowSexualOrientationChanged(bool newValue) { setState(() { _showSexualOrientation = newValue; }); }
  void _onShowHeightChanged(bool newValue) { setState(() { _showHeight = newValue; }); }
  void _onShowInterestsChanged(bool newValue) { setState(() { _showInterests = newValue; }); }
  void _onShowLookingForChanged(bool newValue) { setState(() { _showLookingFor = newValue; }); }
  void _onShowLocationChanged(bool newValue) { setState(() { _showLocation = newValue; }); }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    final Color primaryColor = isDarkMode ? Colors.deepPurpleAccent : Colors.blue.shade700;
    final Color secondaryColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color accentColor = isDarkMode ? Colors.cyanAccent : Colors.orangeAccent;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () {
            if (mounted) context.pop();
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _settingsTabs,
          labelColor: accentColor,
          unselectedLabelColor: textColor.withOpacity(0.7),
          indicatorColor: accentColor,
          labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
          isScrollable: true,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : TabBarView(
              controller: _tabController,
              children: [
                DatingPreferencesForm(
                  formKey: _formKeys[0],
                  preferredGender: _preferredGender,
                  ageRange: _ageRange,
                  maxDistance: _maxDistance,
                  onPreferredGenderChanged: _onPreferredGenderChanged,
                  onAgeRangeChanged: _onAgeRangeChanged,
                  onMaxDistanceChanged: _onMaxDistanceChanged,
                ),
                ProfileVisibilitySettings( // This is the widget causing the duplicate import error
                  formKey: _formKeys[1],
                  showFullName: _showFullName,
                  showDisplayName: _showDisplayName,
                  showAge: _showAge,
                  showGender: _showGender,
                  showBio: _showBio,
                  showSexualOrientation: _showSexualOrientation,
                  showHeight: _showHeight,
                  showInterests: _showInterests,
                  showLookingFor: _showLookingFor,
                  showLocation: _showLocation,
                  onShowFullNameChanged: _onShowFullNameChanged,
                  onShowDisplayNameChanged: _onShowDisplayNameChanged,
                  onShowAgeChanged: _onShowAgeChanged,
                  onShowGenderChanged: _onShowGenderChanged,
                  onShowBioChanged: _onShowBioChanged,
                  onShowSexualOrientationChanged: _onShowSexualOrientationChanged,
                  onShowHeightChanged: _onShowHeightChanged,
                  onShowInterestsChanged: _onShowInterestsChanged,
                  onShowLookingForChanged: _onShowLookingForChanged,
                  onShowLocationChanged: _onShowLocationChanged,
                ),
                AccountSettingsForm(formKey: _formKeys[2]),
                NotificationSettings(formKey: _formKeys[3]),
                PrivacyDataSettings(formKey: _formKeys[4]),
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        color: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _savePreferences,
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Save All Settings',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
          ),
        ),
      ),
    );
  }
}