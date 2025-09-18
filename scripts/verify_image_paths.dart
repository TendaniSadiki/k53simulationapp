import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  print('Verifying road sign image paths...\n');
  
  // List of expected image paths from the mapping
  final expectedImages = [
    'assets/individual_signs/Maximum speed limit allowed.png',
    'assets/individual_signs/No stopping to ensure traffic flow and prevent dri.png',
    'assets/individual_signs/Overtaking prohibited for the next 2km.png',
    'assets/individual_signs/No over taking vehicles by goods vehicles for the next 500m.png',
    'assets/individual_signs/Over taking vehicles is prohibited for the next 500m.png',
    'assets/individual_signs/Indicates that you must yield to other traffic. Gi.png',
    'assets/individual_signs/Residential area.png',
    'assets/individual_signs/Parking only if you pay the parking fee.png',
    'assets/individual_signs/Parking_30min_Week_09-16_Sat_08-13.png.png',
    'assets/individual_signs/Parking here is reserved for a vehicle carrying people with disabilities.png',
  ];

  int missingCount = 0;
  int foundCount = 0;

  print('Checking image files:');
  print('=' * 50);
  
  for (final imagePath in expectedImages) {
    final file = File(imagePath);
    if (file.existsSync()) {
      print('✓ FOUND: $imagePath');
      foundCount++;
    } else {
      print('✗ MISSING: $imagePath');
      missingCount++;
    }
  }

  print('\n' + '=' * 50);
  print('Results:');
  print('Found: $foundCount images');
  print('Missing: $missingCount images');
  
  if (missingCount > 0) {
    print('\n⚠️  Warning: Some images are missing from the assets directory!');
    print('Please ensure all referenced images exist in assets/individual_signs/');
  } else {
    print('\n✅ All image paths are valid!');
  }

  // Also check the assets directory structure
  print('\nChecking assets directory structure...');
  final assetsDir = Directory('assets/individual_signs');
  if (assetsDir.existsSync()) {
    final files = assetsDir.listSync();
    final imageFiles = files.where((file) => 
        file is File && file.path.endsWith('.png')).toList();
    
    print('Found ${imageFiles.length} PNG files in assets/individual_signs/');
    
    // List all files to help identify naming issues
    if (imageFiles.isNotEmpty) {
      print('\nAvailable images:');
      for (final file in imageFiles) {
        final fileName = path.basename(file.path);
        print('  - $fileName');
      }
    }
  } else {
    print('❌ assets/individual_signs/ directory does not exist!');
  }
}