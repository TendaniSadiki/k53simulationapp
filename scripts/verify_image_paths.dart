import 'dart:io';

void main() {
  print('=== VERIFYING IMAGE PATHS IN K53 QUESTION DATABASE ===\n');

  // Read the k53_question_database.dart file
  final databaseFile = File('scripts/k53_question_database.dart');
  if (!databaseFile.existsSync()) {
    print('❌ k53_question_database.dart not found!');
    return;
  }

  final content = databaseFile.readAsStringSync();
  
  // Extract all image URLs from the database
  final imageUrlPattern = RegExp(r"'image_url': '([^']+)'");
  final matches = imageUrlPattern.allMatches(content);
  
  final imageUrls = matches.map((match) => match.group(1)!).toList();
  
  print('Found ${imageUrls.length} image URLs in question database:\n');
  
  int validCount = 0;
  int invalidCount = 0;
  
  for (final imageUrl in imageUrls) {
    final file = File(imageUrl);
    final exists = file.existsSync();
    
    if (exists) {
      print('✅ $imageUrl');
      validCount++;
    } else {
      print('❌ $imageUrl (FILE NOT FOUND)');
      invalidCount++;
    }
  }
  
  print('\n=== SUMMARY ===');
  print('Total image URLs: ${imageUrls.length}');
  print('Valid paths: $validCount');
  print('Invalid paths: $invalidCount');
  
  if (invalidCount == 0) {
    print('\n🎉 All image paths are valid!');
  } else {
    print('\n⚠️  Some image paths need to be fixed.');
  }
  
  // Also check if all images in subdirectories have corresponding questions
  print('\n=== CHECKING IMAGE COVERAGE ===');
  
  final assetsDir = Directory('assets/individual_signs');
  if (!assetsDir.existsSync()) {
    print('❌ assets/individual_signs directory not found!');
    return;
  }
  
  // Get all subdirectories
  final subdirs = assetsDir.listSync()
    .where((entity) => entity is Directory)
    .map((dir) => dir.path)
    .toList();
  
  print('Found ${subdirs.length} subdirectories in assets/individual_signs/');
  
  int totalImages = 0;
  int imagesWithQuestions = 0;
  
  for (final subdir in subdirs) {
    final dirName = subdir.split('/').last;
    final files = Directory(subdir).listSync()
      .where((entity) => entity is File)
      .where((file) => file.path.endsWith('.png') || file.path.endsWith('.jpg'))
      .where((file) => !file.path.contains('sign_page_')) // Exclude sign_page_ files
      .toList();
    
    totalImages += files.length;
    
    // Check if any of these files have corresponding questions
    final filesWithQuestions = files.where((file) {
      final relativePath = file.path.replaceAll('\\', '/');
      return imageUrls.any((url) => url.contains(relativePath));
    }).toList();
    
    imagesWithQuestions += filesWithQuestions.length;
    
    print('$dirName: ${filesWithQuestions.length}/${files.length} images have questions');
  }
  
  print('\n=== COVERAGE SUMMARY ===');
  print('Total descriptive images: $totalImages');
  print('Images with questions: $imagesWithQuestions');
  print('Coverage: ${((imagesWithQuestions / totalImages) * 100).toStringAsFixed(1)}%');
  
  if (imagesWithQuestions < totalImages) {
    print('\n⚠️  Some images are missing questions!');
    print('Run: dart scripts/generate_image_question_plan.dart');
  }
}