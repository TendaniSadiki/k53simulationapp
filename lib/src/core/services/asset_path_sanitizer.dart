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

  /// Correct common image path mismatches
  static String correctAssetPath(String originalPath) {
    String correctedPath = originalPath;
    
    // Fix specific known path mismatches
    final pathCorrections = {
      'assets/individual_signs/SELECTIVE RESTRICTION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png':
        'assets/individual_signs/PROHIBITION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png',
      'assets/individual_signs/SELECTIVE RESTRICTION SIGNS/Over taking vehicles is prohibited for the next 500m.png':
        'assets/individual_signs/PROHIBITION SIGNS/Over taking vehicles is prohibited for the next 500m.png',
      'assets/individual_signs/SELECTIVE RESTRICTION SIGNS/No stopping to ensure traffic flow and prevent dri.png':
        'assets/individual_signs/PROHIBITION SIGNS/No stopping to ensure traffic flow and prevent dri.png',
    };
    
    // Apply corrections if path matches
    if (pathCorrections.containsKey(originalPath)) {
      correctedPath = pathCorrections[originalPath]!;
      if (kDebugMode) {
        print('AssetPathSanitizer: Corrected "$originalPath" -> "$correctedPath"');
      }
    }
    
    return correctedPath;
  }
  
  /// Get fallback asset path for missing images
  static String getFallbackAssetPath() {
    return 'assets/individual_signs/sign_page_042_01.png'; // A common road sign
  }
}