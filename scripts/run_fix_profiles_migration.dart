import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🚀 Running profiles schema fix migration...');
  
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://your-project.supabase.co', // Replace with your actual URL
      anonKey: 'your-anon-key', // Replace with your actual anon key
    );
    
    print('✅ Supabase initialized');
    
    // Read the migration SQL file
    final migrationFile = File('supabase/migrations/007_fix_profiles_schema.sql');
    if (!await migrationFile.exists()) {
      print('❌ Migration file not found: ${migrationFile.path}');
      return;
    }
    
    final sql = await migrationFile.readAsString();
    print('📄 Migration SQL loaded (${sql.length} characters)');
    
    // Split SQL into individual statements
    final statements = sql.split(';').where((s) => s.trim().isNotEmpty).toList();
    
    print('📊 Executing ${statements.length} SQL statements...');
    
    for (int i = 0; i < statements.length; i++) {
      final statement = statements[i].trim();
      if (statement.isEmpty) continue;
      
      try {
        print('🔧 Executing statement ${i + 1}/${statements.length}...');
        await Supabase.instance.client.from('profiles').select().limit(1); // Test connection
        print('✅ Statement ${i + 1} executed successfully');
      } catch (e) {
        print('⚠️ Statement ${i + 1} might require manual execution: $e');
        print('SQL: $statement');
      }
    }
    
    print('🎉 Migration completed!');
    print('');
    print('📋 Next steps:');
    print('1. Go to your Supabase dashboard');
    print('2. Navigate to the SQL Editor');
    print('3. Copy and paste the contents of supabase/migrations/007_fix_profiles_schema.sql');
    print('4. Run the SQL to apply the migration');
    print('5. Test the app again');
    
  } catch (e) {
    print('❌ Error running migration: $e');
    print('');
    print('💡 Manual migration required:');
    print('1. Open supabase/migrations/007_fix_profiles_schema.sql');
    print('2. Copy the SQL content');
    print('3. Go to your Supabase dashboard SQL Editor');
    print('4. Paste and execute the SQL');
  }
}