import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;

void main() async {
  // Initialize sqflite for Dart
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  try {
    // Get the database path
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, 'k53_questions.db');
    
    print('Checking offline database at: $dbPath');
    
    if (!File(dbPath).existsSync()) {
      print('❌ Offline database does not exist yet!');
      print('Run the app first to initialize the offline database.');
      return;
    }

    // Open the database
    final db = await openDatabase(dbPath);
    
    // Check if questions table exists
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    final tableNames = tables.map((row) => row['name'] as String).toList();
    
    if (!tableNames.contains('questions')) {
      print('❌ Questions table does not exist in offline database!');
      await db.close();
      return;
    }

    // Get all questions with image URLs
    final questions = await db.query(
      'questions',
      where: 'image_url IS NOT NULL',
    );

    print('\n=== QUESTIONS WITH IMAGE URLS IN OFFLINE DATABASE ===');
    print('Found ${questions.length} questions with image URLs');

    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];
      print('\nQuestion ${i + 1}:');
      print('  ID: ${question['id']}');
      print('  Category: ${question['category']}');
      print('  Image URL: ${question['image_url']}');
      print('  Question: ${question['question_text']}');
      
      // Check if the image file actually exists
      final imageUrl = question['image_url'] as String?;
      if (imageUrl != null) {
        final imageFile = File(imageUrl);
        final exists = imageFile.existsSync();
        print('  Image file exists: $exists');
        if (!exists) {
          print('  ❌ MISSING IMAGE: $imageUrl');
        }
      }
    }

    // Get vehicle control questions specifically
    final vehicleControlQuestions = await db.query(
      'questions',
      where: 'category = ? AND image_url IS NOT NULL',
      whereArgs: ['vehicle_controls'],
    );

    print('\n=== VEHICLE CONTROL QUESTIONS WITH IMAGES ===');
    print('Found ${vehicleControlQuestions.length} vehicle control questions with images');
    
    for (var i = 0; i < vehicleControlQuestions.length; i++) {
      final question = vehicleControlQuestions[i];
      print('\nVehicle Control Question ${i + 1}:');
      print('  ID: ${question['id']}');
      print('  Image URL: ${question['image_url']}');
      print('  Question: ${question['question_text']}');
      
      final imageUrl = question['image_url'] as String?;
      if (imageUrl != null) {
        final imageFile = File(imageUrl);
        final exists = imageFile.existsSync();
        print('  Image file exists: $exists');
      }
    }

    await db.close();
    print('\n✅ Debug completed successfully!');

  } catch (e) {
    print('❌ Error debugging offline database: $e');
  }
}