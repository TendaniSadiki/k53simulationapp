import 'dart:io';
import 'package:k53app/src/core/services/asset_path_sanitizer.dart';
import 'package:k53app/src/core/services/image_optimization_service.dart';

void main() async {
  print('🚀 Starting Simple Image Testing...\n');
  
  // Test 1: Asset Path Correction
  print('📁 Testing Asset Path Correction...');
  await testAssetPathCorrection();
  
  // Test 2: Image File Existence
  print('\n🔍 Testing Image File Existence...');
  await testImageExistence();
  
  // Test 3: Alt Text Generation
  print('\n📝 Testing Alt Text Generation...');
  await testAltTextGeneration();
  
  // Test 4: Performance Check
  print('\n⚡ Testing Image Performance...');
  await testImagePerformance();
  
  print('\n✅ All image tests completed!');
}

Future<void> testAssetPathCorrection() async {
  final testPaths = [
    'assets/individual_signs/sign_page_007_02.png',
    'assets/individual_signs/sign_page_020_03.png',
    'assets/individual_signs/sign_page_042_01.png',
    'assets/individual_signs/sign_page_075_01.png',
    'assets/individual_signs/sign_page_076_01.png',
  ];
  
  for (final path in testPaths) {
    final corrected = AssetPathSanitizer.sanitizeAssetPath(path);
    final file = File(corrected);
    final exists = await file.exists();
    
    if (exists) {
      print('  ✅ $path → $corrected (EXISTS)');
    } else {
      print('  ❌ $path → $corrected (MISSING)');
    }
  }
}

Future<void> testImageExistence() async {
  final criticalImages = [
    'assets/individual_signs/sign_page_007_02.png', // Stop sign
    'assets/individual_signs/sign_page_020_03.png', // Yield sign
    'assets/individual_signs/sign_page_042_01.png', // Speed limit
    'assets/individual_signs/sign_page_075_01.png', // No entry
    'assets/individual_signs/sign_page_076_01.png', // One way
    'assets/individual_signs/sign_page_019_03.png', // Other important signs
    'assets/individual_signs/sign_page_021_02.png',
    'assets/individual_signs/sign_page_021_03.png',
    'assets/individual_signs/sign_page_023_01.png',
    'assets/individual_signs/sign_page_024_01.png',
  ];

  int missingCount = 0;
  
  for (final imagePath in criticalImages) {
    final file = File(imagePath);
    final exists = await file.exists();
    
    if (exists) {
      final sizeInKB = await file.length() / 1024;
      print('  ✅ $imagePath (${sizeInKB.toStringAsFixed(1)}KB)');
    } else {
      print('  ❌ $imagePath (MISSING)');
      missingCount++;
    }
  }
  
  if (missingCount > 0) {
    print('\n⚠️  Found $missingCount missing critical images!');
  } else {
    print('\n🎉 All critical images are present!');
  }
}

Future<void> testAltTextGeneration() async {
  final optimizationService = ImageOptimizationService();
  
  final testCases = [
    'assets/individual_signs/sign_page_007_02.png',
    'assets/individual_signs/sign_page_020_03.png',
    'assets/individual_signs/sign_page_042_01.png',
    'assets/individual_signs/sign_page_075_01.png',
    'assets/individual_signs/sign_page_076_01.png',
  ];

  for (final imagePath in testCases) {
    final altText = optimizationService.generateAltText(imagePath);
    print('  📝 $imagePath');
    print('     → "$altText"');
  }
}

Future<void> testImagePerformance() async {
  final testImages = [
    'assets/individual_signs/sign_page_007_02.png',
    'assets/individual_signs/sign_page_020_03.png',
    'assets/individual_signs/sign_page_042_01.png',
  ];

  print('  Testing file sizes and loading performance...');
  
  for (final imagePath in testImages) {
    final file = File(imagePath);
    final exists = await file.exists();
    
    if (exists) {
      final sizeInKB = await file.length() / 1024;
      final sizeStatus = sizeInKB < 100 ? '✅' : sizeInKB < 300 ? '⚠️' : '❌';
      
      print('  $sizeStatus $imagePath: ${sizeInKB.toStringAsFixed(1)}KB');
      
      if (sizeInKB > 300) {
        print('     ⚠️  Consider optimizing this image (over 300KB)');
      } else if (sizeInKB > 100) {
        print('     ℹ️  Image size is acceptable but could be optimized');
      } else {
        print('     ✅ Image size is optimal');
      }
    } else {
      print('  ❌ $imagePath: FILE NOT FOUND');
    }
  }
}

// Quick test function to run specific tests
Future<void> quickTest() async {
  print('🚀 Running Quick Image Test...\n');
  
  // Just test a few critical images
  final quickTestImages = [
    'assets/individual_signs/sign_page_007_02.png',
    'assets/individual_signs/sign_page_020_03.png',
    'assets/individual_signs/sign_page_042_01.png',
  ];
  
  for (final imagePath in quickTestImages) {
    final corrected = AssetPathSanitizer.sanitizeAssetPath(imagePath);
    final file = File(corrected);
    final exists = await file.exists();
    
    if (exists) {
      final sizeInKB = await file.length() / 1024;
      print('✅ $imagePath: ${sizeInKB.toStringAsFixed(1)}KB');
    } else {
      print('❌ $imagePath: MISSING');
    }
  }
  
  print('\n✅ Quick test completed!');
}