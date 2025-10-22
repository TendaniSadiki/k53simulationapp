import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;

/// Comprehensive image asset analysis tool
/// Identifies issues and provides optimization recommendations
class ImageAssetAnalyzer {
  final String assetsDirectory;
  final List<String> imageExtensions = ['.png', '.jpg', '.jpeg', '.webp', '.gif'];
  
  ImageAssetAnalyzer(this.assetsDirectory);

  /// Analyze all image assets and generate a comprehensive report
  Future<ImageAnalysisReport> analyzeAssets() async {
    final report = ImageAnalysisReport();
    
    // Find all image files
    final imageFiles = await _findImageFiles();
    report.totalImages = imageFiles.length;
    
    for (final file in imageFiles) {
      final analysis = await _analyzeImageFile(file);
      report.images.add(analysis);
      
      // Categorize issues
      if (analysis.fileSize > 500 * 1024) { // 500KB
        report.largeFiles.add(analysis);
      }
      
      if (!analysis.isOptimizedFormat) {
        report.nonOptimizedFormats.add(analysis);
      }
      
      if (analysis.hasLongFileName) {
        report.longFileNames.add(analysis);
      }
      
      if (analysis.hasSpecialCharacters) {
        report.specialCharacterNames.add(analysis);
      }
    }
    
    return report;
  }

  /// Find all image files in the assets directory
  Future<List<File>> _findImageFiles() async {
    final directory = Directory(assetsDirectory);
    if (!await directory.exists()) {
      throw Exception('Assets directory does not exist: $assetsDirectory');
    }
    
    final files = <File>[];
    await _traverseDirectory(directory, files);
    return files;
  }

  /// Recursively traverse directory to find image files
  Future<void> _traverseDirectory(Directory dir, List<File> files) async {
    try {
      final entities = await dir.list().toList();
      
      for (final entity in entities) {
        if (entity is File) {
          final extension = p.extension(entity.path).toLowerCase();
          if (imageExtensions.contains(extension)) {
            files.add(entity);
          }
        } else if (entity is Directory) {
          await _traverseDirectory(entity, files);
        }
      }
    } catch (e) {
      print('Error traversing directory ${dir.path}: $e');
    }
  }

  /// Analyze a single image file
  Future<ImageAnalysis> _analyzeImageFile(File file) async {
    final analysis = ImageAnalysis();
    analysis.filePath = file.path;
    analysis.fileName = p.basename(file.path);
    analysis.fileSize = await file.length();
    analysis.extension = p.extension(file.path).toLowerCase();
    
    // Check file name issues
    analysis.hasLongFileName = analysis.fileName.length > 50;
    analysis.hasSpecialCharacters = _hasSpecialCharacters(analysis.fileName);
    
    // Check format optimization
    analysis.isOptimizedFormat = analysis.extension == '.webp';
    
    // Get dimensions (basic check - would need image decoding for accurate dimensions)
    try {
      final bytes = await file.readAsBytes();
      analysis.dimensions = await _getImageDimensions(bytes);
    } catch (e) {
      print('Error reading image dimensions for ${file.path}: $e');
    }
    
    return analysis;
  }

  /// Check if filename has problematic special characters
  bool _hasSpecialCharacters(String fileName) {
    final cleanName = p.withoutExtension(fileName);
    final regex = RegExp(r'[^a-zA-Z0-9\s\-_\.]');
    return regex.hasMatch(cleanName);
  }

  /// Get image dimensions (basic implementation)
  Future<ImageDimensions?> _getImageDimensions(Uint8List bytes) async {
    // This is a simplified implementation
    // In a real scenario, you would use an image processing library
    try {
      // For PNG files, check the IHDR chunk
      if (bytes.length >= 24 && 
          bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
        final width = (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
        final height = (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];
        return ImageDimensions(width, height);
      }
    } catch (e) {
      print('Error getting image dimensions: $e');
    }
    return null;
  }
}

/// Analysis result for a single image
class ImageAnalysis {
  String filePath = '';
  String fileName = '';
  int fileSize = 0;
  String extension = '';
  ImageDimensions? dimensions;
  bool hasLongFileName = false;
  bool hasSpecialCharacters = false;
  bool isOptimizedFormat = false;
  
  double get sizeInKB => fileSize / 1024;
  double get sizeInMB => fileSize / (1024 * 1024);
  
  @override
  String toString() {
    return 'ImageAnalysis{fileName: $fileName, size: ${sizeInKB.toStringAsFixed(2)}KB, dimensions: $dimensions}';
  }
}

/// Image dimensions
class ImageDimensions {
  final int width;
  final int height;
  
  ImageDimensions(this.width, this.height);
  
  @override
  String toString() => '${width}x$height';
}

/// Comprehensive analysis report
class ImageAnalysisReport {
  int totalImages = 0;
  final List<ImageAnalysis> images = [];
  final List<ImageAnalysis> largeFiles = []; // > 500KB
  final List<ImageAnalysis> nonOptimizedFormats = []; // Not WebP
  final List<ImageAnalysis> longFileNames = []; // > 50 chars
  final List<ImageAnalysis> specialCharacterNames = []; // Has special chars
  
  double get totalSizeInMB => images.fold(0.0, (sum, img) => sum + img.sizeInMB);
  double get averageSizeInKB => totalImages > 0 ? totalSizeInMB * 1024 / totalImages : 0;
  
  void printReport() {
    print('=== IMAGE ASSET ANALYSIS REPORT ===');
    print('Total Images: $totalImages');
    print('Total Size: ${totalSizeInMB.toStringAsFixed(2)} MB');
    print('Average Size: ${averageSizeInKB.toStringAsFixed(2)} KB');
    print('');
    
    if (largeFiles.isNotEmpty) {
      print('LARGE FILES (>500KB):');
      for (final file in largeFiles) {
        print('  - ${file.fileName} (${file.sizeInMB.toStringAsFixed(2)} MB)');
      }
      print('');
    }
    
    if (nonOptimizedFormats.isNotEmpty) {
      print('NON-OPTIMIZED FORMATS (not WebP):');
      for (final file in nonOptimizedFormats) {
        print('  - ${file.fileName} (${file.extension})');
      }
      print('');
    }
    
    if (longFileNames.isNotEmpty) {
      print('LONG FILE NAMES (>50 chars):');
      for (final file in longFileNames) {
        print('  - ${file.fileName} (${file.fileName.length} chars)');
      }
      print('');
    }
    
    if (specialCharacterNames.isNotEmpty) {
      print('FILES WITH SPECIAL CHARACTERS:');
      for (final file in specialCharacterNames) {
        print('  - ${file.fileName}');
      }
      print('');
    }
    
    print('RECOMMENDATIONS:');
    if (largeFiles.isNotEmpty) {
      print('  • Compress ${largeFiles.length} large files to reduce bundle size');
    }
    if (nonOptimizedFormats.isNotEmpty) {
      print('  • Convert ${nonOptimizedFormats.length} images to WebP format');
    }
    if (longFileNames.isNotEmpty) {
      print('  • Shorten ${longFileNames.length} file names for better compatibility');
    }
    if (specialCharacterNames.isNotEmpty) {
      print('  • Remove special characters from ${specialCharacterNames.length} file names');
    }
    
    if (largeFiles.isEmpty && nonOptimizedFormats.isEmpty && 
        longFileNames.isEmpty && specialCharacterNames.isEmpty) {
      print('  • All images are well-optimized!');
    }
  }
}

void main() async {
  final analyzer = ImageAssetAnalyzer('assets/individual_signs');
  
  try {
    print('Analyzing image assets...');
    final report = await analyzer.analyzeAssets();
    report.printReport();
  } catch (e) {
    print('Error analyzing assets: $e');
  }
}