import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/data/dummy_data.dart'; // Import dummy data
import 'package:image_picker/image_picker.dart'; // Import XFile for web compatibility

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetches a user profile by ID.
  // This method will now prioritize dummy data if a matching dummy ID is found.
  Future<UserProfile?> fetchUserProfile(String id) async {
    // --- First, try to find in dummy data ---
    try {
      final dummyProfile = dummyDiscoveryProfiles.firstWhere(
        (profile) => profile.id == id,
      );
      print('ProfileService: Found dummy profile for ID: $id');
      return dummyProfile;
    } catch (e) {
      // If not found in dummy data, proceed to Supabase
      print('ProfileService: Dummy profile not found for ID: $id. Attempting Supabase fetch.');
    }

    // --- If not found in dummy data, attempt to fetch from Supabase ---
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', id)
          .single();

      if (response != null) {
        return UserProfile.fromJson(response);
      }
      return null;
    } on PostgrestException catch (e) {
      print('ProfileService: Error fetching user profile from Supabase: ${e.message}');
      // It's crucial to handle cases where the user ID might not exist in Supabase
      // or if there are RLS issues.
      return null;
    } catch (e) {
      print('ProfileService: General error fetching user profile: $e');
      return null;
    }
  }

  // FIXED: Changed parameter type from File to XFile? for web compatibility
  Future<String> uploadAnalysisPhoto(String id, XFile? imageFile) async {
    print('ProfileService: Dummy photo upload for id: $id, image: ${imageFile?.name ?? 'null'}');
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 1));
    // Return a dummy URL. Replace with actual Supabase Storage upload logic later.
    // For a real implementation on web, you'd work with imageFile.readAsBytes()
    return 'https://placehold.co/200x200/ff0000/white?text=UPLOADED';
  }

  // Placeholder for createOrUpdateProfile method
  // This is a stub to satisfy calls from profile_setup_screen and about_me_screen.
  // You will need to implement the actual Supabase database insert/update logic here later.
  Future<void> createOrUpdateProfile({required UserProfile profile}) async {
    print('ProfileService: Dummy create/update profile for ${profile.id}');
    // Simulate database operation delay
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Implement actual Supabase upsert logic (insert if new, update if exists)
    // Example:
    // await _supabase.from('profiles').upsert(profile.toJson());
  }

  // Example: Method to check if a profile is complete
  Future<bool> isProfileComplete(String id) async {
    // For dummy data scenario, you might always return true or false,
    // or you could check if the id exists in dummyDiscoveryProfiles
    // if (!dummyDiscoveryProfiles.any((p) => p.id == id)) {
    //   // If not a dummy profile, try Supabase
    // }
    try {
      final response = await _supabase
          .from('profiles')
          .select('profile_complete')
          .eq('id', id)
          .single();

      if (response != null && response['profile_complete'] == true) {
        return true;
      }
      return false;
    } on PostgrestException catch (e) {
      print('Error checking profile completion: ${e.message}');
      return false;
    } catch (e) {
      print('General error checking profile completion: $e');
      return false;
    }
  }
}