import 'dart:io';

void main() {
  final signsDir = Directory('assets/individual_signs');
  
  if (!signsDir.existsSync()) {
    print('Directory not found: ${signsDir.path}');
    return;
  }

  print('=== MANUAL CATEGORY ANALYSIS ===');
  print('Based on previous analysis, these are the categories with named images:\n');

  // Manually define the categories we saw in the previous output
  final categories = [
    'CHANGES IN VEHICLE MOVEMENT AHEAD',
    'CODE 1',
    'CODE 2', 
    'CODE 3',
    'COLOUR COMBINATIONS',
    'COMMAND SIGNS',
    'COMPREHENSIVE SIGNS',
    'CONTROL SIGNS',
    'DE-RESTRICTION SIGNS',
    'DIRECTION SIGN SYMBOLS',
    'HAZARD MARKER PLATES',
    'INFORMATION SIGNS',
    'LIMIT PROHIBITION SIGNS',
    'LOCAL DIRECTION SIGN SYMBOLS',
    'LOCATION NAME SYMBOLS',
    'MOVING HAZARDS AHEAD',
    'PROHIBITION SIGNS',
    'RESERVATION SIGNS',
    'ROAD LAYOUT CHANGES AHEAD',
    'ROAD SITUATIONS AHEAD',
    'SELECTIVE RESTRICTION SIGNS',
    'SUPPLEMENTARY INFORMATION PLATES',
    'TOURISM SIGN SYMBOL',
    'TRAFFIC SIGNALS'
  ];

  var totalNamedImages = 0;
  final categoryStats = <String, List<String>>{};

  for (final category in categories) {
    final categoryDir = Directory('assets/individual_signs/$category');
    if (categoryDir.existsSync()) {
      final files = categoryDir.listSync().whereType<File>().toList();
      
      // Filter out sign_page_ files and only include properly named PNG files
      final namedImages = files.where((file) {
        final fileName = file.uri.pathSegments.last;
        return fileName.toLowerCase().endsWith('.png') && 
               !fileName.startsWith('sign_page_');
      }).map((file) => file.uri.pathSegments.last).toList();
      
      if (namedImages.isNotEmpty) {
        categoryStats[category] = namedImages;
        totalNamedImages += namedImages.length;
        
        print('$category (${namedImages.length} images):');
        for (final image in namedImages) {
          print('  - $image');
        }
        print('');
      }
    }
  }

  print('=== SUMMARY ===');
  print('Total named images: $totalNamedImages');
  print('Total categories with named images: ${categoryStats.length}');
  print('\nCategories:');
  categoryStats.forEach((category, images) {
    print('  $category: ${images.length} images');
  });

  // Generate SQL template
  print('\n=== SQL INSERT STATEMENTS ===');
  categoryStats.forEach((category, images) {
    print('\n-- $category Questions --');
    for (final image in images) {
      final imagePath = 'assets/individual_signs/$category/$image';
      final questionText = _generateQuestionText(image, category);
      
      print('''
INSERT INTO questions (category, difficulty, question_text, options, correct_option_index, explanation, points, image_url)
VALUES (
  'road_signs', 
  1, 
  '$questionText',
  '[{"text": "This is a $category sign indicating specific road regulations"},
    {"text": "This sign provides important information for road users"},
    {"text": "This is a regulatory sign that must be obeyed by all drivers"}]'::jsonb,
  0, 
  'This $category sign indicates specific road regulations that drivers must follow.',
  2, 
  '$imagePath'
);''');
    }
  });
}

String _generateQuestionText(String imageName, String category) {
  final cleanName = imageName.replaceAll('.png', '').replaceAll('_', ' ');
  return 'What does this $category road sign indicate?';
}