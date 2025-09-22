import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  print('=== ANALYZING IMAGE PATHS AND QUESTION MAPPING ===\n');

  // Check assets directory structure
  final assetsDir = Directory('assets/individual_signs');
  if (!assetsDir.existsSync()) {
    print('❌ Assets directory does not exist: assets/individual_signs/');
    return;
  }

  // Get all image files recursively
  final imageFiles = assetsDir.listSync(recursive: true).whereType<File>().toList();
  final imagePaths = imageFiles.map((file) => file.path).toList();

  print('✅ Found ${imagePaths.length} image files in assets/individual_signs/');
  
  // Check for subdirectories
  final subDirs = assetsDir.listSync().whereType<Directory>().toList();
  print('Found ${subDirs.length} subdirectories:');
  for (final dir in subDirs) {
    final dirName = p.basename(dir.path);
    final dirFiles = dir.listSync().whereType<File>().length;
    print('  - $dirName: $dirFiles files');
  }

  // Check for specific problematic image references from question database
  final problematicImages = [
    'assets/individual_signs/code1.png',
    'assets/individual_signs/code2.png',
    'assets/individual_signs/code3.png',
    'assets/individual_signs/Maximum speed limit allowed.png',
    'assets/individual_signs/Stop in line with the Stop sign or before the line.png',
    'assets/individual_signs/This area is reserved for parking.png',
  ];

  print('\n=== CHECKING PROBLEMATIC IMAGE REFERENCES ===');
  for (final imagePath in problematicImages) {
    final file = File(imagePath);
    final exists = file.existsSync();
    print('${exists ? '✅' : '❌'} $imagePath: ${exists ? 'EXISTS' : 'MISSING'}');
    
    if (!exists) {
      // Try to find similar files
      final similarFiles = imagePaths.where((path) {
        final fileName = p.basename(path).toLowerCase();
        final searchName = p.basename(imagePath).toLowerCase().replaceAll('.png', '');
        return fileName.contains(searchName);
      }).toList();
      
      if (similarFiles.isNotEmpty) {
        print('   Similar files found:');
        for (final similarFile in similarFiles.take(3)) {
          print('     - $similarFile');
        }
        if (similarFiles.length > 3) {
          print('     - ... and ${similarFiles.length - 3} more');
        }
      }
    }
  }

  // Check sign_page_ files (which should be excluded according to mapping document)
  final signPageFiles = imagePaths.where((path) => path.contains('sign_page_')).toList();
  print('\n=== SIGN_PAGE FILES (SHOULD BE EXCLUDED) ===');
  print('Found ${signPageFiles.length} sign_page_ files');
  if (signPageFiles.isNotEmpty) {
    print('First 10 sign_page files:');
    for (final file in signPageFiles.take(10)) {
      print('  - ${p.basename(file)}');
    }
    if (signPageFiles.length > 10) {
      print('  - ... and ${signPageFiles.length - 10} more');
    }
  }

  // Check descriptive named files (which should be used according to mapping document)
  final descriptiveFiles = imagePaths.where((path) {
    final fileName = p.basename(path);
    return !fileName.contains('sign_page_') && 
           !fileName.contains('code') &&
           fileName.length > 10; // Filter out very short names
  }).toList();

  print('\n=== DESCRIPTIVE NAMED FILES (SHOULD BE USED) ===');
  print('Found ${descriptiveFiles.length} descriptive named files');
  if (descriptiveFiles.isNotEmpty) {
    print('First 10 descriptive files:');
    for (final file in descriptiveFiles.take(10)) {
      print('  - ${p.basename(file)}');
    }
    if (descriptiveFiles.length > 10) {
      print('  - ... and ${descriptiveFiles.length - 10} more');
    }
  }

  // Check if pubspec.yaml includes the assets correctly
  final pubspecFile = File('pubspec.yaml');
  if (pubspecFile.existsSync()) {
    final pubspecContent = pubspecFile.readAsStringSync();
    final hasAssets = pubspecContent.contains('assets/individual_signs/');
    print('\n=== PUBSPEC.YAML ASSETS CONFIGURATION ===');
    print('Assets configured in pubspec.yaml: ${hasAssets ? '✅' : '❌'}');
    
    if (!hasAssets) {
      print('Add this to pubspec.yaml:');
      print('flutter:');
      print('  assets:');
      print('    - assets/individual_signs/');
    }
  }

  print('\n=== RECOMMENDATIONS ===');
  print('1. The question database references images like code1.png, code2.png, code3.png');
  print('   but these files don\'t exist in the assets directory');
  print('2. Many sign_page_XXX_XX.png files exist but should be excluded according to mapping document');
  print('3. Use descriptive named files from subdirectories instead of page-numbered files');
  print('4. Check that all image_url references in questions point to existing files');
  print('5. Run the app and test image loading in the exam interface');
}