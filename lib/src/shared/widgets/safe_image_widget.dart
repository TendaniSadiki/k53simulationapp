import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/asset_path_sanitizer.dart';

class SafeImageWidget extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  
  const SafeImageWidget({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
  });
  
  @override
  Widget build(BuildContext context) {
    final sanitizedPath = AssetPathSanitizer.sanitizeAssetPath(imagePath);
    final correctedPath = AssetPathSanitizer.correctAssetPath(sanitizedPath);
    
    if (!AssetPathSanitizer.isValidAssetStructure(correctedPath)) {
      if (kDebugMode) {
        print('Invalid asset structure: $correctedPath');
      }
      return _buildErrorWidget(context);
    }
    
    // Log path correction if it occurred
    if (kDebugMode && sanitizedPath != correctedPath) {
      print('Asset path corrected: "$sanitizedPath" -> "$correctedPath"');
    }
    
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationX(0), // Ensure image is not flipped
      child: Image.asset(
        correctedPath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('Image loading error for $correctedPath: $error');
          }
          return _buildErrorWidget(context);
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame == null) {
            return placeholder ?? _buildPlaceholder(context);
          }
          return child;
        },
      ),
    );
  }
  
  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: height ?? 150,
      width: width,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Loading image...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
  
  Widget _buildErrorWidget(BuildContext context) {
    return errorWidget ?? Container(
      height: height ?? 150,
      width: width,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Image not available', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}