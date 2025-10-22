import 'dart:convert';
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  // Supabase configuration from .env file
  const supabaseUrl = 'https://ceydnflvovxphncnuhop.supabase.co';
  const supabaseServiceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNleWRuZmx2b3Z4cGhuY251aG9wIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjAzNDMwMCwiZXhwIjoyMDcxNjEwMzAwfQ.HsJ2B8YDpoEdrMx3OHbQg3DLmfIcUgK5QA51aj4M3H0';

  try {
    // Initialize Supabase client
    final supabase = SupabaseClient(supabaseUrl, supabaseServiceRoleKey);

    print('Connected to Supabase successfully!');

    // Read the SQL file
    final sqlFile = File('scripts/road_sign_questions_output.sql');
    if (!await sqlFile.exists()) {
      print('Error: SQL file not found at scripts/road_sign_questions_output.sql');
      exit(1);
    }

    final sqlContent = await sqlFile.readAsString();
    print('Read SQL file successfully (${sqlContent.length} characters)');

    // Split the SQL into individual statements
    final statements = sqlContent.split(';').where((stmt) => stmt.trim().isNotEmpty).toList();

    print('Executing ${statements.length} SQL statements...');

    // Execute each statement
    for (var i = 0; i < statements.length; i++) {
      final statement = statements[i].trim();
      if (statement.isEmpty) continue;

      print('\nExecuting statement ${i + 1}:');
      print('${statement.substring(0, 100)}${statement.length > 100 ? '...' : ''}');

      try {
        if (statement.toLowerCase().startsWith('select')) {
          // For SELECT statements, use query
          final result = await supabase.from('questions').select().execute();
          if (result.error != null) {
            print('Error executing statement ${i + 1}: ${result.error!.message}');
          } else {
            print('Query executed successfully: ${result.data.length} rows returned');
          }
        } else if (statement.toLowerCase().startsWith('insert')) {
          // For INSERT statements, we need to use raw SQL via RPC or direct execution
          // Since Supabase Dart client doesn't support raw SQL directly, we'll use the REST API approach
          // For now, we'll just print the statement since we can't execute raw SQL easily
          print('INSERT statement detected (cannot execute raw SQL via Dart client)');
          print('Please execute this SQL directly in the Supabase SQL editor:');
          print(statement);
        } else {
          // For other statements, try to execute
          print('Unsupported statement type: ${statement.split(' ')[0]}');
        }
      } catch (e) {
        print('Error executing statement ${i + 1}: $e');
      }
    }

    print('\nSQL execution completed!');
    print('\nTo complete the insertion, please:');
    print('1. Go to your Supabase dashboard at https://app.supabase.com/');
    print('2. Select your project');
    print('3. Go to the SQL Editor');
    print('4. Copy and paste the content from scripts/road_sign_questions_output.sql');
    print('5. Click "Run" to execute the SQL');

  } catch (e) {
    print('Error connecting to Supabase: $e');
    print('\nAlternative approach:');
    print('1. Copy the content from scripts/road_sign_questions_output.sql');
    print('2. Go to https://app.supabase.com/ and login');
    print('3. Select your project and go to SQL Editor');
    print('4. Paste the SQL and click "Run"');
  }
}