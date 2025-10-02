import 'dart:io';

void main() async {
  print('🚀 Starting Standalone Image Testing...\n');
  
  // Test 1: Scan all images in subfolders
  print('📁 Scanning All Images in Subfolders...');
  await scanAllImages();
  
  // Test 2: Check if critical images exist
  print('\n🔍 Testing Critical Image File Existence...');
  await testImageExistence();
  
  // Test 3: Check image file sizes
  print('\n📊 Testing Image File Sizes...');
  await testImageSizes();
  
  // Test 4: Test path patterns
  print('\n🛣️ Testing Image Path Patterns...');
  await testPathPatterns();
  
  print('\n✅ All standalone image tests completed!');
}

// Helper function to get correct path from scripts directory
String getAssetPath(String relativePath) {
  return '../$relativePath';
}

Future<void> testImageExistence() async {
  final criticalImages = [
    'assets/individual_signs/sign_page_007_02.png', // Stop sign
    'assets/individual_signs/sign_page_020_03.png', // Yield sign
    'assets/individual_signs/sign_page_042_01.png', // Speed limit
    'assets/individual_signs/sign_page_075_01.png', // No entry
    'assets/individual_signs/sign_page_076_01.png', // One way
    'assets/individual_signs/sign_page_019_03.png',
    'assets/individual_signs/sign_page_021_02.png',
    'assets/individual_signs/sign_page_021_03.png',
    'assets/individual_signs/sign_page_023_01.png',
    'assets/individual_signs/sign_page_024_01.png',
  ];

  int missingCount = 0;
  int totalCount = 0;
  
  for (final imagePath in criticalImages) {
    totalCount++;
    final file = File(getAssetPath(imagePath));
    final exists = await file.exists();
    
    if (exists) {
      final sizeInKB = await file.length() / 1024;
      print('  ✅ $imagePath (${sizeInKB.toStringAsFixed(1)}KB)');
    } else {
      print('  ❌ $imagePath (MISSING)');
      missingCount++;
    }
  }
  
  print('\n📊 Summary: $totalCount images checked, $missingCount missing');
  
  if (missingCount > 0) {
    print('⚠️  Found $missingCount missing critical images!');
  } else {
    print('🎉 All critical images are present!');
  }
}

Future<void> testImageSizes() async {
  final testImages = [
    'assets/individual_signs/sign_page_007_02.png',
    'assets/individual_signs/sign_page_020_03.png',
    'assets/individual_signs/sign_page_042_01.png',
    'assets/individual_signs/sign_page_075_01.png',
    'assets/individual_signs/sign_page_076_01.png',
  ];

  print('  Testing file sizes for optimal performance...');
  
  int optimalCount = 0;
  int warningCount = 0;
  int criticalCount = 0;
  
  for (final imagePath in testImages) {
    final file = File(getAssetPath(imagePath));
    final exists = await file.exists();
    
    if (exists) {
      final sizeInKB = await file.length() / 1024;
      
      if (sizeInKB < 100) {
        print('  ✅ $imagePath: ${sizeInKB.toStringAsFixed(1)}KB (Optimal)');
        optimalCount++;
      } else if (sizeInKB < 300) {
        print('  ⚠️  $imagePath: ${sizeInKB.toStringAsFixed(1)}KB (Acceptable)');
        warningCount++;
      } else {
        print('  ❌ $imagePath: ${sizeInKB.toStringAsFixed(1)}KB (Too Large)');
        criticalCount++;
      }
    } else {
      print('  ❌ $imagePath: FILE NOT FOUND');
      criticalCount++;
    }
  }
  
  print('\n📊 Size Summary:');
  print('  ✅ Optimal (<100KB): $optimalCount images');
  print('  ⚠️  Acceptable (100-300KB): $warningCount images');
  print('  ❌ Too Large (>300KB): $criticalCount images');
}

Future<void> testPathPatterns() async {
  print('  Testing common path patterns...');
  
  // Test different path variations
  final pathTests = [
    'assets/individual_signs/sign_page_007_02.png',
    'assets/individual_signs/sign_page_020_03.png',
    'assets/individual_signs/sign_page_042_01.png',
    'assets/individual_signs/DE-RESTRICTION SIGNS/End of dual carriage freeway and freeway rules no longer apply.png',
  ];
  
  for (final path in pathTests) {
    final file = File(getAssetPath(path));
    final exists = await file.exists();
    
    if (exists) {
      print('  ✅ Path valid: $path');
    } else {
      print('  ❌ Path invalid: $path');
      
      // Try to find the file with different variations
      await findAlternativePath(path);
    }
  }
}

Future<void> findAlternativePath(String originalPath) async {
  final fileName = originalPath.split('/').last;
  final directory = Directory(getAssetPath('assets/individual_signs'));
  
  if (await directory.exists()) {
    final files = await directory.list().toList();
    
    for (final file in files) {
      if (file is File && file.path.contains(fileName)) {
        print('     🔍 Found alternative: ${file.path}');
        return;
      }
    }
    
    // Check subdirectories
    final subdirs = await directory.list().toList();
    for (final subdir in subdirs) {
      if (subdir is Directory) {
        final subFiles = await subdir.list().toList();
        for (final file in subFiles) {
          if (file is File && file.path.contains(fileName)) {
            print('     🔍 Found in subdirectory: ${file.path}');
            return;
          }
        }
      }
    }
    
    print('     ❓ File not found in any location');
  }
}

// Quick test function
Future<void> quickTest() async {
  print('🚀 Running Quick Standalone Image Test...\n');
  
  final quickTestImages = [
    'assets/individual_signs/sign_page_007_02.png',
    'assets/individual_signs/sign_page_020_03.png',
    'assets/individual_signs/sign_page_042_01.png',
  ];
  
  for (final imagePath in quickTestImages) {
    final file = File(getAssetPath(imagePath));
    final exists = await file.exists();
    
    if (exists) {
      final sizeInKB = await file.length() / 1024;
      final status = sizeInKB < 100 ? '✅' : sizeInKB < 300 ? '⚠️' : '❌';
      print('$status $imagePath: ${sizeInKB.toStringAsFixed(1)}KB');
    } else {
      print('❌ $imagePath: MISSING');
    }
  }
  
  print('\n✅ Quick standalone test completed!');
}

// Function to scan all image assets
Future<void> scanAllImages() async {
  print('🔍 Scanning all image assets...\n');
  
  final assetsDir = Directory(getAssetPath('assets/individual_signs'));
  if (!await assetsDir.exists()) {
    print('❌ assets/individual_signs directory not found!');
    return;
  }
  
  final files = await assetsDir.list(recursive: true).toList();
  final imageFiles = files.where((file) => file is File && file.path.endsWith('.png')).toList();
  
  print('📁 Found ${imageFiles.length} PNG images in assets/individual_signs');
  
  // Show first 10 files as sample
  print('\n📋 Sample files (first 10):');
  for (int i = 0; i < (imageFiles.length > 10 ? 10 : imageFiles.length); i++) {
    final file = imageFiles[i] as File;
    final sizeInKB = await file.length() / 1024;
    print('  ${i + 1}. ${file.path} (${sizeInKB.toStringAsFixed(1)}KB)');
  }
  
  if (imageFiles.length > 10) {
    print('  ... and ${imageFiles.length - 10} more files');
  }
}