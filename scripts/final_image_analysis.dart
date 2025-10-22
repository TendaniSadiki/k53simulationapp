import 'dart:io';

void main() {
  final signsDir = Directory('assets/individual_signs');
  
  if (!signsDir.existsSync()) {
    print('Directory not found: ${signsDir.path}');
    return;
  }

  print('=== COMPREHENSIVE IMAGE ANALYSIS ===');
  print('Analyzing properly named images (excluding sign_page_ files)\n');
  
  // Get all directories with proper names
  final directories = signsDir.listSync()
      .whereType<Directory>()
      .where((dir) => dir.uri.pathSegments.last.isNotEmpty)
      .toList();

  final categoryStats = <String, List<String>>{};
  var totalNamedImages = 0;

  // Analyze each category
  for (final dir in directories) {
    final categoryName = dir.uri.pathSegments.last;
    final files = dir.listSync().whereType<File>().toList();
    
    // Filter out sign_page_ files and only include properly named PNG files
    final namedImages = files.where((file) {
      final fileName = file.uri.pathSegments.last;
      return fileName.toLowerCase().endsWith('.png') && 
             !fileName.startsWith('sign_page_');
    }).map((file) => file.uri.pathSegments.last).toList();
    
    if (namedImages.isNotEmpty) {
      categoryStats[categoryName] = namedImages;
      totalNamedImages += namedImages.length;
      
      print('$categoryName (${namedImages.length} images):');
      for (final image in namedImages) {
        print('  - $image');
      }
      print('');
    }
  }

  print('=== SUMMARY ===');
  print('Total named images: $totalNamedImages');
  print('Total categories with named images: ${categoryStats.length}');
  print('\nCategories:');
  categoryStats.forEach((category, images) {
    print('  $category: ${images.length} images');
  });

  // Generate SQL template for these images
  print('\n=== SQL TEMPLATE FOR NAMED IMAGES ===');
  categoryStats.forEach((category, images) {
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
  });
}

String _generateQuestionText(String imageName, String category) {
  final cleanName = imageName.replaceAll('.png', '').replaceAll('_', ' ');
  return 'What does this $category road sign indicate?';
}