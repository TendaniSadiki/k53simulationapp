import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  print('=== TESTING ASSET LOADING WITH SPACES ===\n');
  
  // Test problematic file names
  final testFiles = [
    'assets/individual_signs/DE-RESTRICTION SIGNS/End of dual carriage freeway and freeway rules no longer apply.png',
    'assets/individual_signs/DE-RESTRICTION SIGNS/End of lane use reservation and all vehicles may now use this lane.png',
    'assets/individual_signs/DE-RESTRICTION SIGNS/End of residential area and rules for a residential area no longer apply.png',
    'assets/individual_signs/DE-RESTRICTION SIGNS/End of single carriage freeway and freeway rules no longer apply.png',
    'assets/individual_signs/DE-RESTRICTION SIGNS/End of toll road.png',
    'assets/individual_signs/DE-RESTRICTION SIGNS/You no longer need to drive with your headlights switched on.png',
    'assets/individual_signs/CODE 1/code1.png',
  ];
  
  for (final filePath in testFiles) {
    final file = File(filePath);
    final exists = file.existsSync();
    
    print('${exists ? '✅' : '❌'} $filePath');
    print('   File exists: $exists');
    
    if (exists) {
      final stat = file.statSync();
      print('   File size: ${stat.size} bytes');
      print('   Modified: ${stat.modified}');
      
      // Check if it's a valid PNG
      try {
        final bytes = file.readAsBytesSync();
        final isPng = bytes.length > 8 && 
                      bytes[0] == 0x89 && 
                      bytes[1] == 0x50 && 
                      bytes[2] == 0x4E && 
                      bytes[3] == 0x47;
        print('   PNG signature: ${isPng ? 'VALID' : 'INVALID'}');
      } catch (e) {
        print('   Error reading file: $e');
      }
    }
    print('');
  }
  
  // Check directory structure
  print('=== DIRECTORY STRUCTURE ANALYSIS ===\n');
  
  final assetsDir = Directory('assets/individual_signs');
  if (assetsDir.existsSync()) {
    final subdirs = assetsDir.listSync();
    print('Found ${subdirs.length} items in assets/individual_signs/');
    
    for (final item in subdirs) {
      if (item is Directory) {
        final dirName = path.basename(item.path);
        final files = item.listSync();
        print('📁 $dirName/ (${files.length} files)');
        
        // Show first few files in each directory
        for (var i = 0; i < files.length && i < 3; i++) {
          final file = files[i];
          if (file is File) {
            final fileName = path.basename(file.path);
            print('   📄 $fileName');
          }
        }
        if (files.length > 3) {
          print('   ... and ${files.length - 3} more files');
        }
      }
    }
  }
  
  print('\n=== RECOMMENDATIONS ===');
  print('1. Use SafeImageWidget for all image loading');
  print('2. Ensure pubspec.yaml has: assets/individual_signs/');
  print('3. Consider renaming files with spaces to use underscores');
  print('4. Test asset loading after flutter pub get and app restart');
}