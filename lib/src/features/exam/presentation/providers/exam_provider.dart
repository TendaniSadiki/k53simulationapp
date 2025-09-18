import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/question.dart';
import '../../../../core/models/session.dart' as session_models;
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/offline_database_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/exam_timer_service.dart';
import '../../../../core/services/session_persistence_service.dart';
import '../../../../core/services/session_database_service.dart';
import '../../../../core/services/session_migration_service.dart';
import '../../../../core/services/session_recovery_service.dart';
import '../../../../core/services/gamification_service.dart';
import '../../../gamification/presentation/providers/gamification_provider.dart';
import '../../data/mock_exam_config.dart';

class ExamState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final bool isLoading;
  final String? error;
  final int? selectedAnswerIndex;
  final bool showExplanation;
  final String? sessionId;
  final int correctAnswers;
  final int totalAnswered;
  final int timeRemainingSeconds;
  final bool isPaused;
  final bool isCompleted;
  final Map<String, int> questionStartTimes; // Track when each question was shown
  final MockExamConfig? mockExamConfig; // Track if this is a mock exam and which config
  final Map<String, int> userAnswers; // Track user answers for review (questionId -> selectedIndex)

  ExamState({
    required this.questions,
    required this.currentQuestionIndex,
    required this.isLoading,
    this.error,
    this.selectedAnswerIndex,
    required this.showExplanation,
    this.sessionId,
    required this.correctAnswers,
    required this.totalAnswered,
    required this.timeRemainingSeconds,
    required this.isPaused,
    required this.isCompleted,
    required this.questionStartTimes,
    this.mockExamConfig,
    Map<String, int>? userAnswers,
  }) : userAnswers = userAnswers ?? {};

  ExamState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    bool? isLoading,
    String? error,
    int? selectedAnswerIndex,
    bool? showExplanation,
    String? sessionId,
    int? correctAnswers,
    int? totalAnswered,
    int? timeRemainingSeconds,
    bool? isPaused,
    bool? isCompleted,
    Map<String, int>? questionStartTimes,
    MockExamConfig? mockExamConfig,
    Map<String, int>? userAnswers,
  }) {
    return ExamState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAnswerIndex: selectedAnswerIndex,
      showExplanation: showExplanation ?? this.showExplanation,
      sessionId: sessionId ?? this.sessionId,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      questionStartTimes: questionStartTimes ?? this.questionStartTimes,
      mockExamConfig: mockExamConfig ?? this.mockExamConfig,
      userAnswers: userAnswers ?? this.userAnswers,
    );
  }

  Question? get currentQuestion {
    if (currentQuestionIndex >= 0 && currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  bool get isFirstQuestion => currentQuestionIndex == 0;
  double get progress => questions.isEmpty ? 0 : (currentQuestionIndex + 1) / questions.length;
  double get accuracy => totalAnswered == 0 ? 0 : correctAnswers / totalAnswered;
  bool get hasPassed => accuracy >= 0.7; // K53 passing threshold (70%)
  String get formattedTime {
    final minutes = (timeRemainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeRemainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class ExamNotifier extends StateNotifier<ExamState> {
  ExamTimerService? _timerService;
  final Ref? _ref; // Store ref for gamification access

  ExamNotifier({Ref? ref}) : _ref = ref, super(ExamState(
    questions: [],
    currentQuestionIndex: 0,
    isLoading: false,
    showExplanation: false,
    correctAnswers: 0,
    totalAnswered: 0,
    timeRemainingSeconds: 45 * 60,
    isPaused: false,
    isCompleted: false,
    questionStartTimes: {},
    mockExamConfig: null,
    userAnswers: {},
  ));

  void _setupTimerListener() {
    _timerService?.timerStream.listen((remainingSeconds) {
      state = state.copyWith(timeRemainingSeconds: remainingSeconds);
      
      if (remainingSeconds <= 0 && !state.isCompleted) {
        _completeExam();
      }
    });
  }

  @override
  void dispose() {
    _timerService?.dispose();
    super.dispose();
  }

  Future<void> loadExamQuestions({
    String? category,
    int? learnerCode,
    int questionCount = 30, // Standard K53 exam has 30 questions
    MockExamConfig? mockExamConfig,
  }) async {
    state = state.copyWith(isLoading: true, error: null, mockExamConfig: mockExamConfig);

    // Calculate exam duration based on question count (1.5 minutes per question)
    final examDurationSeconds = (questionCount * 90).clamp(300, 7200); // Min 5 minutes, max 120 minutes

    try {
      final questions = await OfflineDatabaseService.getRandomQuestions(
        count: questionCount,
        category: category,
        learnerCode: learnerCode,
      );

      if (questions.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No questions available for the selected criteria',
        );
        return;
      }

      // Create a new exam session using the new session database
      final userId = SupabaseService.currentUserId;
      if (userId != null) {
        try {
          // Create session using new database system
          final session = session_models.Session(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: session_models.SessionType.exam,
            userId: userId,
            category: category,
            totalQuestions: questions.length,
            currentQuestionIndex: 0,
            correctAnswers: 0,
            totalAnswered: 0,
            timeRemainingSeconds: examDurationSeconds,
            isPaused: false,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(hours: 24)),
            metadata: {
              'mock_exam_config': mockExamConfig?.toString(),
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
          );

          final sessionId = await SessionDatabaseService.createSession(session, questions);
          
          await AnalyticsService.trackExamSessionStart(
            sessionId: sessionId,
            category: category ?? 'all',
            timeLimitMinutes: 45, // K53 exam is 45 minutes
          );

          state = state.copyWith(
            questions: questions,
            isLoading: false,
            sessionId: sessionId,
            questionStartTimes: {questions[0].id: DateTime.now().millisecondsSinceEpoch},
          );
        } catch (e) {
          print('Failed to create session in database: $e');
          // Fallback to session ID only without database persistence
          final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
          state = state.copyWith(
            questions: questions,
            isLoading: false,
            sessionId: sessionId,
            questionStartTimes: {questions[0].id: DateTime.now().millisecondsSinceEpoch},
          );
        }
      } else {
        // Anonymous user - create session without database persistence
        final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
        state = state.copyWith(
          questions: questions,
          isLoading: false,
          sessionId: sessionId,
          questionStartTimes: {questions[0].id: DateTime.now().millisecondsSinceEpoch},
        );
      }

      // Log image requirements for all questions
      for (final question in questions) {
        await AnalyticsService.trackImageRequirement(
          questionId: question.id,
          questionText: question.questionText,
          imageUrl: question.imageUrl,
          category: question.category,
          learnerCode: question.learnerCode,
        );
      }

      // Initialize and start the exam timer
      _timerService?.dispose();
      _timerService = ExamTimerService(totalDurationSeconds: examDurationSeconds);
      _setupTimerListener();
      _timerService!.start();
      
      // Save initial session state
      await saveSessionState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load exam questions: $e',
      );
      _timerService?.dispose(); // Ensure timer is stopped on error
    }
  }

  Future<void> selectAnswer(int answerIndex) async {
    if (state.showExplanation || state.currentQuestion == null || state.isCompleted) return;

    final startTime = state.questionStartTimes[state.currentQuestion!.id] ?? DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = DateTime.now().millisecondsSinceEpoch - startTime;
    final isCorrect = state.currentQuestion!.isAnswerCorrect(answerIndex);
    final newCorrectAnswers = isCorrect ? state.correctAnswers + 1 : state.correctAnswers;

    // Store the user's answer for review
    final newUserAnswers = Map<String, int>.from(state.userAnswers);
    newUserAnswers[state.currentQuestion!.id] = answerIndex;

    final newTotalAnswered = state.totalAnswered + 1;
    final allQuestionsAnswered = newTotalAnswered == state.questions.length;

    state = state.copyWith(
      selectedAnswerIndex: answerIndex,
      showExplanation: true,
      correctAnswers: newCorrectAnswers,
      totalAnswered: newTotalAnswered,
      userAnswers: newUserAnswers,
    );

    // Record the answer with timing
    await _recordAnswer(answerIndex, isCorrect, elapsedMs);
    
    // Track in analytics
    if (state.sessionId != null && state.currentQuestion != null) {
      await AnalyticsService.trackQuestionAnswered(
        sessionId: state.sessionId!,
        questionId: state.currentQuestion!.id,
        isCorrect: isCorrect,
        elapsedMs: elapsedMs,
        hintsUsed: 0,
      );
    }

    // Award points for correct answers immediately
    if (isCorrect) {
      await _awardPointsForCorrectAnswer();
    }

    // Auto-advance to next question after 2 seconds for exam flow
    if (!state.isLastQuestion) {
      await Future.delayed(const Duration(seconds: 2));
      nextQuestion();
    } else {
      // Last question answered, complete the exam
      await _completeExam();
    }

    // Check if all questions have been answered (user might have answered out of order)
    if (allQuestionsAnswered && !state.isCompleted) {
      await _completeExam();
    }
  }

  Future<void> _recordAnswer(int answerIndex, bool isCorrect, int elapsedMs) async {
    if (state.sessionId == null || state.currentQuestion == null) return;

    try {
      await OfflineDatabaseService.recordAnswer(
        sessionId: state.sessionId!,
        questionId: state.currentQuestion!.id,
        chosenIndex: answerIndex,
        isCorrect: isCorrect,
        elapsedMs: elapsedMs,
        hintsUsed: 0,
      );
    } catch (e) {
      print('Failed to record answer: $e');
      // Optionally, we could retry or store locally for later sync
    }
  }

  void nextQuestion() {
    if (state.isLastQuestion || state.isCompleted) return;

    final newIndex = state.currentQuestionIndex + 1;
    final newQuestion = state.questions[newIndex];
    
    state = state.copyWith(
      currentQuestionIndex: newIndex,
      selectedAnswerIndex: null,
      showExplanation: false,
      questionStartTimes: {
        ...state.questionStartTimes,
        newQuestion.id: DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void previousQuestion() {
    if (state.isFirstQuestion || state.isCompleted) return;

    final newIndex = state.currentQuestionIndex - 1;
    final newQuestion = state.questions[newIndex];
    
    state = state.copyWith(
      currentQuestionIndex: newIndex,
      selectedAnswerIndex: null,
      showExplanation: false,
      questionStartTimes: {
        ...state.questionStartTimes,
        newQuestion.id: DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void togglePause() {
    if (state.isCompleted) return;

    final newPausedState = !state.isPaused;
    state = state.copyWith(isPaused: newPausedState);

    if (newPausedState) {
      _timerService?.pause();
    } else {
      _timerService?.resume();
    }

    // Track pause/resume event
    AnalyticsService.trackUserEngagement(
      eventName: newPausedState ? 'exam_paused' : 'exam_resumed',
      properties: {
        'session_id': state.sessionId,
        'time_remaining': state.timeRemainingSeconds,
      },
    );
  }

  Future<void> _completeExam() async {
    if (state.isCompleted) return;
    
    // Stop timer immediately to prevent further state changes
    _timerService?.dispose();
    state = state.copyWith(isCompleted: true);

    if (state.sessionId == null) {
      print('Exam completed without session ID - skipping database update');
      return;
    }

    try {
      final timeSpentSeconds = _timerService != null
          ? _timerService!.remainingSeconds > 0
            ? _timerService!.remainingSeconds
            : 0
          : 0;
      
      // Update session completion in the new database
      if (state.sessionId != null) {
        try {
          // Load the current session
          final session = await SessionDatabaseService.getSession(state.sessionId!);
          if (session != null) {
            // Update session with completion data
            final updatedSession = session.copyWith(
              correctAnswers: state.correctAnswers,
              totalAnswered: state.totalAnswered,
              timeRemainingSeconds: timeSpentSeconds,
              isCompleted: true,
              updatedAt: DateTime.now(),
            );
            
            await SessionDatabaseService.updateSession(updatedSession);
          }
        } catch (e) {
          print('Error updating session in database: $e');
          // Continue with completion even if database update fails
        }
      }

      // Clear session persistence
      await SessionPersistenceService.clearExamSession();
      await _timerService?.clearExam();

      // Track exam completion in analytics
      await AnalyticsService.trackExamSessionComplete(
        sessionId: state.sessionId!,
        score: state.correctAnswers,
        totalQuestions: state.questions.length,
        passed: state.hasPassed,
        timeSpentSeconds: timeSpentSeconds,
      );

      // Track gamification progress
      if (state.questions.isNotEmpty) {
        final category = state.questions.first.category;
        
        // Use the gamification provider to track exam completion
        if (_ref != null) {
          final gamificationNotifier = _ref!.read(gamificationProvider.notifier);
          await gamificationNotifier.trackExamSessionComplete(
            correctAnswers: state.correctAnswers,
            totalQuestions: state.questions.length,
            category: category,
            passed: state.hasPassed,
          );
        }
      }
    } catch (e) {
      print('Error completing exam: $e');
      // Even if database update fails, we keep the state as completed
      // to prevent multiple submissions
    }
  }


  Future<void> retryExam() async {
    // Use the new reset method to completely clear the state
    resetExam();
    
    await AnalyticsService.trackUserEngagement(
      eventName: 'exam_retry',
      properties: {'question_count': state.questions.length},
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Completely reset the exam state to allow starting a new exam
  void resetExam() {
    _timerService?.dispose();
    _timerService = null;
    
    state = ExamState(
      questions: [],
      currentQuestionIndex: 0,
      isLoading: false,
      showExplanation: false,
      correctAnswers: 0,
      totalAnswered: 0,
      timeRemainingSeconds: 45 * 60,
      isPaused: false,
      isCompleted: false,
      questionStartTimes: {},
      mockExamConfig: null,
      userAnswers: {},
    );
  }

  // Handle app lifecycle events (e.g., when app goes to background)
  void onPause() {
    if (!state.isPaused && !state.isCompleted) {
      togglePause();
    }
  }

  void onResume() {
    if (state.isPaused && !state.isCompleted) {
      togglePause();
    }
  }

  // Save current session state for persistence
  Future<void> saveSessionState() async {
    if (state.sessionId == null || state.questions.isEmpty) return;

    try {
      // First, migrate any old sessions if needed
      await SessionMigrationService.migrateFromSharedPreferences();

      // Create or update session in database
      final session = session_models.Session(
        id: state.sessionId!,
        type: session_models.SessionType.exam,
        userId: SupabaseService.currentUserId,
        category: state.questions.isNotEmpty ? state.questions.first.category : null,
        totalQuestions: state.questions.length,
        currentQuestionIndex: state.currentQuestionIndex,
        correctAnswers: state.correctAnswers,
        totalAnswered: state.totalAnswered,
        timeRemainingSeconds: state.timeRemainingSeconds,
        isPaused: state.isPaused,
        isCompleted: state.isCompleted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        metadata: {
          'mock_exam_config': state.mockExamConfig?.toString(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      await SessionDatabaseService.createSession(session, state.questions);
      
      // Also update session progress for real-time tracking
      await SessionRecoveryService.updateSessionProgress(
        sessionId: state.sessionId!,
        currentQuestionIndex: state.currentQuestionIndex,
        correctAnswers: state.correctAnswers,
        totalAnswered: state.totalAnswered,
        timeRemainingSeconds: state.timeRemainingSeconds,
      );

    } catch (e) {
      print('Error saving session state to database: $e');
      // Fallback to old SharedPreferences method if database fails
      final sessionState = SessionState(
        type: SessionType.exam,
        questions: state.questions,
        currentQuestionIndex: state.currentQuestionIndex,
        selectedAnswerIndex: state.selectedAnswerIndex,
        showExplanation: state.showExplanation,
        sessionId: state.sessionId,
        correctAnswers: state.correctAnswers,
        totalAnswered: state.totalAnswered,
        userAnswers: state.userAnswers,
        additionalData: {
          'timeRemainingSeconds': state.timeRemainingSeconds,
          'isPaused': state.isPaused,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      await SessionPersistenceService.saveExamSession(sessionState);
    }
  }

  // Load session state from persistence
  Future<void> loadSessionState(String sessionId) async {
    try {
      // First, migrate any old sessions if needed
      await SessionMigrationService.migrateFromSharedPreferences();

      // Load session from database
      final session = await SessionDatabaseService.getSession(sessionId);
      if (session == null) {
        print('Session not found in database: $sessionId');
        return;
      }

      // Validate session can be recovered
      if (!await SessionRecoveryService.validateSession(session)) {
        print('Session is not valid for recovery: $sessionId');
        return;
      }

      // Get session questions
      // Get session questions
      final questions = await SessionDatabaseService.getSessionQuestions(sessionId);

      state = ExamState(
        questions: questions,
        currentQuestionIndex: session.currentQuestionIndex,
        isLoading: false,
        selectedAnswerIndex: null, // Reset selected answer on load
        showExplanation: false, // Reset explanation on load
        sessionId: session.id,
        correctAnswers: session.correctAnswers,
        totalAnswered: session.totalAnswered,
        timeRemainingSeconds: session.timeRemainingSeconds,
        isPaused: session.isPaused,
        isCompleted: session.isCompleted,
        questionStartTimes: {questions[session.currentQuestionIndex].id: DateTime.now().millisecondsSinceEpoch},
        mockExamConfig: null, // Will be restored from metadata if needed
        userAnswers: {}, // Will be loaded from session answers
      );

      // Load user answers for review
      final sessionAnswers = await SessionDatabaseService.getSessionAnswers(sessionId);
      final userAnswers = <String, int>{};
      for (final answer in sessionAnswers) {
        userAnswers[answer.questionId] = answer.chosenIndex;
      }
      
      state = state.copyWith(userAnswers: userAnswers);

      // Initialize timer with remaining time
      _timerService?.dispose();
      _timerService = ExamTimerService(totalDurationSeconds: session.timeRemainingSeconds);
      _setupTimerListener();

      if (!session.isPaused) {
        _timerService!.start();
      }

      print('Successfully loaded session from database: $sessionId');

    } catch (e) {
      print('Error loading session from database: $e');
      
      // Fallback to old SharedPreferences method if database fails
      final sessionState = await SessionPersistenceService.loadExamSession();
      if (sessionState != null) {
        state = ExamState(
          questions: sessionState.questions,
          currentQuestionIndex: sessionState.currentQuestionIndex,
          isLoading: false,
          selectedAnswerIndex: sessionState.selectedAnswerIndex,
          showExplanation: sessionState.showExplanation,
          sessionId: sessionState.sessionId,
          correctAnswers: sessionState.correctAnswers,
          totalAnswered: sessionState.totalAnswered,
          timeRemainingSeconds: sessionState.additionalData['timeRemainingSeconds'] ?? 45 * 60,
          isPaused: sessionState.additionalData['isPaused'] ?? false,
          isCompleted: false,
          questionStartTimes: {sessionState.questions[sessionState.currentQuestionIndex].id: DateTime.now().millisecondsSinceEpoch},
          mockExamConfig: null,
          userAnswers: sessionState.userAnswers,
        );

        // Initialize timer with remaining time
        final remainingSeconds = sessionState.additionalData['timeRemainingSeconds'] ?? 45 * 60;
        _timerService?.dispose();
        _timerService = ExamTimerService(totalDurationSeconds: remainingSeconds);
        _setupTimerListener();

        if (sessionState.additionalData['isPaused'] != true) {
          _timerService!.start();
        }
      }
    }
  }

  // Load mock exam with specific configuration
  Future<void> loadMockExamQuestions(MockExamConfig config) async {
    await loadExamQuestions(
      category: config.category,
      learnerCode: config.learnerCode,
      questionCount: config.questionCount,
      mockExamConfig: config,
    );
  }

  // Overloaded method to handle both old and new session loading
  Future<void> loadSession(dynamic sessionData) async {
    if (sessionData is String) {
      // New database system - session ID
      await loadSessionState(sessionData);
    } else if (sessionData is SessionState) {
      // Old SharedPreferences system - full session state
      // This is a fallback for migration period
      state = ExamState(
        questions: sessionData.questions,
        currentQuestionIndex: sessionData.currentQuestionIndex,
        isLoading: false,
        selectedAnswerIndex: sessionData.selectedAnswerIndex,
        showExplanation: sessionData.showExplanation,
        sessionId: sessionData.sessionId,
        correctAnswers: sessionData.correctAnswers,
        totalAnswered: sessionData.totalAnswered,
        timeRemainingSeconds: sessionData.additionalData['timeRemainingSeconds'] ?? 45 * 60,
        isPaused: sessionData.additionalData['isPaused'] ?? false,
        isCompleted: false,
        questionStartTimes: {sessionData.questions[sessionData.currentQuestionIndex].id: DateTime.now().millisecondsSinceEpoch},
        mockExamConfig: null,
        userAnswers: sessionData.userAnswers,
      );

      // Initialize timer with remaining time
      final remainingSeconds = sessionData.additionalData['timeRemainingSeconds'] ?? 45 * 60;
      _timerService?.dispose();
      _timerService = ExamTimerService(totalDurationSeconds: remainingSeconds);
      _setupTimerListener();

      if (sessionData.additionalData['isPaused'] != true) {
        _timerService!.start();
      }
    }
  }
  // Award points for correct answers
  Future<void> _awardPointsForCorrectAnswer() async {
    try {
      // Award 10 points for each correct answer using offline tracking
      await GamificationService().trackOfflineActivity(
        activityType: 'correct_answer',
        value: 10, // 10 points per correct answer
        metadata: {
          'question_id': state.currentQuestion?.id,
          'category': state.currentQuestion?.category,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      // Also track daily points
      await GamificationService().trackOfflineActivity(
        activityType: 'daily_points',
        value: 10, // 10 daily points per correct answer
        metadata: {
          'question_id': state.currentQuestion?.id,
          'category': state.currentQuestion?.category,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'is_daily': true,
        },
      );
    } catch (e) {
      print('Error awarding points: $e');
    }
  }
}


final examProvider = StateNotifierProvider<ExamNotifier, ExamState>((ref) {
  return ExamNotifier(ref: ref);
});