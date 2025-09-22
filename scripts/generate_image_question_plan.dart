import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  print('=== GENERATING QUESTION PLAN FOR ALL DESCRIPTIVE IMAGES ===\n');

  // Check assets directory structure
  final assetsDir = Directory('assets/individual_signs');
  if (!assetsDir.existsSync()) {
    print('❌ Assets directory does not exist: assets/individual_signs/');
    return;
  }

  // Get all image files recursively, excluding sign_page_ files
  final imageFiles = assetsDir.listSync(recursive: true)
      .whereType<File>()
      .where((file) => !p.basename(file.path).contains('sign_page_'))
      .toList();

  print('✅ Found ${imageFiles.length} descriptive image files (excluding sign_page_)');

  // Get current questions from the database to see what's already covered
  final currentQuestions = _getCurrentQuestionImageUrls();
  print('📊 Current database has ${currentQuestions.length} questions with images');

  // Categorize images by subdirectory
  final categorizedImages = <String, List<String>>{};
  for (final file in imageFiles) {
    final relativePath = p.relative(file.path, from: 'assets/individual_signs');
    final directory = p.dirname(relativePath);
    
    if (directory == '.') {
      // Root level files
      if (!categorizedImages.containsKey('ROOT')) {
        categorizedImages['ROOT'] = [];
      }
      categorizedImages['ROOT']!.add(p.basename(file.path));
    } else {
      // Subdirectory files
      if (!categorizedImages.containsKey(directory)) {
        categorizedImages[directory] = [];
      }
      categorizedImages[directory]!.add('$directory/${p.basename(file.path)}');
    }
  }

  // Analyze coverage and generate plan
  print('\n=== IMAGE COVERAGE ANALYSIS ===');
  
  int totalImagesNeedingQuestions = 0;
  final coveragePlan = <String, Map<String, dynamic>>{};

  categorizedImages.forEach((category, images) {
    final imagesInCategory = images.length;
    int coveredImages = 0;
    final uncoveredImages = <String>[];

    for (final image in images) {
      final imagePath = 'assets/individual_signs/$image';
      if (currentQuestions.contains(imagePath)) {
        coveredImages++;
      } else {
        uncoveredImages.add(image);
      }
    }

    final coveragePercentage = (coveredImages / imagesInCategory * 100).toStringAsFixed(1);
    
    coveragePlan[category] = {
      'total': imagesInCategory,
      'covered': coveredImages,
      'uncovered': uncoveredImages.length,
      'coverage': coveragePercentage,
      'uncovered_list': uncoveredImages,
    };

    totalImagesNeedingQuestions += uncoveredImages.length;

    print('$category: $coveredImages/$imagesInCategory covered ($coveragePercentage%)');
  });

  print('\n=== ACTION PLAN ===');
  print('Total images needing questions: $totalImagesNeedingQuestions');
  print('Estimated questions to create: ~${(totalImagesNeedingQuestions * 1.2).round()}');
  print('(Assuming some images might need multiple question variations)');

  print('\n=== PRIORITY CATEGORIES ===');
  
  // Sort by coverage percentage (lowest coverage first)
  final sortedCategories = coveragePlan.entries.toList()
    ..sort((a, b) => double.parse(a.value['coverage']).compareTo(double.parse(b.value['coverage'])));

  for (final entry in sortedCategories.take(10)) {
    final category = entry.key;
    final data = entry.value;
    if (data['uncovered'] > 0) {
      print('${category.padRight(30)}: ${data['uncovered']} images need questions (${data['coverage']}% covered)');
    }
  }

  print('\n=== SAMPLE QUESTION TEMPLATES ===');
  print('For road signs:');
  print('  "What does this sign indicate?"');
  print('  "What action should you take when you see this sign?"');
  print('  "What is the meaning of this road sign?"');
  
  print('\nFor vehicle controls:');
  print('  "What control is shown by number X?"');
  print('  "To perform [action], you must use number..."');
  print('  "Which control is used for [specific function]?"');

  print('\n=== NEXT STEPS ===');
  print('1. Fix existing image URL paths in the question database');
  print('2. Create questions for uncovered images in priority categories');
  print('3. Use descriptive file names to generate appropriate questions');
  print('4. Test image loading in the app interface');
  print('5. Add validation to ensure all images have corresponding questions');

  // Generate a sample output file with uncovered images
  _generateUncoveredImagesFile(coveragePlan);
}

Set<String> _getCurrentQuestionImageUrls() {
  // This would normally read from the actual database, but for now we'll simulate
  // based on the patterns we saw in the k53_question_database.dart file
  final currentUrls = <String>{};
  
  // Add the URLs that are currently referenced with correct subdirectory paths
  currentUrls.add('assets/individual_signs/CODE 1/code1.png');
  currentUrls.add('assets/individual_signs/CODE 2/code2.png');
  currentUrls.add('assets/individual_signs/CODE 3/code3.png');
  currentUrls.add('assets/individual_signs/CONTROL SIGNS/Stop in line with the Stop sign or before the line.png');
  currentUrls.add('assets/individual_signs/CONTROL SIGNS/Stop in line with the Stop sign or befor_1.png');
  currentUrls.add('assets/individual_signs/RESERVATION SIGNS/This area is reserved for parking.png');
  currentUrls.add('assets/individual_signs/RESERVATION SIGNS/This area is reserved for parking by authorized vehicles.png');
  currentUrls.add('assets/individual_signs/RESERVATION SIGNS/This area is reserved for parking by police vehicles.png');
  currentUrls.add('assets/individual_signs/RESERVATION SIGNS/This area is reserved for parking by the class of vehicle shown.png');
  currentUrls.add('assets/individual_signs/RESERVATION SIGNS/This area is reserved for parking, up to a maximum of 60 minutes.png');
  currentUrls.add('assets/individual_signs/RESERVATION SIGNS/This area is temporarily reserved for parking by the class of vehicle shown.png');
  currentUrls.add('assets/individual_signs/PROHIBITION SIGNS/To prohibit vehicles from turning around (u-turn) so that it faces the opposite direction.png');
  currentUrls.add('assets/individual_signs/PROHIBITION SIGNS/To prohibit vehicles from turning left at an intersection.png');
  currentUrls.add('assets/individual_signs/PROHIBITION SIGNS/To prohibit vehicles from turning left.png');
  currentUrls.add('assets/individual_signs/PROHIBITION SIGNS/To prohibit vehicles from turning right at an intersection.png');
  currentUrls.add('assets/individual_signs/PROHIBITION SIGNS/To prohibit vehicles from turning right.png');
  currentUrls.add('assets/individual_signs/PROHIBITION SIGNS/To prohibit drivers from parking during any time of the day or night.png');
  currentUrls.add('assets/individual_signs/PROHIBITION SIGNS/To prohibit hawkers in this area during any time of the day or night.png');
  currentUrls.add('assets/individual_signs/PROHIBITION SIGNS/To prohibit motorcycles on a part of a carriageway for safety reasons.png');
  currentUrls.add('assets/individual_signs/PROHIBITION SIGNS/To prohibit noise, if the noise level of your vehi.png');
  currentUrls.add('assets/individual_signs/PROHIBITION SIGNS/To prohibit pedestrians and stationary vehicles. A.png');
  currentUrls.add('assets/individual_signs/PROHIBITION SIGNS/To prohibit pedestrians from proceeding past this .png');
  currentUrls.add('assets/individual_signs/COMMAND SIGNS/To regulate minimum speed of traffic. Do not drive.png');
  currentUrls.add('assets/individual_signs/CHANGES IN VEHICLE MOVEMENT AHEAD/Traffic circle ahead (mini circle or round about).png');
  currentUrls.add('assets/individual_signs/COMMAND SIGNS/To indicate that you must move in a clockwise direction at the junction.png');
  currentUrls.add('assets/individual_signs/COMMAND SIGNS/To indicate that you must switch on your headlight.png');
  currentUrls.add('assets/individual_signs/COMPREHENSIVE SIGNS/Residential area.png');
  currentUrls.add('assets/individual_signs/COMPREHENSIVE SIGNS/Dual-carriage freeway begins The following rules apply to all freeways.png');
  currentUrls.add('assets/individual_signs/DE-RESTRICTION SIGNS/End of dual carriage freeway and freeway rules no longer apply.png');
  currentUrls.add('assets/individual_signs/DE-RESTRICTION SIGNS/You no longer need to drive with your headlights switched on.png');
  currentUrls.add('assets/individual_signs/INFORMATION SIGNS/Information centre where you can obtain information about the local area.png');
  currentUrls.add('assets/individual_signs/INFORMATION SIGNS/Park and ride point. You can park your car here and take a train for the n leg of your journey..png');
  currentUrls.add('assets/individual_signs/MOVING HAZARDS AHEAD/Children ahead..png');
  currentUrls.add('assets/individual_signs/MOVING HAZARDS AHEAD/Road works ahead..png');
  currentUrls.add('assets/individual_signs/LIMIT PROHIBITION SIGNS/Maximum speed limit allowed.png');
  currentUrls.add('assets/individual_signs/DIRECTION SIGN SYMBOLS/Airport..png');
  currentUrls.add('assets/individual_signs/ROAD LAYOUT CHANGES AHEAD/Crossroad ahead.png');
  currentUrls.add('assets/individual_signs/ROAD SITUATIONS AHEAD/Railway crossing ahead. Obey any traffic control signals at the crossing..png');
  currentUrls.add('assets/individual_signs/TRAFFIC SIGNALS/Stop hand signal for traffic approaching from behind the officer.png');
  currentUrls.add('assets/individual_signs/SELECTIVE RESTRICTION SIGNS/Applies on the days and during the times shown.png');

  return currentUrls;
}

void _generateUncoveredImagesFile(Map<String, Map<String, dynamic>> coveragePlan) {
  final output = StringBuffer();
  output.writeln('# Uncovered Images Needing Questions');
  output.writeln('Generated: ${DateTime.now()}');
  output.writeln('');

  coveragePlan.forEach((category, data) {
    if (data['uncovered'] > 0) {
      output.writeln('## $category');
      output.writeln('Uncovered: ${data['uncovered']}/${data['total']} images');
      output.writeln('');
      
      for (final image in data['uncovered_list']) {
        output.writeln('- assets/individual_signs/$image');
      }
      output.writeln('');
    }
  });

  File('uncovered_images_plan.md').writeAsStringSync(output.toString());
  print('📝 Generated uncovered_images_plan.md with detailed list of images needing questions');
}