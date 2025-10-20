// Test script to verify user signup functionality and database schema
// Run this script to test if the SQL database setup and user signup work correctly

import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/src/core/services/supabase_service.dart';
import 'lib/src/core/services/database_service.dart';

void main() async {
  print('🧪 Testing User Signup Functionality');
  print('=====================================\n');

  try {
    // Initialize Supabase
    await SupabaseService.initialize();
    print('✅ Supabase initialized successfully');

    // Test database connection
    try {
      final testResult = await SupabaseService.client
          .from('profiles')
          .select('count')
          .limit(1);

      print('✅ Database connection successful');

      // Check if profiles table has the required fields
      final profileFields = await SupabaseService.client
          .from('profiles')
          .select('*')
          .limit(1);

      if (profileFields.isNotEmpty) {
        final sampleProfile = profileFields.first;
        print('📊 Current profile fields:');
        sampleProfile.forEach((key, value) {
          print('   - $key: $value');
        });

        // Check for required fields
        final requiredFields = ['full_name', 'phone', 'first_login'];
        final missingFields = requiredFields.where((field) => !sampleProfile.containsKey(field)).toList();

        if (missingFields.isNotEmpty) {
          print('\n⚠️ Missing profile fields: $missingFields');
          print('   Run the database migration to add these fields:');
          print('   supabase/migrations/006_add_user_profile_fields.sql');
        } else {
          print('\n✅ All required profile fields are present');
        }
      }
    } catch (e) {
      print('❌ Database connection failed: $e');
      return;
    }

    // Test user signup functionality
    print('\n🧪 Testing User Signup Process');
    print('-------------------------------');

    // Generate unique test credentials
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testEmail = 'testuser_$timestamp@example.com';
    final testPassword = 'testpassword123';
    final testFullName = 'Test User $timestamp';
    final testPhone = '+1234567890';

    print('Test credentials:');
    print('  Email: $testEmail');
    print('  Password: $testPassword');
    print('  Full Name: $testFullName');
    print('  Phone: $testPhone');

    try {
      // Attempt signup
      final signupResponse = await SupabaseService.client.auth.signUp(
        email: testEmail,
        password: testPassword,
        data: {
          'full_name': testFullName,
          'phone': testPhone,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      if (signupResponse.user != null) {
        print('\n✅ User signup successful');
        print('   User ID: ${signupResponse.user!.id}');

        // Wait a moment for the trigger to create the profile
        await Future.delayed(Duration(seconds: 2));

        // Check if profile was created
        final profileResponse = await SupabaseService.client
            .from('profiles')
            .select('*')
            .eq('id', signupResponse.user!.id)
            .single();

        if (profileResponse != null) {
          final profile = profileResponse;
          print('\n✅ User profile created successfully');
          print('📊 Profile details:');
          print('   - ID: ${profile['id']}');
          print('   - Email: ${profile['email']}');
          print('   - Full Name: ${profile['full_name']}');
          print('   - Phone: ${profile['phone']}');
          print('   - First Login: ${profile['first_login']}');
          print('   - Total Points: ${profile['total_points']}');
          print('   - Level: ${profile['level']}');

          // Verify the enhanced fields
          if (profile['full_name'] == testFullName && 
              profile['phone'] == testPhone && 
              profile['first_login'] == true) {
            print('\n🎉 Enhanced user profile fields working correctly!');
          } else {
            print('\n⚠️ Some profile fields may not be set correctly');
          }
        } else {
          print('\n❌ User profile not found after signup');
        }

        // Clean up: delete test user
        print('\n🧹 Cleaning up test user...');
        try {
          await SupabaseService.client.auth.admin.deleteUser(signupResponse.user!.id);
          print('✅ Test user cleaned up successfully');
        } catch (e) {
          print('⚠️ Could not delete test user (may require admin privileges): $e');
        }
      } else {
        print('\n❌ User signup failed: No user returned');
      }
    } catch (e) {
      print('\n❌ User signup failed: $e');
    }

  } catch (e) {
    print('\n❌ Test setup failed: $e');
  }

  print('\n=====================================');
  print('🧪 Test completed');
}