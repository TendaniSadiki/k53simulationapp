import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import './app_initializer.dart';
import './services/supabase_service.dart';
import './services/session_persistence_service.dart';
import './services/session_database_service.dart';
import './models/session.dart' as session_models;
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/study/presentation/providers/study_provider.dart';
import '../features/exam/presentation/providers/exam_provider.dart';
import '../shared/routing/app_router.dart';
import '../shared/widgets/session_recovery_dialog.dart';

class K53App extends ConsumerStatefulWidget {
  const K53App({super.key});

  @override
  ConsumerState<K53App> createState() => _K53AppState();
}

class _K53AppState extends ConsumerState<K53App> {
  bool _sessionRecoveryChecked = false;

  @override
  void initState() {
    super.initState();
    _initializeSessionDatabase();
    _checkForPendingSessions();
  }

  Future<void> _initializeSessionDatabase() async {
    try {
      await SessionDatabaseService.initialize();
      print('Session database initialized successfully');
    } catch (e) {
      print('Failed to initialize session database: $e');
    }
  }

  Future<void> _checkForPendingSessions() async {
    // Wait a bit for the app to initialize and check auth state
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Only check for sessions if user is authenticated
    final authState = ref.read(authProvider);
    final isAuthenticated = authState.value?.session != null;
    
    if (!isAuthenticated) {
      if (mounted) {
        setState(() {
          _sessionRecoveryChecked = true;
        });
      }
      return;
    }
    
    // Check for any pending sessions using the new database system
    final userId = SupabaseService.currentUserId;
    List<session_models.Session> pendingSessions = [];
    
    if (userId != null) {
      try {
        pendingSessions = await SessionDatabaseService.getUserSessions(userId);
      } catch (e) {
        print('Error loading sessions from database: $e');
        // Fallback to old persistence system
      }
    }
    
    // Fallback to old persistence system if database fails or no user ID
    final studySession = await SessionPersistenceService.loadStudySession();
    final examSession = await SessionPersistenceService.loadExamSession();
    
    if (mounted) {
      setState(() {
        _sessionRecoveryChecked = true;
      });
      
      // Show recovery dialog for database sessions first
      if (pendingSessions.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            for (final session in pendingSessions) {
              if (session.canRecover) {
                _showDatabaseSessionRecoveryDialog(context, session);
                break; // Only show recovery for first valid session
              }
            }
          }
        });
      }
      
      // Fallback to old persistence system
      if (studySession != null && SessionPersistenceService.isSessionValid(studySession)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showSessionRecoveryDialog(context, studySession, SessionType.study);
          }
        });
      } else if (studySession != null) {
        // Clear expired study session
        SessionPersistenceService.clearStudySession();
      }
      
      if (examSession != null && SessionPersistenceService.isSessionValid(examSession)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showSessionRecoveryDialog(context, examSession, SessionType.exam);
          }
        });
      } else if (examSession != null) {
        // Clear expired exam session
        SessionPersistenceService.clearExamSession();
      }
    }
  }

  void _showSessionRecoveryDialog(BuildContext context, SessionState session, SessionType sessionType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionRecoveryDialog(
        session: session,
        onContinue: () {
          Navigator.of(context).pop();
          _continueSession(session, sessionType);
        },
        onStartNew: () {
          Navigator.of(context).pop();
          _startNewSession(sessionType);
        },
      ),
    );
  }

  void _showDatabaseSessionRecoveryDialog(BuildContext context, session_models.Session session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionRecoveryDialog(
        session: SessionState(
          type: session.type == session_models.SessionType.study ? SessionType.study : SessionType.exam,
          questions: [], // Will be loaded when continuing
          currentQuestionIndex: session.currentQuestionIndex,
          selectedAnswerIndex: null,
          showExplanation: false,
          sessionId: session.id,
          correctAnswers: session.correctAnswers,
          totalAnswered: session.totalAnswered,
          userAnswers: {},
          additionalData: {
            'timeRemainingSeconds': session.timeRemainingSeconds,
            'isPaused': session.isPaused,
            'timestamp': session.updatedAt.millisecondsSinceEpoch,
          },
        ),
        onContinue: () {
          Navigator.of(context).pop();
          _continueDatabaseSession(session);
        },
        onStartNew: () {
          Navigator.of(context).pop();
          _startNewDatabaseSession(session);
        },
      ),
    );
  }

  void _continueSession(SessionState session, SessionType sessionType) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sessionType == SessionType.study) {
        ref.read(studyProvider.notifier).loadSessionState(session);
        context.go('/study');
      } else if (sessionType == SessionType.exam) {
        // For exam sessions, use the session ID with the new database system
        if (session.sessionId != null) {
          ref.read(examProvider.notifier).loadSessionState(session.sessionId!);
        } else {
          // Fallback to old method if no session ID
          ref.read(examProvider.notifier).loadSession(session);
        }
        context.go('/exam');
      }
    });
  }

  void _continueDatabaseSession(session_models.Session session) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (session.type == session_models.SessionType.study) {
        // TODO: Implement study session loading from database
        context.go('/study');
      } else if (session.type == session_models.SessionType.exam) {
        ref.read(examProvider.notifier).loadSessionState(session.id);
        context.go('/exam');
      }
    });
  }

  void _startNewSession(SessionType sessionType) {
    if (sessionType == SessionType.study) {
      SessionPersistenceService.clearStudySession();
    } else if (sessionType == SessionType.exam) {
      SessionPersistenceService.clearExamSession();
    }
  }

  void _startNewDatabaseSession(session_models.Session session) {
    // Delete the session from database
    SessionDatabaseService.deleteSession(session.id);
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state to rebuild when auth changes
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.value?.session != null;
    
    // Check for sessions when authentication state changes from unauthenticated to authenticated
    if (isAuthenticated && !_sessionRecoveryChecked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForPendingSessions();
      });
    }
    
    // Reset session recovery check when user logs out
    if (!isAuthenticated && _sessionRecoveryChecked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _sessionRecoveryChecked = false;
          });
        }
      });
    }
    
    // Create router in build method to have access to ref
    final router = AppRouter.router(ref);

    return MaterialApp.router(
      title: 'K53 Learner\'s License',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside text fields
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: child,
        );
      },
    );
  }
}