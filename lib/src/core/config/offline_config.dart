class OfflineConfig {
  // App runs completely offline - no external API dependencies
  static const bool enableOfflineMode = true;
  static const bool enableLocalAuthentication = true;
  static const bool preloadAllQuestions = true;
  static const bool enableLocalGamification = true;
  
  // Local database configuration
  static const String localDatabaseName = 'k53_offline_db';
  static const int localDatabaseVersion = 1;
  
  // Feature flags for offline functionality
  static const bool enableStudyMode = true;
  static const bool enableMockExams = true;
  static const bool enableProgressTracking = true;
  static const bool enableAchievements = true;
  
  // Default user for offline mode
  static const String defaultOfflineUserId = 'offline_user';
  static const String defaultOfflineUsername = 'K53 Learner';
  
  // Validation
  static void validate() {
    // No external dependencies to validate
    print('✅ Offline configuration validated - app will work completely offline');
  }
  
  static void printConfig() {
    print('=== Offline Configuration ===');
    print('Offline Mode: $enableOfflineMode');
    print('Local Authentication: $enableLocalAuthentication');
    print('Preloaded Questions: $preloadAllQuestions');
    print('Local Gamification: $enableLocalGamification');
    print('Study Mode: $enableStudyMode');
    print('Mock Exams: $enableMockExams');
    print('Progress Tracking: $enableProgressTracking');
    print('Achievements: $enableAchievements');
    print('=============================');
  }
}