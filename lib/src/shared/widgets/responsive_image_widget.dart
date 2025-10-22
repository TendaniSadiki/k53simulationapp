import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/image_optimization_service.dart';
import '../../core/services/asset_path_sanitizer.dart';
import '../../core/utils/performance_utils.dart';

/// Enhanced image widget with responsive loading, accessibility, and performance optimization
class ResponsiveImageWidget extends StatefulWidget {
  final String imagePath;
  final String? altText;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool lazyLoad;
  final bool enableOptimization;
  final Widget? placeholder;
  final Widget? errorWidget;
  final VoidCallback? onLoadComplete;
  final VoidCallback? onLoadError;

  const ResponsiveImageWidget({
    super.key,
    required this.imagePath,
    this.altText,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.lazyLoad = true,
    this.enableOptimization = true,
    this.placeholder,
    this.errorWidget,
    this.onLoadComplete,
    this.onLoadError,
  });

  @override
  State<ResponsiveImageWidget> createState() => _ResponsiveImageWidgetState();
}

class _ResponsiveImageWidgetState extends State<ResponsiveImageWidget> {
  late String _optimizedPath;
  late String _altText;
  bool _isLoading = true;
  bool _hasError = false;
  int? _loadStartTime;

  @override
  void initState() {
    super.initState();
    _initializeImage();
  }

  @override
  void didUpdateWidget(ResponsiveImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _initializeImage();
    }
  }

  Future<void> _initializeImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      _loadStartTime = DateTime.now().millisecondsSinceEpoch;

      // Apply path correction first
      final sanitizedPath = AssetPathSanitizer.sanitizeAssetPath(widget.imagePath);
      final correctedPath = AssetPathSanitizer.correctAssetPath(sanitizedPath);

      if (kDebugMode && sanitizedPath != correctedPath) {
        print('ResponsiveImageWidget: Path corrected: "$sanitizedPath" -> "$correctedPath"');
      }

      // Apply optimization if enabled
      if (widget.enableOptimization) {
        final optimizationService = ImageOptimizationService();
        _optimizedPath = await optimizationService.convertToWebP(correctedPath);
        
        // Generate alt text if not provided
        _altText = widget.altText ?? optimizationService.generateAltText(correctedPath);
        
        if (kDebugMode && _optimizedPath != correctedPath) {
          print('ResponsiveImageWidget: Optimized to WebP: "$correctedPath" -> "$_optimizedPath"');
        }
      } else {
        _optimizedPath = correctedPath;
        _altText = widget.altText ?? ImageOptimizationService().generateAltText(correctedPath);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Track performance
        if (_loadStartTime != null) {
          final loadTime = DateTime.now().millisecondsSinceEpoch - _loadStartTime!;
          ImagePerformanceMonitor.trackLoadTime(_optimizedPath, loadTime);
          PerformanceUtils.trackImageLoad(_optimizedPath, loadTime);
        }
        
        widget.onLoadComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        
        ImagePerformanceMonitor.trackError(widget.imagePath, e);
        widget.onLoadError?.call();
        
        if (kDebugMode) {
          print('ResponsiveImageWidget: Error loading $widget.imagePath: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ?? _buildPlaceholder();
    }

    if (_hasError) {
      return widget.errorWidget ?? _buildErrorWidget();
    }

    return Semantics(
      label: _altText,
      image: true,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(0), // Ensure image is not flipped
        child: Image.asset(
          _optimizedPath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          gaplessPlayback: true, // Prevents flickering when rebuilding
          errorBuilder: (context, error, stackTrace) {
            ImagePerformanceMonitor.trackError(_optimizedPath, error);
            widget.onLoadError?.call();
            
            if (kDebugMode) {
              print('ResponsiveImageWidget: Image.asset error for $_optimizedPath: $error');
            }
            
            return widget.errorWidget ?? _buildErrorWidget();
          },
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame == null && !wasSynchronouslyLoaded) {
              return widget.placeholder ?? _buildPlaceholder();
            }
            return child;
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Loading road sign...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text('Road sign not available', style: TextStyle(color: Colors.grey[600])),
          if (kDebugMode) ...[
            const SizedBox(height: 4),
            Text(
              _optimizedPath,
              style: const TextStyle(fontSize: 10, color: Colors.red),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Lazy loading wrapper for images that are below the fold
class LazyImageWidget extends StatefulWidget {
  final String imagePath;
  final String? altText;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration loadDelay;

  const LazyImageWidget({
    super.key,
    required this.imagePath,
    this.altText,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    this.loadDelay = const Duration(milliseconds: 100),
  });

  @override
  State<LazyImageWidget> createState() => _LazyImageWidgetState();
}

class _LazyImageWidgetState extends State<LazyImageWidget> {
  bool _shouldLoad = false;
  Timer? _loadTimer;

  @override
  void initState() {
    super.initState();
    _scheduleLoad();
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }

  void _scheduleLoad() {
    _loadTimer = Timer(widget.loadDelay, () {
      if (mounted) {
        setState(() {
          _shouldLoad = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldLoad) {
      return widget.placeholder ?? _buildPlaceholder();
    }

    return ResponsiveImageWidget(
      imagePath: widget.imagePath,
      altText: widget.altText,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      lazyLoad: false, // Already handled by this widget
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}