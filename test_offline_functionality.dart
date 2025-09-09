// Test script to verify offline functionality
// This simulates what happens when the app starts offline

import 'package:k53app/src/core/services/offline_database_service.dart';
import 'package:k53app/src/core/services/offline_data_preloader.dart';

void main() async {
  print('Testing offline functionality...');
  
  // Initialize the offline database
  await OfflineDatabaseService.initialize();
  print('✓ Offline database initialized');
  
  // Preload basic questions
  await OfflineDataPreloader.preloadQuestions();
  print('✓ Basic questions preloaded');
  
  // Test getting questions while offline
  final questions = await OfflineDatabaseService.getRandomQuestions(count: 5);
  print('✓ Retrieved ${questions.length} questions from offline database');
  
  if (questions.isNotEmpty) {
    print('✓ SUCCESS: Offline mode is working!');
    print('Sample question: ${questions.first.questionText}');
  } else {
    print('✗ FAILED: No questions available offline');
  }
  
  // Test connectivity check
  final isConnected = await OfflineDatabaseService.isConnected();
  print('Connectivity status: ${isConnected ? "Online" : "Offline"}');
  
  print('\nOffline functionality test completed.');
}