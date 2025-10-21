import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('Testing Supabase Connection...');
  
  const supabaseUrl = 'https://ceydnflvovxphncnuhop.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNleWRuZmx2b3Z4cGhuY251aG9wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzQzMDAsImV4cCI6MjA3MTYxMDMwMH0.ear-PJjrY6EcehGEVmcOY0XwUb7uFQLkt4agzQHqJOE';
  
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    
    print('✅ Supabase initialized successfully!');
    
    // Test a simple query
    final response = await Supabase.instance.client
        .from('profiles')
        .select('count')
        .limit(1);
    
    print('✅ Database query successful!');
    print('Response: $response');
    
  } catch (e) {
    print('❌ Supabase connection failed: $e');
    print('This indicates the Supabase project may not be accessible.');
  }
}