import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;

/// Comprehensive image optimization service for the K53 app
/// Handles format conversion, responsive variants, and performance optimization
class ImageOptimizationService {
  static final ImageOptimizationService _instance = ImageOptimizationService._internal();
  factory ImageOptimizationService() => _instance;
  ImageOptimizationService._internal();

  // Cache for optimized images
  final Map<String, Uint8List> _optimizedCache = {};
  final Map<String, Map<String, String>> _responsiveVariantsCache = {};

  /// Converts PNG images to WebP format with configurable quality
  /// Returns the optimized image path or original path if conversion fails
  Future<String> convertToWebP(String originalPath, {int quality = 80}) async {
    try {
      // Check if already optimized
      final cacheKey = '${originalPath}_webp_$quality';
      if (_optimizedCache.containsKey(cacheKey)) {
        return _generateWebPPath(originalPath);
      }

      // Load original image
      final ByteData data = await rootBundle.load(originalPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Decode image
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Convert to WebP (simulated - Flutter doesn't have built-in WebP encoding)
      // In a real implementation, you would use a plugin like image/image.dart
      final Uint8List? webpBytes = await _encodeToWebP(image, quality: quality);
      
      if (webpBytes != null) {
        _optimizedCache[cacheKey] = webpBytes;
        return _generateWebPPath(originalPath);
      }
      
      // Fallback to original path
      return originalPath;
    } catch (e) {
      if (kDebugMode) {
        print('WebP conversion failed for $originalPath: $e');
      }
      return originalPath; // Fallback to original
    }
  }

  /// Generates responsive image variants for different screen densities
  /// Returns a map of density multipliers to image paths
  Future<Map<String, String>> generateResponsiveVariants(String imagePath) async {
    if (_responsiveVariantsCache.containsKey(imagePath)) {
      return _responsiveVariantsCache[imagePath]!;
    }

    final variants = <String, String>{};
    
    try {
      // For now, we'll use the same image for all densities
      // In a real implementation, you would generate different sizes
      variants['1.0x'] = imagePath;
      variants['2.0x'] = imagePath; // Same image for 2x
      variants['3.0x'] = imagePath; // Same image for 3x
      
      // For WebP conversion
      final webpPath = await convertToWebP(imagePath);
      if (webpPath != imagePath) {
        variants['1.0x_webp'] = webpPath;
        variants['2.0x_webp'] = webpPath;
        variants['3.0x_webp'] = webpPath;
      }
      
      _responsiveVariantsCache[imagePath] = variants;
      return variants;
    } catch (e) {
      if (kDebugMode) {
        print('Responsive variant generation failed for $imagePath: $e');
      }
      return {'1.0x': imagePath}; // Fallback to original
    }
  }

  /// Optimizes image for web delivery with compression
  Future<Uint8List> optimizeForWeb(Uint8List imageData, {int maxWidth = 1200}) async {
    try {
      // Decode image
      final ui.Codec codec = await ui.instantiateImageCodec(imageData);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      ui.Image image = frameInfo.image;

      // Resize if too large
      if (image.width > maxWidth) {
        final double scale = maxWidth / image.width;
        image = await _resizeImage(image, scale);
      }

      // Re-encode with compression (simulated)
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List() ?? imageData;
    } catch (e) {
      if (kDebugMode) {
        print('Web optimization failed: $e');
      }
      return imageData; // Return original if optimization fails
    }
  }

  /// Generates descriptive alt text for road sign images
  String generateAltText(String imagePath) {
    final fileName = p.basenameWithoutExtension(imagePath);
    
    // Remove folder path and clean up the filename
    String cleanName = fileName
        .replaceAll('_', ' ')
        .replaceAll('.png', '')
        .replaceAll('..', '')
        .replaceAll('  ', ' ')
        .trim();

    // Common road sign patterns
    if (cleanName.contains('stop') && cleanName.contains('line')) {
      return 'Stop sign - Come to a complete halt at the stop line';
    } else if (cleanName.contains('yield') || cleanName.contains('give way')) {
      return 'Yield sign - Give way to other traffic';
    } else if (cleanName.contains('speed limit')) {
      return 'Speed limit sign showing maximum allowed speed';
    } else if (cleanName.contains('no parking')) {
      return 'No parking sign - Parking prohibited in this area';
    } else if (cleanName.contains('one way')) {
      return 'One-way traffic sign';
    } else if (cleanName.contains('traffic circle') || cleanName.contains('roundabout')) {
      return 'Traffic circle or roundabout ahead sign';
    } else if (cleanName.contains('pedestrian crossing')) {
      return 'Pedestrian crossing ahead sign';
    } else if (cleanName.contains('road works')) {
      return 'Road works ahead warning sign';
    } else if (cleanName.contains('children')) {
      return 'Children crossing warning sign';
    } else if (cleanName.contains('animals')) {
      return 'Wild animals crossing warning sign';
    }

    // Generic description for other signs
    return 'Road sign: $cleanName';
  }

  /// Preloads critical images for better performance
  /// Note: This requires a BuildContext when called from widgets
  Future<void> preloadCriticalImages(List<String> imagePaths, {BuildContext? context}) async {
    for (final path in imagePaths) {
      try {
        // For now, we'll just load the image data without precaching
        // since precacheImage requires a BuildContext
        await rootBundle.load(path);
        if (kDebugMode) {
          print('Preloaded image data: $path');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to preload $path: $e');
        }
      }
    }
  }

  /// Clears optimization cache
  void clearCache() {
    _optimizedCache.clear();
    _responsiveVariantsCache.clear();
  }

  // Private helper methods

  String _generateWebPPath(String originalPath) {
    return originalPath.replaceAll('.png', '.webp');
  }

  Future<Uint8List?> _encodeToWebP(ui.Image image, {int quality = 80}) async {
    // This is a placeholder - Flutter doesn't have built-in WebP encoding
    // In a real implementation, you would use a plugin like:
    // https://pub.dev/packages/image
    // For now, we return null to use the fallback PNG
    return null;
  }

  Future<ui.Image> _resizeImage(ui.Image image, double scale) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    final paint = Paint()
      ..filterQuality = FilterQuality.medium;
    
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, image.width * scale, image.height * scale),
      paint,
    );
    
    final picture = recorder.endRecording();
    return await picture.toImage(
      (image.width * scale).round(),
      (image.height * scale).round(),
    );
  }
}

/// Performance monitoring for image loading
class ImagePerformanceMonitor {
  static final Map<String, List<int>> _loadTimes = {};
  static final Map<String, int> _errorCounts = {};

  /// Track image load time for performance monitoring
  static void trackLoadTime(String imagePath, int loadTimeMs) {
    if (!_loadTimes.containsKey(imagePath)) {
      _loadTimes[imagePath] = [];
    }
    _loadTimes[imagePath]!.add(loadTimeMs);
    
    if (kDebugMode && loadTimeMs > 1000) {
      print('Slow image load: $imagePath took ${loadTimeMs}ms');
    }
  }

  /// Track image loading errors
  static void trackError(String imagePath, dynamic error) {
    _errorCounts[imagePath] = (_errorCounts[imagePath] ?? 0) + 1;
    
    if (kDebugMode) {
      print('Image loading error for $imagePath: $error');
    }
  }

  /// Get performance statistics
  static Map<String, dynamic> getStats() {
    final stats = <String, dynamic>{};
    
    for (final entry in _loadTimes.entries) {
      final times = entry.value;
      if (times.isNotEmpty) {
        final avgTime = times.reduce((a, b) => a + b) ~/ times.length;
        final maxTime = times.reduce((a, b) => a > b ? a : b);
        stats[entry.key] = {
          'load_count': times.length,
          'average_load_time_ms': avgTime,
          'max_load_time_ms': maxTime,
        };
      }
    }
    
    stats['error_counts'] = Map.from(_errorCounts);
    return stats;
  }

  /// Clear performance data
  static void clearStats() {
    _loadTimes.clear();
    _errorCounts.clear();
  }
}