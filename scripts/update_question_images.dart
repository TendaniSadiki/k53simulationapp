import 'dart:io';

void main() {
  print('Updating question images in SQL files...\n');
  
  // Read the original seed file
  final seedFile = File('scripts/seed_evolve_questions.sql');
  final content = seedFile.readAsStringSync();
  
  // Define image mappings for specific questions
  final imageMappings = {
    // Rules of Road questions that benefit from images
    'When may you not overtake another vehicle?... When you ...': 
        'assets/individual_signs/SELECTIVE RESTRICTION SIGNS/Overtaking prohibited for the next 2km.png',
    
    'At an intersection...': 
        'assets/individual_signs/Indicates that you must yield to other traffic. Gi.png',
    
    'Unless otherwise shown by a sign, the general speed limit in an urban area is ...km/h.': 
        'assets/individual_signs/Maximum speed limit allowed.png',
    
    'The legal speed limit which you may drive...': 
        'assets/individual_signs/Maximum speed limit allowed.png',
    
    'What is the longest period that a vehicle may be parked on one place on a road outside urban areas?': 
        'assets/individual_signs/Residential area.png',
    
    'You are not allowed to stop...': 
        'assets/individual_signs/No stopping to ensure traffic flow and prevent dri.png',
    
    'You may overtake another vehicle on the left hand side...': 
        'assets/individual_signs/SELECTIVE RESTRICTION SIGNS/No over taking vehicles by goods vehicles for the next 500m.png',
  };

  // Split the content into lines
  final lines = content.split('\n');
  final updatedLines = <String>[];
  
  bool inValuesSection = false;
  
  for (final line in lines) {
    if (line.contains('VALUES')) {
      inValuesSection = true;
      updatedLines.add(line);
      continue;
    }
    
    if (inValuesSection && line.trim().startsWith('--')) {
      // Comment line, keep as is
      updatedLines.add(line);
      continue;
    }
    
    if (inValuesSection && line.contains('(') && line.contains('rules_of_road')) {
      // Check if this line contains a question that needs an image
      var updatedLine = line;
      
      for (final question in imageMappings.keys) {
        if (line.contains(question)) {
          // Remove the trailing closing parenthesis and difficulty level
          if (line.trim().endsWith('),')) {
            updatedLine = line.substring(0, line.lastIndexOf('),')) +
                ', \'' + imageMappings[question]! + '\'),';
          } else if (line.trim().endsWith(')')) {
            updatedLine = line.substring(0, line.lastIndexOf(')')) +
                ', \'' + imageMappings[question]! + '\')';
          }
          break;
        }
      }
      
      updatedLines.add(updatedLine);
    } else {
      updatedLines.add(line);
    }
    
    if (inValuesSection && line.contains(');')) {
      inValuesSection = false;
    }
  }
  
  // Write the updated content to a new file
  final updatedContent = updatedLines.join('\n');
  final outputFile = File('scripts/seed_evolve_questions_with_images_updated.sql');
  outputFile.writeAsStringSync(updatedContent);
  
  print('✅ Updated SQL file created: scripts/seed_evolve_questions_with_images_updated.sql');
  print('The file includes image URLs for relevant road sign questions.');
  print('\nNext steps:');
  print('1. Review the updated SQL file');
  print('2. Run both files in this order:');
  print('   - scripts/road_sign_questions_output.sql (for road sign specific questions)');
  print('   - scripts/seed_evolve_questions_with_images_updated.sql (for rules of road questions with images)');
  print('3. Test the question database functionality');
}