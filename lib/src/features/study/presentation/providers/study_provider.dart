import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../exam/data/mock_exam_config.dart';
import '../../../../core/models/question.dart';
import '../../../../core/models/session.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/analytics_service.dart';

final studyProvider = StateNotifierProvider<StudyProvider, StudyState>((ref) {
  return StudyProvider();
});

class StudyState {
  final Session? currentSession;
  final List<Question> questions;
  final int currentQuestionIndex;
  final bool isLoading;
  final String? error;
  final bool showExplanation;
  final int? selectedAnswerIndex;
  final Map<String, int> userAnswers;
  final int correctAnswers;
  final int totalAnswered;

  StudyState({
    this.currentSession,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.isLoading = false,
    this.error,
    this.showExplanation = false,
    this.selectedAnswerIndex,
    this.userAnswers = const {},
    this.correctAnswers = 0,
    this.totalAnswered = 0,
  });

  StudyState copyWith({
    Session? currentSession,
    List<Question>? questions,
    int? currentQuestionIndex,
    bool? isLoading,
    String? error,
    bool? showExplanation,
    int? selectedAnswerIndex,
    Map<String, int>? userAnswers,
    int? correctAnswers,
    int? totalAnswered,
  }) {
    return StudyState(
      currentSession: currentSession ?? this.currentSession,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      showExplanation: showExplanation ?? this.showExplanation,
      selectedAnswerIndex: selectedAnswerIndex ?? this.selectedAnswerIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswered: totalAnswered ?? this.totalAnswered,
    );
  }

  Question? get currentQuestion {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }

  double get progress {
    if (questions.isEmpty) return 0.0;
    return (currentQuestionIndex + 1) / questions.length;
  }

  double get accuracy {
    if (totalAnswered == 0) return 0.0;
    return correctAnswers / totalAnswered;
  }

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  bool get isFirstQuestion => currentQuestionIndex == 0;
}

class StudyProvider extends StateNotifier<StudyState> {
  StudyProvider() : super(StudyState());

  // Start a new study session
  Future<void> startStudySession({
    String? category,
    int? learnerCode,
    int questionCount = 10,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get questions for the study session
      final questions = await DatabaseService().getRandomQuestions(
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

      // Create a new session
      final sessionId = const Uuid().v4();
      final session = Session(
        id: sessionId,
        type: SessionType.study,
        category: category,
        totalQuestions: questions.length,
        currentQuestionIndex: 0,
        correctAnswers: 0,
        totalAnswered: 0,
        timeRemainingSeconds: 0,
        isPaused: false,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      // Track analytics
      await AnalyticsService.trackStudySessionStart(
        sessionId: sessionId,
        category: category,
        learnerCode: learnerCode,
      );

      state = state.copyWith(
        currentSession: session,
        questions: questions,
        currentQuestionIndex: 0,
        isLoading: false,
        userAnswers: {},
        correctAnswers: 0,
        totalAnswered: 0,
        showExplanation: false,
        selectedAnswerIndex: null,
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to start study session: $e',
      );
    }
  }

  // Answer the current question
  Future<void> answerQuestion(int answerIndex) async {
    final currentQuestion = state.currentQuestion;
    final session = state.currentSession;
    if (currentQuestion == null || session == null) return;

    final isCorrect = currentQuestion.isAnswerCorrect(answerIndex);
    final questionId = currentQuestion.id;

    // Update session statistics
    final newCorrectAnswers = isCorrect 
      ? state.correctAnswers + 1 
      : state.correctAnswers;
    final newTotalAnswered = state.totalAnswered + 1;

    // Update user answers
    final newUserAnswers = Map<String, int>.from(state.userAnswers);
    newUserAnswers[questionId] = answerIndex;

    // Track analytics
    await AnalyticsService.trackQuestionAnswered(
      sessionId: session.id,
      questionId: questionId,
      isCorrect: isCorrect,
      elapsedMs: 0, // TODO: Implement timing
      hintsUsed: 0, // TODO: Implement hints
    );

    state = state.copyWith(
      selectedAnswerIndex: answerIndex,
      showExplanation: true,
      userAnswers: newUserAnswers,
      correctAnswers: newCorrectAnswers,
      totalAnswered: newTotalAnswered,
    );

    // Update question statistics in database
    await DatabaseService().updateQuestionStats(
      questionId: questionId,
      isCorrect: isCorrect,
    );
  }

  // Move to next question
  void nextQuestion() {
    if (state.isLastQuestion) return;

    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      showExplanation: false,
      selectedAnswerIndex: null,
    );
  }

  // Move to previous question
  void previousQuestion() {
    if (state.isFirstQuestion) return;

    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex - 1,
      showExplanation: false,
      selectedAnswerIndex: null,
    );
  }

  // Complete the study session
  Future<void> completeSession() async {
    final session = state.currentSession;
    if (session == null) return;

    final completedSession = session.copyWith(
      isCompleted: true,
      updatedAt: DateTime.now(),
    );

    // Track analytics
    await AnalyticsService.trackStudySessionComplete(
      sessionId: session.id,
      correctAnswers: state.correctAnswers,
      totalAnswered: state.totalAnswered,
      category: session.category,
    );

    state = state.copyWith(
      currentSession: completedSession,
    );
  }

  // Reset the study session
  void resetSession() {
    state = StudyState();
  }

  // Toggle explanation visibility
  void toggleExplanation() {
    state = state.copyWith(
      showExplanation: !state.showExplanation,
    );
  }

  // Jump to a specific question
  void jumpToQuestion(int index) {
    if (index < 0 || index >= state.questions.length) return;

    state = state.copyWith(
      currentQuestionIndex: index,
      showExplanation: false,
      selectedAnswerIndex: null,
    );
  }

  // Get question by ID
  Question? getQuestionById(String questionId) {
    return state.questions.firstWhere(
      (q) => q.id == questionId,
      orElse: () => throw StateError('Question not found'),
    );
  }

  // Check if a question has been answered
  bool isQuestionAnswered(String questionId) {
    return state.userAnswers.containsKey(questionId);
  }

  // Get user's answer for a question
  int? getUserAnswer(String questionId) {
    return state.userAnswers[questionId];
  }

  // Check if user's answer is correct
  bool isUserAnswerCorrect(String questionId) {
    final userAnswer = getUserAnswer(questionId);
    if (userAnswer == null) return false;

    final question = getQuestionById(questionId);
    return question?.isAnswerCorrect(userAnswer) ?? false;
  }

  // Get session statistics
  Map<String, dynamic> getSessionStats() {
    return {
      'totalQuestions': state.questions.length,
      'answeredQuestions': state.totalAnswered,
      'correctAnswers': state.correctAnswers,
      'accuracy': state.accuracy,
      'progress': state.progress,
    };
  }
}