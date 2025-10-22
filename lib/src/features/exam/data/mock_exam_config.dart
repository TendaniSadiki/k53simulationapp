class MockExamConfig {
  final String id;
  final String title;
  final String? category;
  final int? learnerCode;
  final int questionCount;
  final int timeLimitMinutes;
  final String description;
  final int difficulty;

  const MockExamConfig({
    required this.id,
    required this.title,
    this.category,
    this.learnerCode,
    required this.questionCount,
    required this.timeLimitMinutes,
    required this.description,
    this.difficulty = 1,
  });

  // Standard K53 mock exams
  static const standardExam = MockExamConfig(
    id: 'standard_k53',
    title: 'Standard K53 Exam',
    category: null,
    learnerCode: null,
    questionCount: 30,
    timeLimitMinutes: 45,
    description: 'Full K53 learner\'s license exam simulation',
    difficulty: 2,
  );

  // Rules of the Road exams
  static const rulesBasic = MockExamConfig(
    id: 'rules_basic',
    title: 'Rules of the Road - Basic',
    category: 'rules_of_road',
    learnerCode: null,
    questionCount: 15,
    timeLimitMinutes: 20,
    description: 'Basic rules of the road questions',
    difficulty: 1,
  );

  static const rulesAdvanced = MockExamConfig(
    id: 'rules_advanced',
    title: 'Rules of the Road - Advanced',
    category: 'rules_of_road',
    learnerCode: null,
    questionCount: 20,
    timeLimitMinutes: 30,
    description: 'Advanced rules of the road questions',
    difficulty: 3,
  );

  // Road Signs exams
  static const signsBasic = MockExamConfig(
    id: 'signs_basic',
    title: 'Road Signs - Basic',
    category: 'road_signs',
    learnerCode: null,
    questionCount: 15,
    timeLimitMinutes: 20,
    description: 'Basic road sign identification',
    difficulty: 1,
  );

  static const signsAdvanced = MockExamConfig(
    id: 'signs_advanced',
    title: 'Road Signs - Advanced',
    category: 'road_signs',
    learnerCode: null,
    questionCount: 20,
    timeLimitMinutes: 30,
    description: 'Advanced road sign identification',
    difficulty: 3,
  );

  // Vehicle Controls exams by code
  static const controlsCode1 = MockExamConfig(
    id: 'controls_code1',
    title: 'Vehicle Controls - Code 1',
    category: 'vehicle_controls',
    learnerCode: 1,
    questionCount: 10,
    timeLimitMinutes: 15,
    description: 'Motorcycle controls and operations',
    difficulty: 2,
  );

  static const controlsCode2 = MockExamConfig(
    id: 'controls_code2',
    title: 'Vehicle Controls - Code 2',
    category: 'vehicle_controls',
    learnerCode: 2,
    questionCount: 10,
    timeLimitMinutes: 15,
    description: 'Light vehicle controls and operations',
    difficulty: 2,
  );

  static const controlsCode3 = MockExamConfig(
    id: 'controls_code3',
    title: 'Vehicle Controls - Code 3',
    category: 'vehicle_controls',
    learnerCode: 3,
    questionCount: 10,
    timeLimitMinutes: 15,
    description: 'Heavy vehicle controls and operations',
    difficulty: 2,
  );

  // Quick practice exams
  static const quickPractice = MockExamConfig(
    id: 'quick_practice',
    title: 'Quick Practice',
    category: null,
    learnerCode: null,
    questionCount: 10,
    timeLimitMinutes: 15,
    description: 'Quick 10-question practice session',
    difficulty: 1,
  );

  static const comprehensiveReview = MockExamConfig(
    id: 'comprehensive_review',
    title: 'Comprehensive Review',
    category: null,
    learnerCode: null,
    questionCount: 50,
    timeLimitMinutes: 75,
    description: 'Comprehensive review of all categories',
    difficulty: 3,
  );

  // Get all available mock exam configurations
  static List<MockExamConfig> get allConfigs => [
        standardExam,
        rulesBasic,
        rulesAdvanced,
        signsBasic,
        signsAdvanced,
        controlsCode1,
        controlsCode2,
        controlsCode3,
        quickPractice,
        comprehensiveReview,
      ];

  // Get exams by category
  static List<MockExamConfig> getByCategory(String? category) {
    if (category == null) {
      return allConfigs.where((config) => config.category == null).toList();
    }
    return allConfigs.where((config) => config.category == category).toList();
  }

  // Get exams by learner code
  static List<MockExamConfig> getByLearnerCode(int? learnerCode) {
    if (learnerCode == null) {
      return allConfigs.where((config) => config.learnerCode == null).toList();
    }
    return allConfigs.where((config) => config.learnerCode == learnerCode).toList();
  }

  @override
  String toString() {
    return 'MockExamConfig{id: $id, title: $title, category: $category, learnerCode: $learnerCode, questionCount: $questionCount, timeLimitMinutes: $timeLimitMinutes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockExamConfig &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}