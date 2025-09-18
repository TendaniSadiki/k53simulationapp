import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  print('=== DEBUGGING OFFLINE IMAGE PATHS ===\n');
  
  // Check if the offline database exists
  final databasesDir = Directory('build/databases');
  if (!databasesDir.existsSync()) {
    print('❌ Offline databases directory does not exist!');
    print('Run the app first to initialize the offline database.');
    return;
  }
  
  final dbFiles = databasesDir.listSync();
  FileSystemEntity? k53Db;
  for (final file in dbFiles) {
    if (file.path.contains('k53_questions.db')) {
      k53Db = file;
      break;
    }
  }
  
  if (k53Db == null) {
    print('❌ k53_questions.db not found in build/databases/');
    print('Available database files:');
    for (final file in dbFiles) {
      print('  - ${path.basename(file.path)}');
    }
    return;
  }
  
  print('✅ Found offline database: ${path.basename(k53Db.path)}');
  
  // Check if the assets directory exists
  final assetsDir = Directory('assets/individual_signs');
  if (!assetsDir.existsSync()) {
    print('❌ Assets directory does not exist: assets/individual_signs/');
    return;
  }
  
  final imageFiles = assetsDir.listSync();
  print('✅ Found ${imageFiles.length} image files in assets/individual_signs/');
  
  // Check for specific vehicle control images
  final vehicleControlImages = ['code1.png', 'code2.png', 'code3.png'];
  print('\n=== VEHICLE CONTROL IMAGES CHECK ===');
  
  for (final imageName in vehicleControlImages) {
    final imagePath = 'assets/individual_signs/$imageName';
    final imageFile = File(imagePath);
    final exists = imageFile.existsSync();
    
    print('${exists ? '✅' : '❌'} $imagePath: ${exists ? 'FOUND' : 'MISSING'}');
    
    if (!exists) {
      // Try to find similar files
      final similarFiles = imageFiles.where((file) {
        final fileName = path.basename(file.path).toLowerCase();
        return fileName.contains(imageName.toLowerCase().replaceAll('.png', ''));
      }).toList();
      
      if (similarFiles.isNotEmpty) {
        print('   Similar files found:');
        for (final file in similarFiles) {
          print('     - ${path.basename(file.path)}');
        }
      }
    }
  }
  
  print('\n=== IMAGE PATH VALIDATION ===');
  print('Testing image path loading with Image.asset():');
  
  // Test paths that should work with Image.asset()
  final testPaths = [
    'assets/individual_signs/code1.png',
    'assets/individual_signs/code2.png', 
    'assets/individual_signs/code3.png',
  ];
  
  for (final testPath in testPaths) {
    final file = File(testPath);
    final exists = file.existsSync();
    print('${exists ? '✅' : '❌'} $testPath: ${exists ? 'EXISTS' : 'MISSING'}');
    
    if (exists) {
      // Check if it's a valid PNG file
      try {
        final bytes = file.readAsBytesSync();
        final isPng = bytes.length > 8 && 
                      bytes[0] == 0x89 && 
                      bytes[1] == 0x50 && 
                      bytes[2] == 0x4E && 
                      bytes[3] == 0x47;
        print('   PNG signature: ${isPng ? 'VALID' : 'INVALID'}');
        print('   File size: ${bytes.length} bytes');
      } catch (e) {
        print('   Error reading file: $e');
      }
    }
  }
  
  print('\n=== TROUBLESHOOTING ===');
  print('1. Make sure pubspec.yaml includes the assets:');
  print('   flutter:');
  print('     assets:');
  print('       - assets/individual_signs/');
  print('');
  print('2. Run "flutter pub get" after adding assets');
  print('3. Restart the app completely (not just hot reload)');
  print('4. Check that the offline database was populated with the new questions');
  print('5. Verify the exam screen is using the correct category filter');
}