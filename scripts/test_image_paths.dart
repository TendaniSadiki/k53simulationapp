import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  print('Testing K53 image paths and accessibility...\n');

  // Test the image paths referenced in the question database
  final imagePaths = [
    'assets/individual_signs/parking.png',
    'assets/individual_signs/stop_ahead.png',
  ];

  int successCount = 0;
  int totalCount = imagePaths.length;

  for (final imagePath in imagePaths) {
    final file = File(imagePath);
    final exists = file.existsSync();
    
    print('Testing: $imagePath');
    if (exists) {
      final size = file.lengthSync();
      print('✅ SUCCESS: File exists (${size} bytes)');
      successCount++;
    } else {
      print('❌ FAILED: File does not exist');
      
      // Check if directory exists
      final dir = Directory(path.dirname(imagePath));
      if (dir.existsSync()) {
        print('   Directory exists, but file is missing');
      } else {
        print('   Directory does not exist');
      }
    }
    print('');
  }

  print('Results:');
  print('$successCount/$totalCount image files are accessible');
  
  if (successCount == totalCount) {
    print('🎉 All image files are properly configured and accessible!');
    print('The K53 exam app should now display road sign images correctly.');
  } else {
    print('⚠️  Some image files are missing. Check the paths and file locations.');
  }
}