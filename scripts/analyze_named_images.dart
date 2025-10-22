import 'dart:io';

void main() {
  final signsDir = Directory('assets/individual_signs');
  
  if (!signsDir.existsSync()) {
    print('Directory not found: ${signsDir.path}');
    return;
  }

  print('=== NAMED IMAGE ANALYSIS (EXCLUDING sign_page_ FILES) ===');
  
  // List all directories
  final directories = signsDir.listSync().whereType<Directory>().toList();
  
  print('Total categories: ${directories.length}');
  
  // Analyze each category
  var totalNamedImages = 0;
  final categoryStats = <String, int>{};
  
  for (final dir in directories) {
    final dirName = dir.uri.pathSegments.last;
    final files = dir.listSync().whereType<File>().toList();
    
    // Filter out sign_page_ files and only include properly named PNG files
    final namedImages = files.where((file) {
      final fileName = file.uri.pathSegments.last;
      return fileName.toLowerCase().endsWith('.png') && 
             !fileName.startsWith('sign_page_');
    }).toList();
    
    if (namedImages.isNotEmpty) {
      categoryStats[dirName] = namedImages.length;
      totalNamedImages += namedImages.length;
      
      print('\n$dirName (${namedImages.length} named images):');
      for (final file in namedImages.take(5)) {
        print('  - ${file.uri.pathSegments.last}');
      }
      if (namedImages.length > 5) {
        print('  - ... and ${namedImages.length - 5} more');
      }
    }
  }
  
  print('\n=== SUMMARY ===');
  print('Total named images (excluding sign_page_ files): $totalNamedImages');
  print('Categories with named images:');
  categoryStats.forEach((category, count) {
    print('  $category: $count images');
  });
  
  // Also check if there are any named images in the main directory
  final mainFiles = signsDir.listSync().whereType<File>().toList();
  final mainNamedImages = mainFiles.where((file) {
    final fileName = file.uri.pathSegments.last;
    return fileName.toLowerCase().endsWith('.png') && 
           !fileName.startsWith('sign_page_');
  }).toList();
  
  if (mainNamedImages.isNotEmpty) {
    print('\nMain directory named images (${mainNamedImages.length}):');
    for (final file in mainNamedImages) {
      print('  - ${file.uri.pathSegments.last}');
    }
  }
}