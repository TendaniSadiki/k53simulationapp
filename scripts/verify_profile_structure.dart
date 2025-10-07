import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🔍 Checking Profile Table Structure...\n');
  
  try {
    // Initialize Supabase (you'll need to add your credentials)
    // This is just a template - you'll need to configure with your actual Supabase URL and anon key
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
    
    final client = Supabase.instance.client;
    
    // Check if profiles table exists and get its structure
    final result = await client
        .from('profiles')
        .select('*')
        .limit(1);
    
    if (result.isEmpty) {
      print('❌ Profiles table is empty or does not exist');
      return;
    }
    
    print('✅ Profiles table exists');
    
    // Check for specific columns
    final sampleProfile = result[0];
    final columns = sampleProfile.keys.toList();
    
    print('\n📊 Current Profile Table Columns:');
    for (final column in columns) {
      print('   - $column: ${sampleProfile[column]}');
    }
    
    // Check for new fields
    final hasFullName = columns.contains('full_name');
    final hasPhone = columns.contains('phone');
    final hasFirstLogin = columns.contains('first_login');
    
    print('\n🔍 New Field Status:');
    print('   - full_name: ${hasFullName ? '✅ EXISTS' : '❌ MISSING'}');
    print('   - phone: ${hasPhone ? '✅ EXISTS' : '❌ MISSING'}');
    print('   - first_login: ${hasFirstLogin ? '✅ EXISTS' : '❌ MISSING'}');
    
    if (!hasFullName || !hasPhone || !hasFirstLogin) {
      print('\n⚠️  ACTION REQUIRED:');
      print('   Run the database migration script: scripts/add_user_profile_fields.sql');
      print('   in your Supabase SQL Editor to add the missing fields.');
    } else {
      print('\n🎉 All new profile fields are available!');
      print('   User registration will save full_name, phone, and first_login data.');
    }
    
  } catch (e) {
    print('❌ Error checking database structure: $e');
    print('\n💡 Make sure to:');
    print('   1. Configure Supabase credentials in this script');
    print('   2. Check your internet connection');
    print('   3. Verify your Supabase project is running');
  }
}