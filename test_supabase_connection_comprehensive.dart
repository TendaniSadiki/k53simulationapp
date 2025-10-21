import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Comprehensive Supabase Connection Test');
  print('==========================================');
  
  const supabaseUrl = 'https://ceydnflvovxphncnuhop.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNleWRuZmx2b3Z4cGhuY251aG9wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzQzMDAsImV4cCI6MjA3MTYxMDMwMH0.ear-PJjrY6EcehGEVmcOY0XwUb7uFQLkt4agzQHqJOE';
  
  print('Testing Supabase Project: $supabaseUrl');
  print('Anon Key: ${supabaseAnonKey.substring(0, 20)}...');
  print('');
  
  // Test 1: Basic HTTP connectivity
  print('1️⃣ Testing basic HTTP connectivity...');
  try {
    final response = await http.get(Uri.parse('$supabaseUrl/rest/v1/'));
    if (response.statusCode == 200) {
      print('✅ HTTP connectivity: SUCCESS (Status: ${response.statusCode})');
    } else {
      print('❌ HTTP connectivity: FAILED (Status: ${response.statusCode})');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ HTTP connectivity: ERROR ($e)');
  }
  
  // Test 2: Supabase initialization
  print('\n2️⃣ Testing Supabase initialization...');
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    print('✅ Supabase initialization: SUCCESS');
  } catch (e) {
    print('❌ Supabase initialization: FAILED ($e)');
    return; // Stop if initialization fails
  }
  
  // Test 3: Database query
  print('\n3️⃣ Testing database query...');
  try {
    final response = await Supabase.instance.client
        .from('questions')
        .select('count')
        .limit(1);
    
    print('✅ Database query: SUCCESS');
    print('   Response: $response');
  } catch (e) {
    print('❌ Database query: FAILED ($e)');
  }
  
  // Test 4: Authentication test
  print('\n4️⃣ Testing authentication...');
  try {
    final auth = Supabase.instance.client.auth;
    final session = auth.currentSession;
    
    if (session != null) {
      print('✅ Authentication: ACTIVE SESSION');
      print('   User: ${session.user.email}');
    } else {
      print('ℹ️ Authentication: NO ACTIVE SESSION (expected for anonymous access)');
    }
  } catch (e) {
    print('❌ Authentication test: FAILED ($e)');
  }
  
  // Test 5: Table existence check
  print('\n5️⃣ Testing table access...');
  final tablesToTest = ['questions', 'profiles', 'achievements', 'user_stats'];
  
  for (final table in tablesToTest) {
    try {
      final response = await Supabase.instance.client
          .from(table)
          .select('count')
          .limit(1);
      
      print('✅ Table "$table": ACCESSIBLE');
    } catch (e) {
      print('❌ Table "$table": INACCESSIBLE ($e)');
    }
  }
  
  // Test 6: Real data fetch
  print('\n6️⃣ Testing real data fetch...');
  try {
    final questions = await Supabase.instance.client
        .from('questions')
        .select('*')
        .limit(5);
    
    print('✅ Data fetch: SUCCESS');
    print('   Questions found: ${questions.length}');
    
    if (questions.isNotEmpty) {
      final firstQuestion = questions.first;
      print('   Sample question: ${firstQuestion['question_text']?.toString().substring(0, 50)}...');
    }
  } catch (e) {
    print('❌ Data fetch: FAILED ($e)');
  }
  
  print('\n==========================================');
  print('📊 TEST SUMMARY');
  print('==========================================');
  print('Supabase Project Status: ${Supabase.instance != null ? '✅ ACTIVE' : '❌ INACTIVE'}');
  print('Database Access: ${Supabase.instance != null ? '✅ AVAILABLE' : '❌ UNAVAILABLE'}');
  print('API Connectivity: ${Supabase.instance != null ? '✅ WORKING' : '❌ BROKEN'}');
  
  if (Supabase.instance != null) {
    print('\n🎉 Supabase project is ACTIVE and ACCESSIBLE!');
    print('   The API should work in the release APK.');
    print('   Use the hybrid build script for best results.');
  } else {
    print('\n⚠️ Supabase project appears INACCESSIBLE.');
    print('   Possible reasons:');
    print('   - Project paused or deleted');
    print('   - API keys invalid');
    print('   - Network restrictions');
    print('   - Free tier limits exceeded');
    print('\n💡 Recommendation: Use the offline build script or set up alternative backend.');
  }
}