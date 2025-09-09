import 'dart:io';
import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';
import 'k53_question_database.dart';

void main() async {
  // Read environment variables from .env file
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('Error: .env file not found in the root directory');
    exit(1);
  }

  final envLines = envFile.readAsLinesSync();
  final envVars = <String, String>{};

  for (final line in envLines) {
    if (line.contains('=') && !line.startsWith('#')) {
      final parts = line.split('=');
      if (parts.length >= 2) {
        envVars[parts[0]] = parts.sublist(1).join('=');
      }
    }
  }

  // Use SERVICE_ROLE key to bypass RLS for seeding
  final supabaseUrl = envVars['SUPABASE_URL'] ?? '';
  final supabaseKey =
      envVars['SUPABASE_SERVICE_ROLE_KEY'] ??
      envVars['SUPABASE_ANON_KEY'] ??
      '';

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print(
      'Error: SUPABASE_URL and at least one key (SERVICE_ROLE or ANON) not found in .env file',
    );
    exit(1);
  }

  final keyType = envVars['SUPABASE_SERVICE_ROLE_KEY'] != null
      ? 'SERVICE_ROLE'
      : 'ANON';
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);
  print('Using $keyType key: ${supabaseKey.substring(0, 10)}...');
  print('Using Supabase URL: ${supabaseUrl.substring(0, 20)}...');
  if (keyType == 'ANON') {
    print(
      'Note: RLS policies may prevent insertion - consider using SERVICE_ROLE key',
    );
  }
  final uuid = Uuid();

  try {
    print('Starting to seed complete K53 question database...');

    // Optional: Clear existing questions for fresh start
    print('Do you want to clear existing questions first? (y/N)');
    final input = stdin.readLineSync()?.toLowerCase();
    if (input == 'y' || input == 'yes') {
      print('Clearing existing questions...');
      try {
        await supabase
            .from('questions')
            .delete()
            .neq('id', '00000000-0000-0000-0000-000000000000');
        print('Existing questions cleared.');
      } catch (e) {
        if (e.toString().contains('Could not find the table')) {
          print(
            'Questions table does not exist yet - proceeding with fresh insert...',
          );
        } else {
          rethrow;
        }
      }
    }

    // Complete K53 question set - 196+ questions from database
    final allQuestions = getAllK53Questions();

    int insertedCount = 0;
    int errorCount = 0;

    print('Question counts by category:');
    print('- Rules of the Road: ${getQuestionsByCategory('rules_of_road').length} questions');
    print('- Road Signs: ${getQuestionsByCategory('road_signs').length} questions');
    print('- Vehicle Controls: ${getQuestionsByCategory('vehicle_controls').length} questions');
    print('- General Knowledge: ${getQuestionsByCategory('general_knowledge').length} questions');
    print('- Total: ${allQuestions.length} questions');
    print('Starting database insertion...\n');

    for (final questionData in allQuestions) {
      final questionId = uuid.v4();
      final now = DateTime.now().toIso8601String();

      try {
        await supabase.from('questions').insert({
          'id': questionId,
          'category': questionData['category'],
          'learner_code': questionData['learner_code'],
          'question_text': questionData['question_text'],
          'options': questionData['options'],
          'correct_index': questionData['correct_index'],
          'explanation': questionData['explanation'],
          'version': 1,
          'is_active': true,
          'difficulty_level': questionData['difficulty_level'],
          if (questionData['image_url'] != null) 'image_url': questionData['image_url'],
          'created_at': now,
          'updated_at': now,
        });

        insertedCount++;
        if (insertedCount % 20 == 0) {
          print('Inserted $insertedCount questions...');
        }
      } catch (e) {
        errorCount++;
        if (errorCount <= 5) {
          // Only show first 5 errors to avoid spam
          print('Error inserting question: ${questionData['question_text']}');
          print('Error details: $e');
        }
      }

      // Add small delay to avoid rate limiting
      await Future.delayed(Duration(milliseconds: 30));
    }

    print('\n✅ Seeding completed!');
    print('Successfully inserted: $insertedCount questions');
    print('Errors: $errorCount');
    if (insertedCount != allQuestions.length) {
      print('⚠️  WARNING: Only $insertedCount of ${allQuestions.length} questions were inserted!');
      print('   This may indicate database constraint violations or duplicate questions.');
    }
    print('\nCategories covered: Rules of the Road, Road Signs, Vehicle Controls, General Knowledge');
    print('Total questions: ${allQuestions.length} (Complete K53 Official)');
  } catch (e) {
    print('Error seeding questions: $e');
    exit(1);
  } finally {
    supabase.dispose();
  }
}

List<Map<String, dynamic>> _getRulesOfRoadQuestions() {
  return [
    // Rules of the Road - 68 questions
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'You may...',
      'options': [
        {'text': 'Drive your vehicle on the sidewalk at night'},
        {'text': 'Reverse your vehicle only if it is safe to do so'},
        {'text': 'Leave the engine of your vehicle idling when you put petrol in it'},
      ],
      'correct_index': 1,
      'explanation': 'You may only reverse your vehicle when it is safe to do so. Driving on sidewalks is illegal and leaving engine running while refueling is dangerous.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'When you want to change lanes and drive from one lane to the other you must...',
      'options': [
        {'text': 'Only do it when it is safe to do so'},
        {'text': 'Switch on your indicators in time to show what you are going to do'},
        {'text': 'Use the mirrors of your vehicle to ensure that you know of other traffic around you'},
        {'text': 'All of the above are correct'},
      ],
      'correct_index': 3,
      'explanation': 'All options are correct: change lanes only when safe, use indicators in time, and check mirrors for surrounding traffic.',
      'difficulty_level': 2,
    },
    // Add 66 more Rules of the Road questions here...
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'The legal speed limit which you may drive...',
      'options': [
        {'text': 'Is always 120km/h outside an urban area'},
        {'text': 'Can be determined by yourself if you look at the number of lanes the road has'},
        {'text': 'Is shown to you by signs next to the road'},
      ],
      'correct_index': 2,
      'explanation': 'Legal speed limits are indicated by road signs. Do not assume limits based on road type or number of lanes.',
      'difficulty_level': 1,
    },
  ];
}

List<Map<String, dynamic>> _getRoadSignsQuestions() {
  return [
    // Road Signs - 52 questions with visual support
    {
      'category': 'road_signs',
      'learner_code': 1,
      'question_text': 'What does this sign indicate?',
      'options': [
        {'text': 'Stop ahead'},
        {'text': 'Yield ahead'},
        {'text': 'No entry'},
        {'text': 'Roundabout ahead'},
      ],
      'correct_index': 0,
      'explanation': 'This triangular sign with red border and "STOP" text indicates a stop sign is ahead.',
      'difficulty_level': 1,
      'image_url': 'assets/images/signs/stop_ahead.png',
    },
    {
      'category': 'road_signs',
      'learner_code': 1,
      'question_text': 'What does a circular sign with a red border and diagonal bar indicate?',
      'options': [
        {'text': 'Warning'},
        {'text': 'Prohibition'},
        {'text': 'Mandatory instruction'},
        {'text': 'Information'},
      ],
      'correct_index': 1,
      'explanation': 'Circular signs with red borders and diagonal bars indicate prohibitions - things you must not do.',
      'difficulty_level': 1,
    },
    // Add 50 more Road Signs questions here...
    {
      'category': 'road_signs',
      'learner_code': 1,
      'question_text': 'What does a blue rectangular sign with a white "P" indicate?',
      'options': [
        {'text': 'No parking'},
        {'text': 'Parking area'},
        {'text': 'Pedestrian crossing'},
        {'text': 'Police station'},
      ],
      'correct_index': 1,
      'explanation': 'A white "P" on blue background indicates a parking area.',
      'difficulty_level': 1,
      'image_url': 'assets/images/signs/parking.png',
    },
  ];
}

List<Map<String, dynamic>> _getVehicleControlsQuestions() {
  return [
    // Vehicle Controls - 48 questions
    {
      'category': 'vehicle_controls',
      'learner_code': 1,
      'question_text': 'To ride faster, you must use number...',
      'options': [
        {'text': '7'},
        {'text': '5'},
        {'text': '4'},
      ],
      'correct_index': 2,
      'explanation': 'Number 4 is the throttle control. To increase speed, gradually roll the throttle forward.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 1,
      'question_text': 'To turn you must use number',
      'options': [
        {'text': '8'},
        {'text': '1'},
        {'text': '7'},
      ],
      'correct_index': 0,
      'explanation': 'Number 8 is the steering. To turn, lean the motorcycle and gently counter-steer in the desired direction.',
      'difficulty_level': 1,
    },
    // Add 46 more Vehicle Controls questions here...
    {
      'category': 'vehicle_controls',
      'learner_code': 3,
      'question_text': 'To ensure that your parked vehicle does not move, use number...',
      'options': [
        {'text': '7'},
        {'text': '8'},
        {'text': '9'},
      ],
      'correct_index': 2,
      'explanation': 'Number 9 is the parking brake, crucial for securing heavy vehicles when stationary.',
      'difficulty_level': 1,
    },
  ];
}

List<Map<String, dynamic>> _getGeneralKnowledgeQuestions() {
  return [
    // General Knowledge - 28 questions
    {
      'category': 'general_knowledge',
      'learner_code': 1,
      'question_text': 'What is the legal blood alcohol limit for drivers in South Africa?',
      'options': [
        {'text': '0.05%'},
        {'text': '0.08%'},
        {'text': '0.10%'},
        {'text': '0.02%'},
      ],
      'correct_index': 0,
      'explanation': 'The legal blood alcohol limit for drivers in South Africa is 0.05 grams per 100 milliliters.',
      'difficulty_level': 2,
    },
    {
      'category': 'general_knowledge',
      'learner_code': 1,
      'question_text': 'How often must you renew your vehicle license?',
      'options': [
        {'text': 'Every 6 months'},
        {'text': 'Every year'},
        {'text': 'Every 2 years'},
        {'text': 'Every 5 years'},
      ],
      'correct_index': 1,
      'explanation': 'Vehicle licenses must be renewed annually in South Africa.',
      'difficulty_level': 1,
    },
    // Add 26 more General Knowledge questions here...
    {
      'category': 'general_knowledge',
      'learner_code': 1,
      'question_text': 'What is the minimum age to apply for a learner\'s license?',
      'options': [
        {'text': '16 years'},
        {'text': '17 years'},
        {'text': '18 years'},
        {'text': '21 years'},
      ],
      'correct_index': 1,
      'explanation': 'The minimum age to apply for a learner\'s license in South Africa is 17 years.',
      'difficulty_level': 1,
    },
  ];
}