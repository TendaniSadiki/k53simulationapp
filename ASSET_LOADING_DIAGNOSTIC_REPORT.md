# Asset Loading Diagnostic Report

## Problem Analysis

The K53 app is experiencing "Unable to load asset" errors for image files in the `assets/individual_signs/` directory, specifically for files with long names containing spaces like "This area is reserved for parking by the class of vehicle shown.png" and "code1.png".

## Root Cause Analysis

### 1. Asset Declaration Verification
✅ **Status**: Properly declared in `pubspec.yaml`
- Line 104: `- assets/individual_signs/`
- Correct indentation and path formatting
- Directory-level declaration includes all subdirectories

### 2. File System Analysis
✅ **Status**: Files exist but with problematic naming
- Found problematic files:
  - `assets/individual_signs/DE-RESTRICTION SIGNS/End of dual carriage freeway and freeway rules no longer apply.png`
  - `assets/individual_signs/DE-RESTRICTION SIGNS/End of lane use reservation and all vehicles may now use this lane.png`
  - `assets/individual_signs/DE-RESTRICTION SIGNS/End of residential area and rules for a residential area no longer apply.png`
  - `assets/individual_signs/DE-RESTRICTION SIGNS/End of single carriage freeway and freeway rules no longer apply.png`
  - `assets/individual_signs/DE-RESTRICTION SIGNS/End of toll road.png`
  - `assets/individual_signs/DE-RESTRICTION SIGNS/You no longer need to drive with your headlights switched on.png`
  - `assets/individual_signs/CODE 1/code1.png`

### 3. Asset Loading Code Review
❌ **Critical Issue**: Image paths are being loaded directly from database
- In [`exam_screen.dart`](lib/src/features/exam/presentation/screens/exam_screen.dart:495), [`Image.asset()`](lib/src/features/exam/presentation/screens/exam_screen.dart:495) is called with `state.currentQuestion!.imageUrl!`
- The `imageUrl` field in questions contains full paths like `assets/individual_signs/DE-RESTRICTION SIGNS/End of dual carriage freeway and freeway rules no longer apply.png`
- **Problem**: Flutter's asset system has issues with:
  - Spaces in file names
  - Special characters
  - Long file names
  - Nested directory structures with spaces

### 4. Build Process Investigation
⚠️ **Potential Issue**: Asset bundling with spaces
- Flutter's asset bundling system may not properly handle files with spaces in names
- The build process might be encoding/decoding file paths incorrectly

## Solution Implementation

### Immediate Fix: Asset Path Sanitization Service

<write_to_file>
<path>lib/src/core/services/asset_path_sanitizer.dart</path>
<content>
import 'package:flutter/foundation.dart';

class AssetPathSanitizer {
  /// Sanitizes asset paths for Flutter's asset loading system
  /// Handles spaces, special characters, and nested directories
  static String sanitizeAssetPath(String originalPath) {
    if (originalPath.isEmpty) return originalPath;
    
    // Remove any leading/trailing whitespace
    String sanitized = originalPath.trim();
    
    // Check if this is already a valid Flutter asset path
    if (_isValidFlutterAssetPath(sanitized)) {
      return sanitized;
    }
    
    // Handle common problematic patterns
    sanitized = _handleSpacesInPath(sanitized);
    sanitized = _handleSpecialCharacters(sanitized);
    sanitized = _normalizePath(sanitized);
    
    if (kDebugMode) {
      print('AssetPathSanitizer: "$originalPath" -> "$sanitized"');
    }
    
    return sanitized;
  }
  
  /// Check if path is already valid for Flutter asset loading
  static bool _isValidFlutterAssetPath(String path) {
    // Valid paths should not contain URL-encoded characters
    if (path.contains('%20') || path.contains('%2F')) {
      return false;
    }
    
    // Should not have double slashes
    if (path.contains('//')) {
      return false;
    }
    
    return true;
  }
  
  /// Handle spaces in file paths
  static String _handleSpacesInPath(String path) {
    // Replace URL-encoded spaces with actual spaces
    path = path.replaceAll('%20', ' ');
    
    // For Flutter assets, spaces in paths should be preserved
    // but we need to ensure the path is properly formatted
    return path;
  }
  
  /// Handle special characters in file paths
  static String _handleSpecialCharacters(String path) {
    // Remove any URL encoding that might interfere with Flutter asset loading
    path = path.replaceAll('%2F', '/');
    path = path.replaceAll('%5C', '/');
    
    // Ensure forward slashes are used consistently
    path = path.replaceAll(r'\', '/');
    
    return path;
  }
  
  /// Normalize the path structure
  static String _normalizePath(String path) {
    // Remove any leading './'
    if (path.startsWith('./')) {
      path = path.substring(2);
    }
    
    // Ensure consistent directory structure
    List<String> parts = path.split('/');
    List<String> normalizedParts = [];
    
    for (String part in parts) {
      if (part.isEmpty || part == '.') continue;
      if (part == '..') {
        if (normalizedParts.isNotEmpty) {
          normalizedParts.removeLast();
        }
        continue;
      }
      normalizedParts.add(part);
    }
    
    return normalizedParts.join('/');
  }
  
  /// Validate if an asset path exists in the expected structure
  static bool isValidAssetStructure(String path) {
    if (!path.startsWith('assets/')) {
      return false;
    }
    
    // Check for common asset directories
    final validDirectories = [
      'assets/individual_signs/',
      'assets/icons/',
      'assets/images/',
    ];
    
    return validDirectories.any((dir) => path.startsWith(dir));
  }
  
  /// Get fallback asset path for missing images
  static String getFallbackAssetPath() {
    return 'assets/individual_signs/sign_page_042_01.png'; // A common road sign
  }
}