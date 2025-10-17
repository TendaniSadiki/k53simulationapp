import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../core/services/asset_management_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/models/asset_bucket.dart';
import '../../../../core/models/road_sign_asset.dart';

final assetManagementProvider = StateNotifierProvider<AssetManagementProvider, AssetManagementState>((ref) {
  return AssetManagementProvider();
});

class AssetManagementState {
  final List<RoadSignAsset> assets;
  final List<AssetBucket> buckets;
  final bool isLoading;
  final String? error;
  final String? selectedBucket;
  final Map<String, int> assetCounts;
  final Map<String, int> storageUsage;

  AssetManagementState({
    this.assets = const [],
    this.buckets = const [],
    this.isLoading = false,
    this.error,
    this.selectedBucket,
    this.assetCounts = const {},
    this.storageUsage = const {},
  });

  AssetManagementState copyWith({
    List<RoadSignAsset>? assets,
    List<AssetBucket>? buckets,
    bool? isLoading,
    String? error,
    String? selectedBucket,
    Map<String, int>? assetCounts,
    Map<String, int>? storageUsage,
  }) {
    return AssetManagementState(
      assets: assets ?? this.assets,
      buckets: buckets ?? this.buckets,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedBucket: selectedBucket ?? this.selectedBucket,
      assetCounts: assetCounts ?? this.assetCounts,
      storageUsage: storageUsage ?? this.storageUsage,
    );
  }

  int get totalAssets => assets.length;
  int get totalBuckets => buckets.length;
  int get totalStorageUsage => storageUsage.values.fold(0, (sum, value) => sum + value);
}

class AssetManagementProvider extends StateNotifier<AssetManagementState> {
  AssetManagementProvider() : super(AssetManagementState());

  // Load all assets and buckets
  Future<void> loadAssets() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final assetService = AssetManagementService();
      final assets = assetService.getAllAssets();
      final buckets = assetService.getAllBuckets();
      final assetCounts = _calculateAssetCounts();
      final storageUsage = _calculateStorageUsage();

      state = state.copyWith(
        assets: assets,
        buckets: buckets,
        assetCounts: assetCounts,
        storageUsage: storageUsage,
        isLoading: false,
      );

      // Track analytics
      await AnalyticsService.trackEvent(
        eventType: 'assets_loaded',
        metadata: {
          'total_assets': assets.length,
          'total_buckets': buckets.length,
          'total_storage_usage': storageUsage.values.fold(0, (sum, value) => sum + value),
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load assets: $e',
      );
    }
  }

  // Upload asset
  Future<void> uploadAsset({
    required String filePath,
    required String bucketName,
    String? assetName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final assetService = AssetManagementService();
      final asset = await assetService.uploadAsset(
        bucketId: bucketName,
        imageFile: File(filePath),
        metadata: metadata ?? {},
      );

      // Add to local state
      final newAssets = List<RoadSignAsset>.from(state.assets);
      newAssets.add(asset);

      // Update asset counts and storage usage
      final newAssetCounts = Map<String, int>.from(state.assetCounts);
      newAssetCounts[bucketName] = (newAssetCounts[bucketName] ?? 0) + 1;

      final newStorageUsage = Map<String, int>.from(state.storageUsage);
      final fileSize = asset.fileSize;
      newStorageUsage[bucketName] = (newStorageUsage[bucketName] ?? 0) + fileSize;

      state = state.copyWith(
        assets: newAssets,
        assetCounts: newAssetCounts,
        storageUsage: newStorageUsage,
        isLoading: false,
      );

      // Track analytics
      await AnalyticsService.trackEvent(
        eventType: 'asset_uploaded',
        metadata: {
          'bucket_name': bucketName,
          'asset_name': asset.fileName,
          'file_size': fileSize,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to upload asset: $e',
      );
    }
  }

  // Delete asset
  Future<void> deleteAsset(String assetId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final asset = state.assets.firstWhere((a) => a.id == assetId);
      final bucketName = asset.bucketId;
      final fileSize = asset.fileSize;

      final assetService = AssetManagementService();
      assetService.deleteAsset(assetId);

      // Remove from local state
      final newAssets = state.assets.where((a) => a.id != assetId).toList();

      // Update asset counts and storage usage
      final newAssetCounts = Map<String, int>.from(state.assetCounts);
      if (bucketName != null) {
        newAssetCounts[bucketName] = (newAssetCounts[bucketName] ?? 1) - 1;
        if (newAssetCounts[bucketName]! <= 0) {
          newAssetCounts.remove(bucketName);
        }
      }

      final newStorageUsage = Map<String, int>.from(state.storageUsage);
      if (bucketName != null) {
        newStorageUsage[bucketName] = (newStorageUsage[bucketName] ?? fileSize) - fileSize;
        if (newStorageUsage[bucketName]! <= 0) {
          newStorageUsage.remove(bucketName);
        }
      }

      state = state.copyWith(
        assets: newAssets,
        assetCounts: newAssetCounts,
        storageUsage: newStorageUsage,
        isLoading: false,
      );

      // Track analytics
      await AnalyticsService.trackEvent(
        eventType: 'asset_deleted',
        metadata: {
          'asset_id': assetId,
          'bucket_name': bucketName,
          'file_size': fileSize,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete asset: $e',
      );
    }
  }

  // Create bucket
  Future<void> createBucket({
    required String bucketName,
    String? description,
    Map<String, dynamic>? settings,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final assetService = AssetManagementService();
      final bucket = assetService.createBucket(
        name: bucketName,
        description: description ?? '',
        category: 'general',
        metadata: settings ?? {},
      );

      // Add to local state
      final newBuckets = List<AssetBucket>.from(state.buckets);
      newBuckets.add(bucket);

      state = state.copyWith(
        buckets: newBuckets,
        isLoading: false,
      );

      // Track analytics
      await AnalyticsService.trackEvent(
        eventType: 'bucket_created',
        metadata: {
          'bucket_name': bucketName,
          'description': description,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create bucket: $e',
      );
    }
  }

  // Delete bucket
  Future<void> deleteBucket(String bucketName) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final assetService = AssetManagementService();
      assetService.deleteBucket(bucketName);

      // Remove from local state
      final newBuckets = state.buckets.where((b) => b.name != bucketName).toList();

      // Remove assets from this bucket
      final newAssets = state.assets.where((a) => a.bucketId != bucketName).toList();

      // Update asset counts and storage usage
      final newAssetCounts = Map<String, int>.from(state.assetCounts);
      newAssetCounts.remove(bucketName);

      final newStorageUsage = Map<String, int>.from(state.storageUsage);
      newStorageUsage.remove(bucketName);

      state = state.copyWith(
        buckets: newBuckets,
        assets: newAssets,
        assetCounts: newAssetCounts,
        storageUsage: newStorageUsage,
        isLoading: false,
      );

      // Track analytics
      await AnalyticsService.trackEvent(
        eventType: 'bucket_deleted',
        metadata: {
          'bucket_name': bucketName,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete bucket: $e',
      );
    }
  }

  // Select bucket
  void selectBucket(String? bucketName) {
    state = state.copyWith(selectedBucket: bucketName);
  }

  // Get assets by bucket
  List<RoadSignAsset> getAssetsByBucket(String bucketName) {
    return state.assets.where((asset) => asset.bucketId == bucketName).toList();
  }

  // Search assets
  List<RoadSignAsset> searchAssets(String query) {
    if (query.isEmpty) return state.assets;

    final assetService = AssetManagementService();
    return assetService.searchAssets(query);
  }

  // Get asset by ID
  RoadSignAsset? getAssetById(String assetId) {
    try {
      return state.assets.firstWhere((asset) => asset.id == assetId);
    } catch (e) {
      return null;
    }
  }

  // Get bucket by name
  AssetBucket? getBucketByName(String bucketName) {
    try {
      return state.buckets.firstWhere((bucket) => bucket.name == bucketName);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper methods
  Map<String, int> _calculateAssetCounts() {
    final counts = <String, int>{};
    
    for (final asset in state.assets) {
      final bucketName = asset.bucketId;
      counts[bucketName] = (counts[bucketName] ?? 0) + 1;
    }
    
    return counts;
  }

  Map<String, int> _calculateStorageUsage() {
    final usage = <String, int>{};
    
    for (final asset in state.assets) {
      final bucketName = asset.bucketId;
      final fileSize = asset.fileSize;
      
      usage[bucketName] = (usage[bucketName] ?? 0) + fileSize;
    }
    
    return usage;
  }

  // Get storage statistics
  Map<String, dynamic> getStorageStats() {
    final totalUsage = state.storageUsage.values.fold(0, (sum, value) => sum + value);
    final totalAssets = state.assets.length;
    final totalBuckets = state.buckets.length;

    return {
      'total_usage_bytes': totalUsage,
      'total_usage_mb': (totalUsage / (1024 * 1024)).toStringAsFixed(2),
      'total_assets': totalAssets,
      'total_buckets': totalBuckets,
      'average_asset_size': totalAssets > 0 ? totalUsage / totalAssets : 0,
    };
  }

  // Get bucket statistics
  Map<String, dynamic> getBucketStats(String bucketName) {
    final bucketAssets = getAssetsByBucket(bucketName);
    final assetCount = bucketAssets.length;
    final totalSize = bucketAssets.fold(0, (sum, asset) => sum + asset.fileSize);

    return {
      'asset_count': assetCount,
      'total_size_bytes': totalSize,
      'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'average_asset_size': assetCount > 0 ? totalSize / assetCount : 0,
    };
  }

  // Validate asset name
  bool isValidAssetName(String name) {
    if (name.isEmpty) return false;
    if (name.length > 255) return false;
    
    // Check for invalid characters
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    return !invalidChars.hasMatch(name);
  }

  // Validate bucket name
  bool isValidBucketName(String name) {
    if (name.isEmpty) return false;
    if (name.length > 63) return false;
    
    // Check for invalid characters and patterns
    final invalidChars = RegExp(r'[^a-z0-9\-]');
    return !invalidChars.hasMatch(name.toLowerCase()) &&
           !name.startsWith('-') &&
           !name.endsWith('-') &&
           !name.contains('--');
  }

  // Get asset file extension
  String getAssetFileExtension(String assetName) {
    final parts = assetName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // Check if asset is an image
  bool isImageAsset(String assetName) {
    final extension = getAssetFileExtension(assetName);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  // Check if asset is a video
  bool isVideoAsset(String assetName) {
    final extension = getAssetFileExtension(assetName);
    return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'].contains(extension);
  }

  // Check if asset is a document
  bool isDocumentAsset(String assetName) {
    final extension = getAssetFileExtension(assetName);
    return ['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(extension);
  }

  // Get asset type category
  String getAssetTypeCategory(String assetName) {
    if (isImageAsset(assetName)) return 'image';
    if (isVideoAsset(assetName)) return 'video';
    if (isDocumentAsset(assetName)) return 'document';
    return 'other';
  }
}