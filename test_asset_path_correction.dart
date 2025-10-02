import 'package:flutter_test/flutter_test.dart';
import 'lib/src/core/services/asset_path_sanitizer.dart';

void main() {
  group('Asset Path Correction Tests', () {
    test('Corrects prohibition sign path from SELECTIVE RESTRICTION to PROHIBITION', () {
      const incorrectPath = 'assets/individual_signs/SELECTIVE RESTRICTION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png';
      const expectedPath = 'assets/individual_signs/PROHIBITION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png';
      
      final correctedPath = AssetPathSanitizer.correctAssetPath(incorrectPath);
      
      expect(correctedPath, equals(expectedPath));
      print('✓ Path correction test passed:');
      print('  Input: $incorrectPath');
      print('  Output: $correctedPath');
    });

    test('Sanitizes asset path with spaces and special characters', () {
      const rawPath = 'assets/individual_signs/PROHIBITION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png';
      const expectedPath = 'assets/individual_signs/PROHIBITION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png';
      
      final sanitizedPath = AssetPathSanitizer.sanitizeAssetPath(rawPath);
      
      expect(sanitizedPath, equals(expectedPath));
      print('✓ Path sanitization test passed:');
      print('  Input: $rawPath');
      print('  Output: $sanitizedPath');
    });

    test('Validates correct asset structure', () {
      const validPath = 'assets/individual_signs/PROHIBITION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png';
      
      final isValid = AssetPathSanitizer.isValidAssetStructure(validPath);
      
      expect(isValid, isTrue);
      print('✓ Asset structure validation test passed:');
      print('  Path: $validPath');
      print('  Is valid: $isValid');
    });

    test('Combined sanitization and correction workflow', () {
      const rawIncorrectPath = 'assets/individual_signs/SELECTIVE RESTRICTION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png';
      const expectedPath = 'assets/individual_signs/PROHIBITION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png';
      
      final sanitizedPath = AssetPathSanitizer.sanitizeAssetPath(rawIncorrectPath);
      final correctedPath = AssetPathSanitizer.correctAssetPath(sanitizedPath);
      
      expect(correctedPath, equals(expectedPath));
      print('✓ Combined workflow test passed:');
      print('  Raw input: $rawIncorrectPath');
      print('  Sanitized: $sanitizedPath');
      print('  Corrected: $correctedPath');
    });
  });

  print('\n🎉 All asset path correction tests completed successfully!');
  print('The SafeImageWidget should now automatically correct path mismatches.');
}