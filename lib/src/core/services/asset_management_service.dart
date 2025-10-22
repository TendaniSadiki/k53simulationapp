import 'dart:io';
import '../models/asset_bucket.dart';
import '../models/road_sign_asset.dart';

class AssetManagementService {
  static final AssetManagementService _instance = AssetManagementService._internal();
  factory AssetManagementService() => _instance;
  AssetManagementService._internal();

  // In-memory storage for demonstration
  final List<AssetBucket> _buckets = [];
  final List<RoadSignAsset> _assets = [];

  // Initialize with default bucket
  void initialize() {
    if (_buckets.isEmpty) {
      final defaultBucket = AssetBucket.create(
        name: 'road_signs',
        description: 'Default collection of road sign assets',
        category: 'regulatory',
      );
      _buckets.add(defaultBucket);
    }
  }

  // Bucket Management
  List<AssetBucket> getAllBuckets() {
    return List.from(_buckets);
  }

  AssetBucket? getBucketById(String bucketId) {
    return _buckets.firstWhere((bucket) => bucket.id == bucketId);
  }

  AssetBucket createBucket({
    required String name,
    required String description,
    required String category,
    Map<String, dynamic> metadata = const {},
  }) {
    final bucket = AssetBucket.create(
      name: name,
      description: description,
      category: category,
      metadata: metadata,
    );
    _buckets.add(bucket);
    return bucket;
  }

  void deleteBucket(String bucketId) {
    _buckets.removeWhere((bucket) => bucket.id == bucketId);
    // Also remove assets in this bucket
    _assets.removeWhere((asset) => asset.bucketId == bucketId);
  }

  // Asset Management
  List<RoadSignAsset> getAssetsByBucket(String bucketId) {
    return _assets.where((asset) => asset.bucketId == bucketId).toList();
  }

  List<RoadSignAsset> getAllAssets() {
    return List.from(_assets);
  }

  RoadSignAsset? getAssetById(String assetId) {
    return _assets.firstWhere((asset) => asset.id == assetId);
  }

  Future<RoadSignAsset> uploadAsset({
    required String bucketId,
    required File imageFile,
    String? location,
    String? signType,
    String? condition,
    List<String> tags = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    // Validate bucket exists
    final bucket = getBucketById(bucketId);
    if (bucket == null) {
      throw Exception('Bucket not found: $bucketId');
    }

    // Read file metadata
    final fileStat = await imageFile.stat();
    final fileName = imageFile.uri.pathSegments.last;
    final fileExtension = fileName.split('.').last.toLowerCase();

    // Validate image format
    if (!['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(fileExtension)) {
      throw Exception('Unsupported image format: $fileExtension');
    }

    // For now, use default dimensions since we can't decode images without the image package
    // In a real implementation, you would use an image processing library
    final defaultWidth = 300;
    final defaultHeight = 300;

    // Create asset record
    final asset = RoadSignAsset.create(
      bucketId: bucketId,
      fileName: fileName,
      filePath: imageFile.path,
      fileFormat: fileExtension,
      fileSize: fileStat.size,
      width: defaultWidth,
      height: defaultHeight,
      location: location,
      signType: signType,
      condition: condition,
      tags: tags,
      metadata: {
        ...metadata,
        'original_path': imageFile.path,
        'file_permissions': fileStat.mode.toString(),
      },
    );

    _assets.add(asset);

    // Update bucket asset count
    final bucketIndex = _buckets.indexWhere((b) => b.id == bucketId);
    if (bucketIndex != -1) {
      final currentBucket = _buckets[bucketIndex];
      final updatedBucket = currentBucket.copyWith(
        assetCount: currentBucket.assetCount + 1,
      );
      _buckets[bucketIndex] = updatedBucket;
    }

    return asset;
  }

  void deleteAsset(String assetId) {
    final assetIndex = _assets.indexWhere((asset) => asset.id == assetId);
    if (assetIndex != -1) {
      final asset = _assets[assetIndex];
      _assets.removeAt(assetIndex);

      // Update bucket asset count
      final bucketIndex = _buckets.indexWhere((b) => b.id == asset.bucketId);
      if (bucketIndex != -1) {
        final currentBucket = _buckets[bucketIndex];
        final updatedBucket = currentBucket.copyWith(
          assetCount: currentBucket.assetCount - 1,
        );
        _buckets[bucketIndex] = updatedBucket;
      }
    }
  }

  // Search functionality
  List<AssetBucket> searchBuckets(String query) {
    if (query.isEmpty) return getAllBuckets();
    
    final lowerQuery = query.toLowerCase();
    return _buckets.where((bucket) {
      return bucket.name.toLowerCase().contains(lowerQuery) ||
             bucket.description.toLowerCase().contains(lowerQuery) ||
             bucket.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<RoadSignAsset> searchAssets(String query) {
    if (query.isEmpty) return getAllAssets();
    
    final lowerQuery = query.toLowerCase();
    return _assets.where((asset) {
      return asset.fileName.toLowerCase().contains(lowerQuery) ||
             (asset.location?.toLowerCase().contains(lowerQuery) ?? false) ||
             (asset.signType?.toLowerCase().contains(lowerQuery) ?? false) ||
             asset.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<RoadSignAsset> searchAssetsAcrossBuckets(String query) {
    return searchAssets(query);
  }

  // Statistics
  Map<String, dynamic> getSystemStats() {
    final totalAssets = _assets.length;
    final totalBuckets = _buckets.length;
    final totalFileSize = _assets.fold<int>(0, (sum, asset) => sum + asset.fileSize);
    
    // Category distribution
    final categoryDistribution = <String, int>{};
    for (final bucket in _buckets) {
      categoryDistribution.update(
        bucket.category,
        (value) => value + bucket.assetCount,
        ifAbsent: () => bucket.assetCount,
      );
    }

    return {
      'total_assets': totalAssets,
      'total_buckets': totalBuckets,
      'total_file_size': totalFileSize,
      'category_distribution': categoryDistribution,
      'formatted_total_size': _formatFileSize(totalFileSize),
    };
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Import existing assets from file system
  Future<void> importExistingAssets() async {
    final assetsDir = Directory('assets/individual_signs');
    if (!assetsDir.existsSync()) return;

    final defaultBucket = _buckets.firstWhere(
      (bucket) => bucket.name == 'road_signs',
      orElse: () => createBucket(
        name: 'road_signs',
        description: 'Default collection of road sign assets',
        category: 'regulatory',
      ),
    );

    await _importDirectoryAssets(assetsDir, defaultBucket.id);
  }

  Future<void> _importDirectoryAssets(Directory directory, String bucketId) async {
    final entities = directory.listSync();
    
    for (final entity in entities) {
      if (entity is File) {
        final fileName = entity.uri.pathSegments.last;
        final fileExtension = fileName.split('.').last.toLowerCase();
        
        if (['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(fileExtension)) {
          try {
            await uploadAsset(
              bucketId: bucketId,
              imageFile: entity,
              metadata: {
                'imported_at': DateTime.now().toIso8601String(),
                'source_directory': directory.path,
              },
            );
          } catch (e) {
            print('Failed to import asset: $fileName - $e');
          }
        }
      } else if (entity is Directory) {
        await _importDirectoryAssets(entity, bucketId);
      }
    }
  }
}