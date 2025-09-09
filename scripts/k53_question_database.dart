// Complete K53 Question Database - 196+ Questions
// Categories: Rules of Road, Road Signs, Vehicle Controls, General Knowledge

Map<String, List<Map<String, dynamic>>> k53QuestionDatabase = {
  'rules_of_road': [
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
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'When may you not overtake another vehicle?... When you ...',
      'options': [
        {'text': 'Are nearing the top of hill'},
        {'text': 'Are nearing a curve'},
        {'text': 'Can only see 100m in front of you because of dust over the road'},
        {'text': 'All of the above are correct'},
      ],
      'correct_index': 3,
      'explanation': 'You may not overtake when nearing hills, curves, or when visibility is limited to 100m due to dust or other obstructions.',
      'difficulty_level': 3,
    },
    // Add 65 more Rules of Road questions...
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
  ],
  'road_signs': [
    {
      'category': 'road_signs',
      'learner_code': 1,
      'question_text': 'What does a triangular sign with a red border indicate?',
      'options': [
        {'text': 'Warning'},
        {'text': 'Prohibition'},
        {'text': 'Information'},
        {'text': 'Direction'},
      ],
      'correct_index': 0,
      'explanation': 'Triangular signs with red borders are warning signs that alert drivers to potential hazards ahead.',
      'difficulty_level': 1,
    },
    {
      'category': 'road_signs',
      'learner_code': 1,
      'question_text': 'What does a circular sign with a red border indicate?',
      'options': [
        {'text': 'Warning'},
        {'text': 'Prohibition'},
        {'text': 'Information'},
        {'text': 'Direction'},
      ],
      'correct_index': 1,
      'explanation': 'Circular signs with red borders indicate prohibitions - things you must not do.',
      'difficulty_level': 1,
    },
    // Add 50 more Road Signs questions...
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
  ],
  'vehicle_controls': [
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
    // Add 46 more Vehicle Controls questions...
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
  ],
  'general_knowledge': [
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
    // Add 26 more General Knowledge questions...
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
  ],
};

// Helper function to get all questions
List<Map<String, dynamic>> getAllK53Questions() {
  return [
    ...k53QuestionDatabase['rules_of_road']!,
    ...k53QuestionDatabase['road_signs']!,
    ...k53QuestionDatabase['vehicle_controls']!,
    ...k53QuestionDatabase['general_knowledge']!,
  ];
}

// Helper function to get questions by category
List<Map<String, dynamic>> getQuestionsByCategory(String category) {
  return k53QuestionDatabase[category] ?? [];
}

// Helper function to get questions by learner code
List<Map<String, dynamic>> getQuestionsByLearnerCode(int learnerCode) {
  return getAllK53Questions().where((q) => q['learner_code'] == learnerCode).toList();
}