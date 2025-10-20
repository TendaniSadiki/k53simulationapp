import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

// This script helps test the authentication and database integration
// Run with: dart scripts/run_auth_migration_test.dart

void main() async {
  print('🔧 K53 App Authentication Migration Test');
  print('========================================');
  
  // Check if .env file exists
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ .env file not found. Please create it with Supabase configuration.');
    return;
  }
  
  print('✅ .env file found');
  
  // Read environment variables
  final envContent = envFile.readAsStringSync();
  final supabaseUrl = _extractEnvVariable(envContent, 'SUPABASE_URL');
  final supabaseAnonKey = _extractEnvVariable(envContent, 'SUPABASE_ANON_KEY');
  
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    print('❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env file');
    return;
  }
  
  print('✅ Supabase configuration loaded');
  print('   - URL: ${supabaseUrl.substring(0, 20)}...');
  print('   - Anon Key: ${supabaseAnonKey.substring(0, 10)}...');
  
  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize Supabase: $e');
    return;
  }
  
  // Test database connection
  final client = Supabase.instance.client;
  try {
    final response = await client.from('profiles').select().limit(1);
    print('✅ Database connection successful');
    print('   - Profiles table accessible');
  } catch (e) {
    print('❌ Database connection failed: $e');
    print('💡 Please run the database migration: supabase/migrations/006_add_user_profile_fields.sql');
    return;
  }
  
  // Check if profiles table has required fields
  try {
    final testProfile = await client.from('profiles').select('email, full_name, phone, first_login').limit(1);
    print('✅ Profiles table structure check:');
    if (testProfile.isNotEmpty) {
      final sample = testProfile.first;
      print('   - email field: ${sample.containsKey('email') ? '✅' : '❌'}');
      print('   - full_name field: ${sample.containsKey('full_name') ? '✅' : '❌'}');
      print('   - phone field: ${sample.containsKey('phone') ? '✅' : '❌'}');
      print('   - first_login field: ${sample.containsKey('first_login') ? '✅' : '❌'}');
    }
  } catch (e) {
    print('❌ Profiles table structure check failed: $e');
    print('💡 Please run the database migration: supabase/migrations/006_add_user_profile_fields.sql');
  }
  
  print('\n⚠️  Important Note:');
  print('The migration script has been updated to remove the problematic UPDATE statement.');
  print('New users will have all fields populated automatically via the handle_new_user trigger.');
  print('Existing users may need manual updates if required.');
  
  print('\n📋 Migration Instructions:');
  print('1. Go to your Supabase dashboard');
  print('2. Navigate to SQL Editor');
  print('3. Copy and paste the contents of: supabase/migrations/006_add_user_profile_fields.sql');
  print('4. Run the migration');
  print('5. Test the signup functionality in the app');
  
  print('\n🔍 Next Steps:');
  print('1. Build the app: flutter build apk --release');
  print('2. Install on Android device');
  print('3. Test signup with phone number and verify data is saved');
  print('4. Check Supabase dashboard to confirm user profile creation');
}

String _extractEnvVariable(String content, String variableName) {
  final lines = content.split('\n');
  for (final line in lines) {
    if (line.startsWith('$variableName=')) {
      return line.substring('$variableName='.length).trim();
    }
  }
  return '';
}