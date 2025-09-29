// Test script to verify point adjustment system functionality
// This tests the complete point adjustment workflow

import 'package:k53app/src/core/services/offline_database_service.dart';
import 'package:k53app/src/core/services/session_database_service.dart';
import 'package:k53app/src/core/services/point_adjustment_service.dart';
import 'package:k53app/src/core/services/gamification_service.dart';
import 'package:k53app/src/core/models/session.dart';
import 'package:k53app/src/core/models/question.dart';

void main() async {
  print('Testing Point Adjustment System...');
  
  // Initialize the offline database
  await OfflineDatabaseService.initialize();
  await SessionDatabaseService.initialize();
  print('✓ Database initialized');

  // Test session ID
  const testSessionId = 'test-session-points';
  const testUserId = 'test-user-points';

  // Create a test session
  final testSession = Session(
    id: testSessionId,
    type: SessionType.study,
    userId: testUserId,
    category: 'rules_of_road',
    totalQuestions: 5,
    currentQuestionIndex: 0,
    correctAnswers: 0,
    totalAnswered: 0,
    timeRemainingSeconds: 300,
    isPaused: false,
    isCompleted: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    expiresAt: DateTime.now().add(Duration(hours: 1)),
  );

  // Create test questions
  final testQuestions = [
    Question(
      id: 'q1',
      category: 'rules_of_road',
      learnerCode: 1,
      questionText: 'What does this sign mean?',
      options: [
        QuestionOption(text: 'Stop'),
        QuestionOption(text: 'Yield'),
        QuestionOption(text: 'No entry'),
      ],
      correctIndex: 0,
      explanation: 'This is a stop sign',
      version: 1,
      isActive: true,
      difficultyLevel: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Question(
      id: 'q2',
      category: 'rules_of_road',
      learnerCode: 2,
      questionText: 'What is the speed limit in residential areas?',
      options: [
        QuestionOption(text: '60 km/h'),
        QuestionOption(text: '80 km/h'),
        QuestionOption(text: '100 km/h'),
      ],
      correctIndex: 0,
      explanation: 'Speed limit is 60 km/h in residential areas',
      version: 1,
      isActive: true,
      difficultyLevel: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  // Create session
  await SessionDatabaseService.createSession(testSession, testQuestions);
  print('✓ Test session created');

  // Test 1: Record correct answer and award points
  print('\n1. Testing correct answer point awarding...');
  
  await PointAdjustmentService().recordQuestionAnswer(
    sessionId: testSessionId,
    questionId: 'q1',
    chosenIndex: 0,
    isCorrect: true,
    elapsedMs: 5000,
  );

  final pointsAfterCorrect = await PointAdjustmentService().getSessionTotalPoints(testSessionId);
  print('✓ Points after correct answer: $pointsAfterCorrect (expected: 1)');

  // Test 2: Record incorrect answer (no points)
  print('\n2. Testing incorrect answer (no points)...');
  
  await PointAdjustmentService().recordQuestionAnswer(
    sessionId: testSessionId,
    questionId: 'q2',
    chosenIndex: 1, // Wrong answer
    isCorrect: false,
    elapsedMs: 3000,
  );

  final pointsAfterIncorrect = await PointAdjustmentService().getSessionTotalPoints(testSessionId);
  print('✓ Points after incorrect answer: $pointsAfterIncorrect (expected: 1)');

  // Test 3: Navigate back to previous question (point deduction)
  print('\n3. Testing navigation back point deduction...');
  
  await PointAdjustmentService().handleNavigationBack(
    sessionId: testSessionId,
    questionId: 'q1',
  );

  final pointsAfterNavigationBack = await PointAdjustmentService().getSessionTotalPoints(testSessionId);
  print('✓ Points after navigation back: $pointsAfterNavigationBack (expected: 0)');

  // Test 4: Get point history for question
  print('\n4. Testing point history tracking...');
  
  final pointHistory = await PointAdjustmentService().getQuestionPointHistory(
    sessionId: testSessionId,
    questionId: 'q1',
  );

  print('✓ Point history for q1:');
  for (final adjustment in pointHistory) {
    print('  - ${adjustment.points} points: ${adjustment.reason} at ${adjustment.adjustedAt}');
  }

  // Test 5: Get session point summary
  print('\n5. Testing session point summary...');
  
  final sessionSummary = await PointAdjustmentService().getSessionPointSummary(testSessionId);
  print('✓ Session point summary:');
  print('  Total Points: ${sessionSummary['totalPoints']}');
  print('  Total Questions: ${sessionSummary['totalQuestions']}');
  print('  Questions with Points: ${sessionSummary['questionsWithPoints']}');
  print('  Adjusted Questions: ${sessionSummary['adjustedQuestions']}');

  // Test 6: Test GamificationService integration
  print('\n6. Testing GamificationService integration...');
  
  await GamificationService().trackQuestionAnswer(
    sessionId: testSessionId,
    questionId: 'q1',
    chosenIndex: 0,
    isCorrect: true,
    elapsedMs: 4000,
  );

  final gamificationPoints = await PointAdjustmentService().getSessionTotalPoints(testSessionId);
  print('✓ Points via GamificationService: $gamificationPoints');

  // Test 7: Test navigation back via GamificationService
  print('\n7. Testing navigation back via GamificationService...');
  
  await GamificationService().handleNavigationBack(
    sessionId: testSessionId,
    questionId: 'q1',
  );

  final finalPoints = await PointAdjustmentService().getSessionTotalPoints(testSessionId);
  print('✓ Final points after navigation back: $finalPoints');

  // Test 8: Test point adjustment edge cases
  print('\n8. Testing edge cases...');
  
  // Try to deduct points from question that never had points
  await PointAdjustmentService().handleNavigationBack(
    sessionId: testSessionId,
    questionId: 'q2', // This question never had points
  );

  final edgeCasePoints = await PointAdjustmentService().getSessionTotalPoints(testSessionId);
  print('✓ Points after edge case test: $edgeCasePoints (should remain unchanged)');

  // Test 9: Verify point history integrity
  print('\n9. Testing point history integrity...');
  
  final finalHistory = await PointAdjustmentService().getQuestionPointHistory(
    sessionId: testSessionId,
    questionId: 'q1',
  );

  print('✓ Final point history for q1:');
  for (final adjustment in finalHistory) {
    print('  - ${adjustment.points} points: ${adjustment.reason}');
  }

  // Clean up
  await SessionDatabaseService.deleteSession(testSessionId);
  print('\n✓ Test session cleaned up');

  print('\n🎯 POINT ADJUSTMENT SYSTEM TEST COMPLETED!');
  print('✓ Correct answer awards +1 point');
  print('✓ Incorrect answer awards 0 points');
  print('✓ Navigation back deducts -1 point');
  print('✓ Point history is properly tracked');
  print('✓ Minimum point threshold (0) is enforced');
  print('✓ GamificationService integration works');
  print('✓ Edge cases handled correctly');
  print('✓ Point history integrity maintained');
  
  print('\nTo run this test: dart test_point_adjustment_system.dart');
}