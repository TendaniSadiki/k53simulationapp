import 'dart:io';

void main() {
  // List of road sign images with descriptive names (avoiding sign_page_ prefix)
  final roadSignImages = [
    'Maximum speed limit allowed.png',
    'No stopping to ensure traffic flow and prevent dri.png',
    'Over taking vehicles is prohibited for the next 500m.png',
    'Overtaking prohibited for the next 2km.png',
    'Parking here is reserved for a vehicle carrying people with disabilities.png',
    'Parking only if you pay the parking fee.png',
    'Parking_30min_Week_09-16_Sat_08-13.png.png',
    'Residential area.png',
    'Indicates that you must yield to other traffic. Gi.png',
    'No over taking vehicles by goods vehicles for the next 500m.png',
    'No vehicles may enter this road at any time.png',
    'Applies only to mini-buses.png',
    'Come to a complete halt in line with the stop sign.png',
    'To indicate that you must move in a clockwise direction at the junction.png',
    'Traffic circle ahead ( mini circle or round about)..png',
    'Give way to any pedestrians on or about to enter t.png',
    'Dual-carriage freeway begins The following rules apply to all freeways.png',
    'End of dual carriage freeway and freeway rules no longer apply.png',
    'Gross vehicle mass limit allowed.png',
  ];

  // Categories for better organization
  final categories = {
    'regulatory': 'Regulatory Signs',
    'warning': 'Warning Signs', 
    'informational': 'Informational Signs',
    'prohibition': 'Prohibition Signs',
    'command': 'Command Signs',
    'freeway': 'Freeway Signs',
    'mass_dimension': 'Mass/Dimension Signs'
  };

  // Questions mapped to specific images
  final questions = [
    // Regulatory signs
    {
      'image': 'Maximum speed limit allowed.png',
      'question': 'What does this sign indicate?',
      'options': ['Maximum speed limit allowed', 'Minimum speed requirement', 'Recommended speed'],
      'correct': 0,
      'explanation': 'This circular sign with red border indicates the maximum speed limit allowed on this road section.',
      'category': 'regulatory',
      'difficulty': 1
    },
    {
      'image': 'No stopping to ensure traffic flow and prevent dri.png',
      'question': 'This sign prohibits:',
      'options': ['No stopping to ensure traffic flow', 'No parking allowed', 'Loading zone only'],
      'correct': 0,
      'explanation': 'The no stopping sign prohibits any stopping to maintain traffic flow and prevent disruptions.',
      'category': 'regulatory',
      'difficulty': 1
    },
    {
      'image': 'Parking only if you pay the parking fee.png',
      'question': 'This parking sign indicates:',
      'options': ['Paid parking only', 'Free parking available', 'No parking at any time'],
      'correct': 0,
      'explanation': 'The parking fee sign shows that parking is only permitted if the parking fee is paid.',
      'category': 'regulatory',
      'difficulty': 1
    },
    {
      'image': 'Parking_30min_Week_09-16_Sat_08-13.png.png',
      'question': 'What does this parking restriction sign specify?',
      'options': ['30-minute parking limit on weekdays 09-16, Saturday 08-13', 'No parking during these times', 'Free parking during these hours'],
      'correct': 0,
      'explanation': 'Time-restricted parking signs specify the maximum parking duration and applicable time periods.',
      'category': 'regulatory',
      'difficulty': 2
    },
    {
      'image': 'Parking here is reserved for a vehicle carrying people with disabilities.png',
      'question': 'This reserved parking is for:',
      'options': ['Vehicles carrying people with disabilities', 'Emergency vehicles only', 'Official government vehicles'],
      'correct': 0,
      'explanation': 'Disabled parking signs reserve spaces specifically for vehicles transporting people with disabilities.',
      'category': 'regulatory',
      'difficulty': 1
    },

    // Prohibition signs
    {
      'image': 'Over taking vehicles is prohibited for the next 500m.png',
      'question': 'This sign means:',
      'options': ['Overtaking prohibited for 500m', 'No U-turns allowed', 'No right turns'],
      'correct': 0,
      'explanation': 'General overtaking prohibition signs ban all overtaking maneuvers for the specified distance.',
      'category': 'prohibition',
      'difficulty': 1
    },
    {
      'image': 'Overtaking prohibited for the next 2km.png',
      'question': 'This sign prohibits:',
      'options': ['Overtaking for the next 2km', 'Stopping for any reason', 'Turning right'],
      'correct': 0,
      'explanation': 'The overtaking prohibition sign with distance indication bans overtaking for the specified distance.',
      'category': 'prohibition',
      'difficulty': 1
    },
    {
      'image': 'No over taking vehicles by goods vehicles for the next 500m.png',
      'question': 'What restriction does this sign impose on goods vehicles?',
      'options': ['No overtaking for 500m', 'Speed limit of 50km/h', 'No entry for goods vehicles'],
      'correct': 0,
      'explanation': 'This specific prohibition applies only to goods vehicles regarding overtaking for the specified distance.',
      'category': 'prohibition',
      'difficulty': 2
    },
    {
      'image': 'No vehicles may enter this road at any time.png',
      'question': 'What does this sign prohibit?',
      'options': ['No vehicles may enter this road', 'No heavy vehicles allowed', 'No pedestrians allowed'],
      'correct': 0,
      'explanation': 'The no entry sign completely prohibits any vehicles from entering the road from this direction.',
      'category': 'prohibition',
      'difficulty': 1
    },
    {
      'image': 'Applies only to mini-buses.png',
      'question': 'This sign applies:',
      'options': ['Only to mini-buses', 'To all vehicles', 'Only to trucks'],
      'correct': 0,
      'explanation': 'Signs with specific vehicle type restrictions apply only to the indicated vehicle category.',
      'category': 'prohibition',
      'difficulty': 2
    },

    // Command signs
    {
      'image': 'Come to a complete halt in line with the stop sign.png',
      'question': 'When you see this sign, you must:',
      'options': ['Come to a complete halt', 'Slow down and proceed', 'Sound your horn'],
      'correct': 0,
      'explanation': 'Stop signs require a complete halt at the stop line or before entering the intersection.',
      'category': 'command',
      'difficulty': 1
    },
    {
      'image': 'To indicate that you must move in a clockwise direction at the junction.png',
      'question': 'This sign indicates you must:',
      'options': ['Move in a clockwise direction', 'Turn right only', 'Make a U-turn'],
      'correct': 0,
      'explanation': 'Circular direction signs mandate the direction of travel around traffic circles or roundabouts.',
      'category': 'command',
      'difficulty': 2
    },
    {
      'image': 'Indicates that you must yield to other traffic. Gi.png',
      'question': 'What action must you take when you see this sign?',
      'options': ['Yield to other traffic', 'Stop completely', 'Proceed with caution'],
      'correct': 0,
      'explanation': 'The yield sign (inverted triangle) requires you to give way to other vehicles on the major road.',
      'category': 'command',
      'difficulty': 1
    },

    // Warning signs
    {
      'image': 'Traffic circle ahead ( mini circle or round about)..png',
      'question': 'This sign warns of:',
      'options': ['Traffic circle ahead', 'Sharp curve ahead', 'Pedestrian crossing'],
      'correct': 0,
      'explanation': 'Roundabout warning signs alert drivers to an upcoming traffic circle requiring reduced speed and caution.',
      'category': 'warning',
      'difficulty': 1
    },
    {
      'image': 'Give way to any pedestrians on or about to enter t.png',
      'question': 'What should you do when you see this sign?',
      'options': ['Give way to pedestrians', 'Increase speed', 'Change lanes'],
      'correct': 0,
      'explanation': 'Pedestrian warning signs indicate areas where pedestrians may be crossing and require extra caution.',
      'category': 'warning',
      'difficulty': 1
    },

    // Freeway signs
    {
      'image': 'Dual-carriage freeway begins The following rules apply to all freeways.png',
      'question': 'This sign indicates:',
      'options': ['Dual-carriage freeway begins', 'Freeway ends ahead', 'Toll road ahead'],
      'correct': 0,
      'explanation': 'Freeway beginning signs mark the start of freeway sections where specific freeway rules apply.',
      'category': 'freeway',
      'difficulty': 2
    },
    {
      'image': 'End of dual carriage freeway and freeway rules no longer apply.png',
      'question': 'When you see this sign:',
      'options': ['Freeway rules no longer apply', 'Freeway begins ahead', 'Toll payment required'],
      'correct': 0,
      'explanation': 'Freeway end signs indicate that you are leaving the freeway and standard road rules resume.',
      'category': 'freeway',
      'difficulty': 2
    },

    // Informational signs
    {
      'image': 'Residential area.png',
      'question': 'Entering this area means:',
      'options': ['Residential area rules apply', 'Commercial zone begins', 'Industrial area ahead'],
      'correct': 0,
      'explanation': 'The residential area sign indicates that special rules for residential zones now apply, including lower speed limits.',
      'category': 'informational',
      'difficulty': 1
    },

    // Mass/Dimension signs
    {
      'image': 'Gross vehicle mass limit allowed.png',
      'question': 'This sign indicates the maximum allowed:',
      'options': ['Gross vehicle mass', 'Vehicle height', 'Vehicle width'],
      'correct': 0,
      'explanation': 'Gross vehicle mass signs specify the maximum total weight allowed for vehicles on this road.',
      'category': 'mass_dimension',
      'difficulty': 2
    }
  ];

  // Generate SQL output
  final sqlBuffer = StringBuffer();
  sqlBuffer.writeln('-- Road Sign Specific Questions for K53 Test');
  sqlBuffer.writeln('-- Generated by scripts/seed_road_sign_questions.dart');
  sqlBuffer.writeln('-- These questions focus specifically on road sign recognition and interpretation');
  sqlBuffer.writeln('-- Uses only descriptive image names (avoids sign_page_ prefixed images)');
  sqlBuffer.writeln('');
  sqlBuffer.writeln('INSERT INTO questions (id, category, learner_code, question_text, options, correct_index, explanation, version, is_active, difficulty_level, image_url, created_at, updated_at)');
  sqlBuffer.writeln('SELECT ');
  sqlBuffer.writeln('  gen_random_uuid(),');
  sqlBuffer.writeln('  data.category,');
  sqlBuffer.writeln('  data.learner_code,');
  sqlBuffer.writeln('  data.question_text,');
  sqlBuffer.writeln('  data.options,');
  sqlBuffer.writeln('  data.correct_index,');
  sqlBuffer.writeln('  data.explanation,');
  sqlBuffer.writeln('  1,');
  sqlBuffer.writeln('  true,');
  sqlBuffer.writeln('  data.difficulty_level,');
  sqlBuffer.writeln('  data.image_url,');
  sqlBuffer.writeln('  NOW(),');
  sqlBuffer.writeln('  NOW()');
  sqlBuffer.writeln('FROM (');
  sqlBuffer.writeln('  VALUES');

  // Add each question
  for (var i = 0; i < questions.length; i++) {
    final question = questions[i];
    final optionsList = question['options'] as List<String>;
    final optionsJson = optionsList.map((opt) => '{"text": "$opt"}').join(',');
    
    sqlBuffer.write('    (\'${question['category']}\', 1, \'${question['question']}\', ');
    sqlBuffer.write('\'[$optionsJson]\'::jsonb, ');
    sqlBuffer.write('${question['correct']}, ');
    sqlBuffer.write('\'${question['explanation']}\', ');
    sqlBuffer.write('${question['difficulty']}, ');
    sqlBuffer.write('\'assets/individual_signs/${question['image']}\')');
    
    if (i < questions.length - 1) {
      sqlBuffer.writeln(',');
    } else {
      sqlBuffer.writeln();
    }
  }

  sqlBuffer.writeln(') AS data(category, learner_code, question_text, options, correct_index, explanation, difficulty_level, image_url);');
  sqlBuffer.writeln('');
  sqlBuffer.writeln('-- Verify the insertions');
  sqlBuffer.writeln('SELECT \'Successfully inserted \' || COUNT(*) || \' road sign questions\' AS result FROM questions WHERE category IN (\'regulatory\', \'prohibition\', \'command\', \'warning\', \'freeway\', \'informational\', \'mass_dimension\') AND created_at > NOW() - INTERVAL \'1 minute\';');

  // Write to file
  final outputFile = File('scripts/road_sign_questions_output.sql');
  outputFile.writeAsStringSync(sqlBuffer.toString());
  
  print('✅ Generated SQL file with ${questions.length} road sign questions');
  print('📁 Output file: scripts/road_sign_questions_output.sql');
  print('');
  print('Categories created:');
  categories.forEach((key, value) {
    final count = questions.where((q) => q['category'] == key).length;
    if (count > 0) {
      print('  - $value: $count questions');
    }
  });
}