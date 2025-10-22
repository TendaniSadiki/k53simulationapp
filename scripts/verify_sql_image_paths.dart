import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  print('Verifying image paths in SQL files...');
  
  // Check road sign questions file
  final roadSignFile = File('scripts/road_sign_questions_output_fixed.sql');
  final roadSignContent = roadSignFile.readAsStringSync();
  
  // Extract all image paths
  final imagePathPattern = RegExp(r"assets/individual_signs/[^']+\.png");
  final matches = imagePathPattern.allMatches(roadSignContent);
  
  print('Found ${matches.length} image references in road_sign_questions_output_fixed.sql:');
  
  int missingCount = 0;
  for (final match in matches) {
    final imagePath = match.group(0)!;
    final file = File(imagePath);
    
    if (file.existsSync()) {
      print('✓ $imagePath');
    } else {
      print('✗ $imagePath (MISSING)');
      missingCount++;
    }
  }
  
  // Check evolve questions file
  final evolveFile = File('scripts/seed_evolve_questions_with_images.sql');
  final evolveContent = evolveFile.readAsStringSync();
  
  final evolveMatches = imagePathPattern.allMatches(evolveContent);
  
  print('\nFound ${evolveMatches.length} image references in seed_evolve_questions_with_images.sql:');
  
  for (final match in evolveMatches) {
    final imagePath = match.group(0)!;
    final file = File(imagePath);
    
    if (file.existsSync()) {
      print('✓ $imagePath');
    } else {
      print('✗ $imagePath (MISSING)');
      missingCount++;
    }
  }
  
  print('\nVerification complete:');
  print('Total missing files: $missingCount');
  
  if (missingCount > 0) {
    print('\nERROR: Some image files referenced in SQL do not exist!');
    exit(1);
  } else {
    print('SUCCESS: All image files exist!');
  }
}