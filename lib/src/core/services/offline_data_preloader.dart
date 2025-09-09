import './offline_database_service.dart';
import '../models/question.dart';

class OfflineDataPreloader {
  static Future<void> preloadQuestions() async {
    try {
      // Check if we already have questions in the local database
      final localStats = await OfflineDatabaseService.getLocalStats();
      if ((localStats['questions'] ?? 0) > 0) {
        print('Questions already preloaded in local database');
        return;
      }

      print('Preloading questions into local database...');

      // Create a basic set of questions for offline use
      final List<Question> questions = [
        // Rules of Road - Basic questions
        Question(
          id: 'offline-1',
          category: 'rules_of_road',
          learnerCode: 1,
          questionText: 'You may reverse your vehicle...',
          options: [
            QuestionOption(text: 'Only when it is safe to do so'),
            QuestionOption(text: 'Anywhere you want'),
            QuestionOption(text: 'Without looking behind you'),
          ],
          correctIndex: 0,
          explanation: 'You may only reverse your vehicle when it is safe to do so and after checking your surroundings.',
          version: 1,
          isActive: true,
          difficultyLevel: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Question(
          id: 'offline-2',
          category: 'rules_of_road',
          learnerCode: 1,
          questionText: 'When changing lanes, you must...',
          options: [
            QuestionOption(text: 'Use your indicators'),
            QuestionOption(text: 'Check your mirrors'),
            QuestionOption(text: 'Do it only when safe'),
            QuestionOption(text: 'All of the above'),
          ],
          correctIndex: 3,
          explanation: 'All options are correct: use indicators, check mirrors, and change lanes only when safe.',
          version: 1,
          isActive: true,
          difficultyLevel: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),

        // Road Signs - Basic questions
        Question(
          id: 'offline-3',
          category: 'road_signs',
          learnerCode: 1,
          questionText: 'A triangular sign with red border indicates...',
          options: [
            QuestionOption(text: 'Warning'),
            QuestionOption(text: 'Prohibition'),
            QuestionOption(text: 'Information'),
          ],
          correctIndex: 0,
          explanation: 'Triangular signs with red borders are warning signs alerting to potential hazards.',
          version: 1,
          isActive: true,
          difficultyLevel: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),

        // Vehicle Controls - Basic questions
        Question(
          id: 'offline-4',
          category: 'vehicle_controls',
          learnerCode: 1,
          questionText: 'To increase speed on a motorcycle, you use the...',
          options: [
            QuestionOption(text: 'Throttle'),
            QuestionOption(text: 'Brake'),
            QuestionOption(text: 'Clutch'),
          ],
          correctIndex: 0,
          explanation: 'The throttle control is used to increase speed on a motorcycle.',
          version: 1,
          isActive: true,
          difficultyLevel: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),

        // General Knowledge - Basic questions
        Question(
          id: 'offline-5',
          category: 'general_knowledge',
          learnerCode: 1,
          questionText: 'The legal blood alcohol limit for drivers is...',
          options: [
            QuestionOption(text: '0.05%'),
            QuestionOption(text: '0.08%'),
            QuestionOption(text: '0.10%'),
          ],
          correctIndex: 0,
          explanation: 'The legal blood alcohol limit for drivers in South Africa is 0.05%.',
          version: 1,
          isActive: true,
          difficultyLevel: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Cache the questions in the local database
      await OfflineDatabaseService.cacheQuestions(questions);
      
      print('Preloaded ${questions.length} basic questions into local database');
    } catch (e) {
      print('Error preloading questions: $e');
      // This is not critical - the app will still work and cache questions as they're loaded
    }
  }

  // Method to check if we need to preload data
  static Future<bool> needsPreloading() async {
    final localStats = await OfflineDatabaseService.getLocalStats();
    return (localStats['questions'] ?? 0) == 0;
  }
}