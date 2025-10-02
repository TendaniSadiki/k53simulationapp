import 'dart:io';

void main() async {
  print('🚀 Testing Subfolder Images (Excluding sign_page files)...\n');
  
  // Test 1: Scan all descriptive images in subfolders
  print('📁 Scanning Descriptive Images in Subfolders...');
  await scanDescriptiveImages();
  
  // Test 2: Test specific subfolder categories
  print('\n🔍 Testing Specific Subfolder Categories...');
  await testSubfolderCategories();
  
  // Test 3: Quick functionality test
  print('\n⚡ Quick Functionality Test...');
  await quickFunctionalityTest();
  
  print('\n✅ Subfolder image testing completed!');
}

// Helper function to get correct path from scripts directory
String getAssetPath(String relativePath) {
  return '../$relativePath';
}

Future<void> scanDescriptiveImages() async {
  final assetsDir = Directory(getAssetPath('assets/individual_signs'));
  if (!await assetsDir.exists()) {
    print('❌ assets/individual_signs directory not found!');
    return;
  }
  
  // Get all subdirectories
  final subdirs = await assetsDir.list().where((entity) => entity is Directory).toList();
  
  print('📁 Found ${subdirs.length} subdirectories:');
  for (final subdir in subdirs) {
    final subdirName = subdir.path.split('/').last;
    print('  📂 $subdirName');
  }
  
  // Scan all PNG files recursively, excluding sign_page files
  final files = await assetsDir.list(recursive: true).toList();
  final imageFiles = files.where((file) => 
    file is File && 
    file.path.endsWith('.png') &&
    !file.path.contains('sign_page')
  ).toList();
  
  print('\n📊 Found ${imageFiles.length} descriptive PNG images (excluding sign_page files)');
  
  // Group by subdirectory
  final Map<String, List<File>> imagesBySubdir = {};
  
  for (final file in imageFiles.cast<File>()) {
    final path = file.path;
    final parts = path.split('/');
    final subdirName = parts.length > 3 ? parts[2] : 'root';
    
    if (!imagesBySubdir.containsKey(subdirName)) {
      imagesBySubdir[subdirName] = [];
    }
    imagesBySubdir[subdirName]!.add(file);
  }
  
  // Print summary by subdirectory
  print('\n📋 Descriptive images by subdirectory:');
  imagesBySubdir.forEach((subdir, files) {
    print('  📂 $subdir: ${files.length} descriptive images');
  });
  
  // Show sample descriptive files from each subdirectory
  print('\n📋 Sample descriptive files from each subdirectory:');
  imagesBySubdir.forEach((subdir, files) async {
    print('\n  📂 $subdir:');
    for (int i = 0; i < (files.length > 5 ? 5 : files.length); i++) {
      final file = files[i];
      final sizeInKB = await file.length() / 1024;
      final fileName = file.path.split('/').last;
      final status = sizeInKB < 100 ? '✅' : sizeInKB < 300 ? '⚠️' : '❌';
      print('    $status $fileName (${sizeInKB.toStringAsFixed(1)}KB)');
    }
    if (files.length > 5) {
      print('    ... and ${files.length - 5} more files');
    }
  });
}

Future<void> testSubfolderCategories() async {
  final subfolderTests = [
    'DE-RESTRICTION SIGNS',
    'RESERVATION SIGNS', 
    'ROAD LAYOUT CHANGES AHEAD',
    'ROAD SITUATIONS AHEAD',
    'SELECTIVE RESTRICTION SIGNS',
    'CODE 2'
  ];
  
  print('  Testing specific subfolder categories:');
  
  for (final subfolder in subfolderTests) {
    final subfolderPath = getAssetPath('assets/individual_signs/$subfolder');
    final subfolderDir = Directory(subfolderPath);
    final exists = await subfolderDir.exists();
    
    if (exists) {
      final files = await subfolderDir.list().where((file) => 
        file is File && file.path.endsWith('.png') && !file.path.contains('sign_page')
      ).toList();
      
      print('  ✅ $subfolder: ${files.length} descriptive images');
      
      // Show first 3 files as sample
      for (int i = 0; i < (files.length > 3 ? 3 : files.length); i++) {
        final file = files[i] as File;
        final fileName = file.path.split('/').last;
        final sizeInKB = await file.length() / 1024;
        print('      ${i + 1}. $fileName (${sizeInKB.toStringAsFixed(1)}KB)');
      }
    } else {
      print('  ❌ $subfolder: Subfolder not found');
    }
  }
}

Future<void> quickFunctionalityTest() async {
  print('  Testing image loading functionality...');
  
  // Test a few specific descriptive images
  final testImages = [
    'assets/individual_signs/DE-RESTRICTION SIGNS/End of dual carriage freeway and freeway rules no longer apply.png',
    'assets/individual_signs/RESERVATION SIGNS/Parking here is reserved for a vehicle carrying people with disabilities.png',
    'assets/individual_signs/ROAD LAYOUT CHANGES AHEAD/Crossroad ahead.png',
    'assets/individual_signs/ROAD SITUATIONS AHEAD/Railway crossing ahead. Obey any traffic control signals at the crossing..png',
    'assets/individual_signs/SELECTIVE RESTRICTION SIGNS/Applies at night only.png',
  ];
  
  int workingCount = 0;
  int totalCount = 0;
  
  for (final imagePath in testImages) {
    totalCount++;
    final file = File(getAssetPath(imagePath));
    final exists = await file.exists();
    
    if (exists) {
      final sizeInKB = await file.length() / 1024;
      final status = sizeInKB < 100 ? '✅' : sizeInKB < 300 ? '⚠️' : '❌';
      print('  $status $imagePath (${sizeInKB.toStringAsFixed(1)}KB)');
      workingCount++;
    } else {
      print('  ❌ $imagePath: FILE NOT FOUND');
    }
  }
  
  print('\n  📊 Functionality Summary: $workingCount/$totalCount images working');
  
  if (workingCount == totalCount) {
    print('  🎉 All test images are accessible!');
  } else {
    print('  ⚠️  Some images need attention');
  }
}

// Quick test for specific subfolder
Future<void> testSpecificSubfolder(String subfolderName) async {
  print('🔍 Testing $subfolderName subfolder...\n');
  
  final subfolderPath = getAssetPath('assets/individual_signs/$subfolderName');
  final subfolderDir = Directory(subfolderPath);
  final exists = await subfolderDir.exists();
  
  if (!exists) {
    print('❌ Subfolder not found: $subfolderName');
    return;
  }
  
  final files = await subfolderDir.list().where((file) => 
    file is File && file.path.endsWith('.png') && !file.path.contains('sign_page')
  ).toList();
  
  print('📁 Found ${files.length} descriptive images in $subfolderName:\n');
  
  for (final file in files.cast<File>()) {
    final fileName = file.path.split('/').last;
    final sizeInKB = await file.length() / 1024;
    final status = sizeInKB < 100 ? '✅' : sizeInKB < 300 ? '⚠️' : '❌';
    print('$status $fileName (${sizeInKB.toStringAsFixed(1)}KB)');
  }
}