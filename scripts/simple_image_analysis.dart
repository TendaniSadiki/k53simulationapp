import 'dart:io';

void main() {
  final signsDir = Directory('assets/individual_signs');
  
  if (!signsDir.existsSync()) {
    print('Directory not found: ${signsDir.path}');
    return;
  }

  print('=== IMAGE DIRECTORY ANALYSIS ===');
  
  // List all directories
  final entities = signsDir.listSync();
  final directories = entities.whereType<Directory>().toList();
  final files = entities.whereType<File>().toList();
  
  print('Total directories: ${directories.length}');
  print('Total files in main directory: ${files.length}');
  
  // List directories with their contents
  for (final dir in directories) {
    final dirName = dir.uri.pathSegments.last;
    final dirFiles = dir.listSync().whereType<File>().toList();
    final pngFiles = dirFiles.where((file) => file.path.toLowerCase().endsWith('.png')).toList();
    
    print('\n$dirName (${pngFiles.length} PNG files):');
    for (final file in pngFiles.take(5)) {
      print('  - ${file.uri.pathSegments.last}');
    }
    if (pngFiles.length > 5) {
      print('  - ... and ${pngFiles.length - 5} more');
    }
  }
  
  // List files in main directory
  final mainPngFiles = files.where((file) => file.path.toLowerCase().endsWith('.png')).toList();
  print('\nMain directory PNG files (${mainPngFiles.length}):');
  for (final file in mainPngFiles.take(10)) {
    print('  - ${file.uri.pathSegments.last}');
  }
  if (mainPngFiles.length > 10) {
    print('  - ... and ${mainPngFiles.length - 10} more');
  }
  
  // Count total PNG files recursively
  final allPngFiles = _getAllPngFiles(signsDir);
  print('\n=== TOTAL COUNT ===');
  print('Total PNG files (recursive): ${allPngFiles.length}');
}

List<File> _getAllPngFiles(Directory dir) {
  return dir.listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.png'))
      .toList();
}