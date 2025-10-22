import 'dart:io';

void main() {
  final signsDir = Directory('assets/individual_signs');
  final allImages = _getAllImages(signsDir);
  final categories = _getCategories(signsDir);
  
  print('Total images found: ${allImages.length}');
  print('Categories: ${categories.length}');
  
  // Count images in each category
  final categoryCounts = <String, int>{};
  for (final category in categories) {
    final categoryDir = Directory('assets/individual_signs/$category');
    final categoryImages = _listImages(categoryDir);
    categoryCounts[category] = categoryImages.length;
  }
  
  // Print main directory images
  final mainDirImages = _listImages(signsDir);
  print('\nMain directory (${mainDirImages.length} images):');
  for (final image in mainDirImages.take(10)) {
    print('  - $image');
  }
  if (mainDirImages.length > 10) {
    print('  - ... and ${mainDirImages.length - 10} more');
  }
  
  // Print category images
  for (final category in categories) {
    final categoryDir = Directory('assets/individual_signs/$category');
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
  
  // Generate SQL template
  _generateSqlTemplate(categories, signsDir, mainDirImages);
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
      .toList();
}

List<String> _listImages(Directory dir) {
  return dir.listSync()
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.png'))
      .map((file) => file.uri.pathSegments.last)
      .toList();
}

void _generateSqlTemplate(List<String> categories, Directory signsDir, List<String> mainDirImages) {
  print('\n\n=== SQL TEMPLATE GENERATION ===');
  
  // Generate for main directory images
  if (mainDirImages.isNotEmpty) {
    print('\n-- Main Directory Questions --');
    for (final image in mainDirImages) {
      final imagePath = 'assets/individual_signs/$image';
      final questionText = _generateQuestionText(image, 'road sign');
      
      print('''
    -- ${image.replaceAll('.png', '')}
    ('road_signs', 1, '$questionText',
     '[{"text": "This is a road sign indicating specific road regulations"},
       {"text": "This sign provides important information for road users"},
       {"text": "This is a regulatory sign that must be obeyed by all drivers"}]'::jsonb,
      0, 'This road sign indicates specific road regulations that drivers must follow.',
      2, '$imagePath'),''');
    }
  }
  
  // Generate for category images
  for (final category in categories) {
    final categoryDir = Directory('assets/individual_signs/$category');
    final images = _listImages(categoryDir);
    
    if (images.isNotEmpty) {
      print('\n-- $category Questions --');
      for (final image in images) {
        final imagePath = 'assets/individual_signs/$category/$image';
        final questionText = _generateQuestionText(image, category);
        
        print('''
    -- ${image.replaceAll('.png', '')}
    ('road_signs', 1, '$questionText',
     '[{"text": "This is a $category sign indicating specific road regulations"},
       {"text": "This sign provides important information for road users"},
       {"text": "This is a regulatory sign that must be obeyed by all drivers"}]'::jsonb,
      0, 'This $category sign indicates specific road regulations that drivers must follow.',
      2, '$imagePath'),''');
      }
    }
  }
}

String _generateQuestionText(String imageName, String category) {
  final cleanName = imageName.replaceAll('.png', '').replaceAll('_', ' ');
  return 'What does this $category road sign indicate?';
}