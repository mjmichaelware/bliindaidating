// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

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
  late final ProfileService _profileService;

  bool _isLoading = true;
  UserProfile? _userProfile;

  // --- Dating Preferences State ---
  String? _preferredGender;
  RangeValues _ageRange = const RangeValues(18, 50);
  double _maxDistance = 100; // in miles

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
    _profileService = ProfileService(Supabase.instance.client);
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
      final userProfile = await _profileService.fetchUserProfile(id: currentUser.id);
      if (userProfile != null) {
        setState(() {
          _userProfile = userProfile;
          // Load dating preferences from a separate table or from userProfile if they exist there
          _preferredGender = userProfile.datingPreferences?['preferredGender'] as String? ?? 'Any';
          _ageRange = userProfile.datingPreferences?['ageRange'] != null
              ? RangeValues(
                  (userProfile.datingPreferences!['ageRange'] as List)[0].toDouble(),
                  (userProfile.datingPreferences!['ageRange'] as List)[1].toDouble(),
                )
              : const RangeValues(20, 40);
          _maxDistance = (userProfile.datingPreferences?['maxDistance'] as double? ?? 50.0);
        });
      }
      debugPrint('SettingsScreen: Preferences loaded.');
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
    if (_userProfile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User profile not loaded!')),
        );
      }
      setState(() { _isLoading = false; });
      return;
    }

    try {
      debugPrint('SettingsScreen: Saving preferences...');
      // Prepare a map of dating preferences to save
      final datingPreferencesToSave = {
        'preferredGender': _preferredGender,
        'ageRange': [_ageRange.start.toInt(), _ageRange.end.toInt()],
        'maxDistance': _maxDistance.toInt(),
      };
      
      // Update the local profile object with new dating preferences
      final updatedProfile = _userProfile!.copyWith(
        datingPreferences: datingPreferencesToSave,
      );

      // Call the service to update the profile in the database
      await _profileService.updateProfile(profile: updatedProfile);

      debugPrint('SettingsScreen: Preferences saved successfully!');
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

  // --- Callbacks for child widgets to update parent state ---
  void _onPreferredGenderChanged(String? newValue) { setState(() { _preferredGender = newValue; }); }
  void _onAgeRangeChanged(RangeValues newValues) { setState(() { _ageRange = newValues; }); }
  void _onMaxDistanceChanged(double newValue) { setState(() { _maxDistance = newValue; }); }

  void _onProfileVisibilityChanged(Map<String, bool> newPrefs) {
    if (_userProfile != null) {
      setState(() {
        _userProfile = _userProfile!.copyWith(profileVisibilityPreferences: newPrefs);
      });
    }
  }

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

    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color accentColor = isDarkMode ? AppConstants.accentColor : AppConstants.lightAccentColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color iconColor = isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor;

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
                ProfileVisibilitySettings(
                  formKey: _formKeys[1],
                  profile: _userProfile!,
                  onVisibilityChange: _onProfileVisibilityChanged,
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
                    child: CircularProgressIndicator(color: Colors.white)
                  )
                : const Text('Save Settings'),
          ),
        ),
      ),
    );
  }
}