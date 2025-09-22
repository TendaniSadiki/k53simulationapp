import 'dart:io';

void main() {
  final signsDir = Directory('assets/individual_signs');
  
  if (!signsDir.existsSync()) {
    print('Directory not found: ${signsDir.path}');
    return;
  }

  // Get all PNG files recursively
  final allImages = _getAllImages(signsDir);
  print('Total images found: ${allImages.length}');
  
  // Get categories (subdirectories)
  final categories = _getCategories(signsDir);
  print('Categories found: ${categories.length}');
  
  // Count images in main directory
  final mainDirImages = _listImages(signsDir);
  print('\nMain directory images: ${mainDirImages.length}');
  for (final image in mainDirImages.take(10)) {
    print('  - $image');
  }
  if (mainDirImages.length > 10) {
    print('  - ... and ${mainDirImages.length - 10} more');
  }
  
  // Count images in each category
  print('\n=== CATEGORY ANALYSIS ===');
  for (final category in categories) {
    final categoryDir = Directory('assets/individual_signs/$category');
    if (categoryDir.existsSync()) {
      final categoryImages = _listImages(categoryDir);
      if (categoryImages.isNotEmpty) {
        print('\n$category (${categoryImages.length} images):');
        for (final image in categoryImages.take(5)) {
          print('  - $image');
        }
        if (categoryImages.length > 5) {
          print('  - ... and ${categoryImages.length - 5} more');
        }
      }
    }
  }
  
  // Generate summary
  print('\n=== SUMMARY ===');
  print('Total images: ${allImages.length}');
  print('Main directory images: ${mainDirImages.length}');
  
  var categoryImageCount = 0;
  for (final category in categories) {
    final categoryDir = Directory('assets/individual_signs/$category');
    if (categoryDir.existsSync()) {
      final categoryImages = _listImages(categoryDir);
      categoryImageCount += categoryImages.length;
      print('$category: ${categoryImages.length} images');
    }
  }
  
  print('Category images total: $categoryImageCount');
  print('Verification: ${mainDirImages.length + categoryImageCount} should equal ${allImages.length}');
}

List<String> _getAllImages(Directory dir) {
  return dir.listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.png'))
      .map((file) => file.path)
      .toList();
}

List<String> _getCategories(Directory dir) {
  return dir.listSync()
      .whereType<Directory>()
      .map((dir) => dir.uri.pathSegments.last)
      .where((name) => !name.startsWith('.')) // exclude hidden directories
      .toList();
}

List<String> _listImages(Directory dir) {
  if (!dir.existsSync()) return [];
  
  return dir.listSync()
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.png'))
      .map((file) => file.uri.pathSegments.last)
      .toList();
}