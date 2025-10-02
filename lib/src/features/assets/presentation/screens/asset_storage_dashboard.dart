                  import 'package:flutter/material.dart';
                  import 'package:flutter_riverpod/flutter_riverpod.dart';
                  import '../providers/asset_management_provider.dart';
                  import '../../../../shared/widgets/safe_image_widget.dart';
                  import '../../../../core/models/road_sign_asset.dart';

class AssetStorageDashboard extends ConsumerWidget {
  const AssetStorageDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assetManagementProvider);
    final notifier = ref.read(assetManagementProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Road Sign Assets'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.importExistingAssets(),
            tooltip: 'Import Existing Assets',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateBucketDialog(context, notifier),
            tooltip: 'Create New Bucket',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(notifier, state.searchQuery),
          
          // Statistics Overview
          _buildStatisticsOverview(state),
          
          // Bucket Navigation
          _buildBucketNavigation(state, notifier),
          
          // Content Area
          Expanded(
            child: _buildContentArea(state, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadDialog(context, notifier, state),
        child: const Icon(Icons.upload),
        tooltip: 'Upload Asset',
      ),
    );
  }

  Widget _buildSearchBar(AssetManagementNotifier notifier, String searchQuery) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: TextEditingController(text: searchQuery),
        decoration: InputDecoration(
          hintText: 'Search all assets...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => notifier.clearSearch(),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: notifier.setSearchQuery,
      ),
    );
  }

  Widget _buildStatisticsOverview(AssetManagementState state) {
    final stats = state.statistics;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Assets',
            stats['total_assets'].toString(),
            Icons.image,
          ),
          _buildStatItem(
            'Buckets',
            stats['total_buckets'].toString(),
            Icons.folder,
          ),
          _buildStatItem(
            'Storage',
            stats['formatted_total_size'],
            Icons.storage,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[700],
          ),
        ),
      ],
    );
  }

  Widget _buildBucketNavigation(AssetManagementState state, AssetManagementNotifier notifier) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All Buckets option
          _buildBucketChip(
            'All Buckets',
            null,
            state.selectedBucketId == null,
            notifier,
          ),
          // Individual buckets
          ...state.buckets.map((bucket) => _buildBucketChip(
            bucket.name,
            bucket.id,
            state.selectedBucketId == bucket.id,
            notifier,
          )),
        ],
      ),
    );
  }

  Widget _buildBucketChip(
    String label,
    String? bucketId,
    bool isSelected,
    AssetManagementNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => notifier.selectBucket(bucketId),
        selectedColor: Colors.blue[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue[900] : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildContentArea(AssetManagementState state, AssetManagementNotifier notifier) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyle(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.clearError(),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
    }

    // Show global search results if searching
    if (state.searchQuery.isNotEmpty) {
      final globalResults = state.globallySearchedAssets;
      return _buildAssetGrid(globalResults, notifier, 'Search Results');
    }

    // Show bucket-specific content
    final assets = state.filteredAssets;
    final bucketName = state.selectedBucket?.name ?? 'All Buckets';
    
    return _buildAssetGrid(assets, notifier, bucketName);
  }

  Widget _buildAssetGrid(
    List<RoadSignAsset> assets,
    AssetManagementNotifier notifier,
    String title,
  ) {
    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No assets found in $title',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload assets to get started',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '$title (${assets.length} assets)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              return _buildAssetCard(asset, notifier);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAssetCard(RoadSignAsset asset, AssetManagementNotifier notifier) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Image Preview
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                color: Colors.grey[100],
              ),
              child: SafeImageWidget(
                imagePath: asset.filePath,
                fit: BoxFit.contain,
                placeholder: Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 32, color: Colors.grey),
                ),
              ),
            ),
          ),
          
          // Asset Info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${asset.width}x${asset.height} • ${asset.formattedFileSize}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                if (asset.location != null)
                  Text(
                    asset.location!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateBucketDialog(BuildContext context, AssetManagementNotifier notifier) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Bucket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Bucket Name',
                hintText: 'e.g., regulatory_signs',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Collection of regulatory road signs',
              ),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g., regulatory, warning, information',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  categoryController.text.isNotEmpty) {
                notifier.createBucket(
                  name: nameController.text,
                  description: descriptionController.text,
                  category: categoryController.text,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(
    BuildContext context,
    AssetManagementNotifier notifier,
    AssetManagementState state,
  ) {
    // This would typically use file_picker or similar package
    // For now, we'll show a placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Asset'),
        content: const Text('Asset upload functionality would be implemented here with file picker integration.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}