import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  print('=== Session Database Verification ===');
  
  // Check if session database tables exist in the SQLite database
  final dbPath = path.join(Directory.current.path, 'k53app.db');
  final dbFile = File(dbPath);
  
  if (await dbFile.exists()) {
    print('✓ Database file exists: $dbPath');
    
    // Check if session tables exist by querying sqlite_master
    final result = Process.runSync('sqlite3', [dbPath, '.tables']);
    
    if (result.exitCode == 0) {
      final tables = result.stdout.toString();
      print('✓ Database tables:');
      print(tables);
      
      // Check for session-related tables
      if (tables.contains('sessions')) {
        print('✓ sessions table exists');
      } else {
        print('✗ sessions table missing');
      }
      
      if (tables.contains('session_questions')) {
        print('✓ session_questions table exists');
      } else {
        print('✗ session_questions table missing');
      }
      
      if (tables.contains('session_answers')) {
        print('✓ session_answers table exists');
      } else {
        print('✗ session_answers table missing');
      }
    } else {
      print('✗ Failed to query database: ${result.stderr}');
    }
  } else {
    print('✗ Database file does not exist: $dbPath');
    print('The database will be created when the app runs for the first time');
  }
  
  print('\n=== Verification Complete ===');
}