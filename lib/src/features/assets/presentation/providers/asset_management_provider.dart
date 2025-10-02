import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/asset_management_service.dart';
import '../../../../core/models/asset_bucket.dart';
import '../../../../core/models/road_sign_asset.dart';

// Provider for the asset management service
final assetManagementServiceProvider = Provider<AssetManagementService>((ref) {
  final service = AssetManagementService();
  service.initialize();
  return service;
});

// State for asset management
class AssetManagementState {
  final List<AssetBucket> buckets;
  final List<RoadSignAsset> assets;
  final String? selectedBucketId;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const AssetManagementState({
    this.buckets = const [],
    this.assets = const [],
    this.selectedBucketId,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  AssetManagementState copyWith({
    List<AssetBucket>? buckets,
    List<RoadSignAsset>? assets,
    String? selectedBucketId,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return AssetManagementState(
      buckets: buckets ?? this.buckets,
      assets: assets ?? this.assets,
      selectedBucketId: selectedBucketId ?? this.selectedBucketId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Get current bucket
  AssetBucket? get selectedBucket {
    if (selectedBucketId == null) return null;
    return buckets.firstWhere(
      (bucket) => bucket.id == selectedBucketId,
      orElse: () => buckets.firstWhere((bucket) => bucket.name == 'road_signs'),
    );
  }

  // Get filtered assets based on current state
  List<RoadSignAsset> get filteredAssets {
    List<RoadSignAsset> filtered = assets;

    // Filter by selected bucket
    if (selectedBucketId != null) {
      filtered = filtered.where((asset) => asset.bucketId == selectedBucketId).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((asset) => asset.matchesSearch(searchQuery)).toList();
    }

    return filtered;
  }

  // Get assets for global search (across all buckets)
  List<RoadSignAsset> get globallySearchedAssets {
    if (searchQuery.isEmpty) return [];
    return assets.where((asset) => asset.matchesSearch(searchQuery)).toList();
  }

  // Statistics
  Map<String, dynamic> get statistics {
    final totalAssets = assets.length;
    final totalBuckets = buckets.length;
    final totalFileSize = assets.fold<int>(0, (sum, asset) => sum + asset.fileSize);

    return {
      'total_assets': totalAssets,
      'total_buckets': totalBuckets,
      'total_file_size': totalFileSize,
      'formatted_total_size': _formatFileSize(totalFileSize),
    };
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// Notifier for asset management
class AssetManagementNotifier extends StateNotifier<AssetManagementState> {
  final AssetManagementService _service;

  AssetManagementNotifier(this._service) : super(const AssetManagementState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true);
    try {
      final buckets = _service.getAllBuckets();
      final assets = _service.getAllAssets();
      
      state = state.copyWith(
        buckets: buckets,
        assets: assets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load assets: $e',
        isLoading: false,
      );
    }
  }

  // Bucket management
  Future<void> createBucket({
    required String name,
    required String description,
    required String category,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final bucket = _service.createBucket(
        name: name,
        description: description,
        category: category,
      );
      
      final updatedBuckets = _service.getAllBuckets();
      state = state.copyWith(
        buckets: updatedBuckets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create bucket: $e',
        isLoading: false,
      );
    }
  }

  Future<void> deleteBucket(String bucketId) async {
    state = state.copyWith(isLoading: true);
    try {
      _service.deleteBucket(bucketId);
      
      final updatedBuckets = _service.getAllBuckets();
      final updatedAssets = _service.getAllAssets();
      
      state = state.copyWith(
        buckets: updatedBuckets,
        assets: updatedAssets,
        isLoading: false,
        selectedBucketId: state.selectedBucketId == bucketId ? null : state.selectedBucketId,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete bucket: $e',
        isLoading: false,
      );
    }
  }

  // Asset management
  Future<void> uploadAsset({
    required String bucketId,
    required String filePath,
    String? location,
    String? signType,
    String? condition,
    List<String> tags = const [],
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final file = File(filePath);
      await _service.uploadAsset(
        bucketId: bucketId,
        imageFile: file,
        location: location,
        signType: signType,
        condition: condition,
        tags: tags,
      );
      
      final updatedAssets = _service.getAllAssets();
      final updatedBuckets = _service.getAllBuckets();
      
      state = state.copyWith(
        assets: updatedAssets,
        buckets: updatedBuckets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to upload asset: $e',
        isLoading: false,
      );
    }
  }

  Future<void> deleteAsset(String assetId) async {
    state = state.copyWith(isLoading: true);
    try {
      _service.deleteAsset(assetId);
      
      final updatedAssets = _service.getAllAssets();
      final updatedBuckets = _service.getAllBuckets();
      
      state = state.copyWith(
        assets: updatedAssets,
        buckets: updatedBuckets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete asset: $e',
        isLoading: false,
      );
    }
  }

  // Search and filtering
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectBucket(String? bucketId) {
    state = state.copyWith(selectedBucketId: bucketId);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Import existing assets
  Future<void> importExistingAssets() async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.importExistingAssets();
      
      final updatedAssets = _service.getAllAssets();
      final updatedBuckets = _service.getAllBuckets();
      
      state = state.copyWith(
        assets: updatedAssets,
        buckets: updatedBuckets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to import existing assets: $e',
        isLoading: false,
      );
    }
  }
}

// Provider for the asset management state
final assetManagementProvider = StateNotifierProvider<AssetManagementNotifier, AssetManagementState>((ref) {
  final service = ref.watch(assetManagementServiceProvider);
  return AssetManagementNotifier(service);
});