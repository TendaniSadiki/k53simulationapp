import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  print('=== Generating RooCode Structure from Assets Directory ===\n');
  
  final assetsDir = Directory('assets/individual_signs');
  if (!assetsDir.existsSync()) {
    print('❌ Assets directory not found: ${assetsDir.path}');
    return;
  }
  
  // Get all top-level directories
  final entities = assetsDir.listSync();
  final folders = <String>[];
  
  for (final entity in entities) {
    if (entity is Directory) {
      final folderName = path.basename(entity.path);
      folders.add(folderName);
    }
  }
  
  // Sort folders alphabetically
  folders.sort();
  
  print('📁 Found ${folders.length} folders in assets/individual_signs/');
  print('\n=== FOLDER STRUCTURE ===');
  
  for (final folder in folders) {
    print('  📂 $folder');
    
    // Count files in each folder
    final folderDir = Directory(path.join(assetsDir.path, folder));
    final files = folderDir.listSync().where((e) => e is File).toList();
    print('     📄 ${files.length} files');
    
    // Show first few files as examples
    for (var i = 0; i < files.length && i < 3; i++) {
      final file = files[i] as File;
      final fileName = path.basename(file.path);
      print('        • $fileName');
    }
    if (files.length > 3) {
      print('        • ... and ${files.length - 3} more files');
    }
  }
  
  // Generate RooCode YAML content
  final yamlContent = _generateYamlContent(folders);
  final jsonContent = _generateJsonContent(folders);
  
  print('\n=== ROOCODE YAML OUTPUT ===');
  print(yamlContent);
  
  print('\n=== ROOCODE JSON OUTPUT ===');
  print(jsonContent);
  
  // Write to files
  _writeRooCodeFiles(yamlContent, jsonContent, folders.length);
}

String _generateYamlContent(List<String> folders) {
  final buffer = StringBuffer();
  
  buffer.writeln('# RooCode Definition: Road Signs Storage Structure');
  buffer.writeln('# This file defines the bucket and folder hierarchy for K53 road sign assets');
  buffer.writeln('# Generated from the existing assets/individual_signs/ directory structure');
  buffer.writeln();
  buffer.writeln('bucket: road_signs');
  buffer.writeln('description: "K53 Road Sign Assets - Comprehensive collection of South African road signs"');
  buffer.writeln('category: regulatory');
  buffer.writeln('folders:');
  
  for (final folder in folders) {
    buffer.writeln('  - $folder');
  }
  
  buffer.writeln();
  buffer.writeln('metadata:');
  buffer.writeln('  total_folders: ${folders.length}');
  buffer.writeln('  asset_types:');
  buffer.writeln('    - regulatory_signs');
  buffer.writeln('    - warning_signs');
  buffer.writeln('    - information_signs');
  buffer.writeln('    - command_signs');
  buffer.writeln('    - prohibition_signs');
  buffer.writeln('  file_formats:');
  buffer.writeln('    - png');
  buffer.writeln('    - jpg');
  buffer.writeln('    - jpeg');
  buffer.writeln('  organization: hierarchical');
  buffer.writeln('  version: 1.0');
  buffer.writeln('  created: ${DateTime.now().toIso8601String().split('T').first}');
  buffer.writeln('  source: assets/individual_signs/');
  
  return buffer.toString();
}

String _generateJsonContent(List<String> folders) {
  final buffer = StringBuffer();
  
  buffer.writeln('{');
  buffer.writeln('  "bucket": "road_signs",');
  buffer.writeln('  "description": "K53 Road Sign Assets - Comprehensive collection of South African road signs",');
  buffer.writeln('  "category": "regulatory",');
  buffer.writeln('  "folders": [');
  
  for (var i = 0; i < folders.length; i++) {
    buffer.write('    "${folders[i]}"');
    if (i < folders.length - 1) {
      buffer.write(',');
    }
    buffer.writeln();
  }
  
  buffer.writeln('  ],');
  buffer.writeln('  "metadata": {');
  buffer.writeln('    "total_folders": ${folders.length},');
  buffer.writeln('    "asset_types": [');
  buffer.writeln('      "regulatory_signs",');
  buffer.writeln('      "warning_signs",');
  buffer.writeln('      "information_signs",');
  buffer.writeln('      "command_signs",');
  buffer.writeln('      "prohibition_signs"');
  buffer.writeln('    ],');
  buffer.writeln('    "file_formats": [');
  buffer.writeln('      "png",');
  buffer.writeln('      "jpg",');
  buffer.writeln('      "jpeg"');
  buffer.writeln('    ],');
  buffer.writeln('    "organization": "hierarchical",');
  buffer.writeln('    "version": "1.0",');
  buffer.writeln('    "created": "${DateTime.now().toIso8601String().split('T').first}",');
  buffer.writeln('    "source": "assets/individual_signs/"');
  buffer.writeln('  }');
  buffer.writeln('}');
  
  return buffer.toString();
}

void _writeRooCodeFiles(String yamlContent, String jsonContent, int folderCount) {
  final yamlFile = File('road_signs_structure.roocode.yaml');
  final jsonFile = File('road_signs_structure.roocode.json');
  
  yamlFile.writeAsStringSync(yamlContent);
  jsonFile.writeAsStringSync(jsonContent);
  
  print('\n✅ Generated RooCode structure files:');
  print('   📄 ${yamlFile.path}');
  print('   📄 ${jsonFile.path}');
  print('   📁 Total folders documented: $folderCount');
  
  print('\n=== USAGE ===');
  print('• Use these files for programmatic reference to your storage structure');
  print('• Integrate with asset management systems and code generation tools');
  print('• Maintain consistency across development and deployment environments');
}