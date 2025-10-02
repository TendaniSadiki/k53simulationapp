import 'package:flutter/material.dart';

class LearningGoal {
  final String id;
  final String title;
  final String description;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GoalStatus status;
  final List<Milestone> milestones;
  final List<DailyTask> dailyTasks;

  LearningGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.status = GoalStatus.active,
    this.milestones = const [],
    this.dailyTasks = const [],
  });

  factory LearningGoal.fromJson(Map<String, dynamic> json) {
    return LearningGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetDate: DateTime.parse(json['target_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      status: GoalStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => GoalStatus.active,
      ),
      milestones: (json['milestones'] as List<dynamic>?)
          ?.map((m) => Milestone.fromJson(m))
          .toList() ?? [],
      dailyTasks: (json['daily_tasks'] as List<dynamic>?)
          ?.map((t) => DailyTask.fromJson(t))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'target_date': targetDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'daily_tasks': dailyTasks.map((t) => t.toJson()).toList(),
    };
  }

  LearningGoal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    GoalStatus? status,
    List<Milestone>? milestones,
    List<DailyTask>? dailyTasks,
  }) {
    return LearningGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      milestones: milestones ?? this.milestones,
      dailyTasks: dailyTasks ?? this.dailyTasks,
    );
  }

  // Progress calculation
  double get overallProgress {
    if (milestones.isEmpty) return 0.0;
    final completedMilestones = milestones.where((m) => m.isCompleted).length;
    return completedMilestones / milestones.length;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    return difference.inDays;
  }

  bool get isOnTrack {
    final expectedProgress = _calculateExpectedProgress();
    return overallProgress >= expectedProgress;
  }

  double _calculateExpectedProgress() {
    final totalDays = targetDate.difference(createdAt).inDays;
    final daysPassed = DateTime.now().difference(createdAt).inDays;
    return daysPassed / totalDays;
  }
}

enum GoalStatus {
  active,
  completed,
  paused,
  abandoned,
}

class Milestone {
  final String id;
  final String title;
  final String description;
  final DateTime targetDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<String> tasks;
  final MilestoneType type;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
    this.isCompleted = false,
    this.completedAt,
    this.tasks = const [],
    this.type = MilestoneType.knowledge,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetDate: DateTime.parse(json['target_date']),
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      tasks: List<String>.from(json['tasks'] ?? []),
      type: MilestoneType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MilestoneType.knowledge,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'target_date': targetDate.toIso8601String(),
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'tasks': tasks,
      'type': type.toString().split('.').last,
    };
  }

  Milestone copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? targetDate,
    bool? isCompleted,
    DateTime? completedAt,
    List<String>? tasks,
    MilestoneType? type,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      tasks: tasks ?? this.tasks,
      type: type ?? this.type,
    );
  }

  Color get typeColor {
    switch (type) {
      case MilestoneType.knowledge:
        return Colors.blue;
      case MilestoneType.skill:
        return Colors.green;
      case MilestoneType.practice:
        return Colors.orange;
      case MilestoneType.assessment:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String get typeLabel {
    switch (type) {
      case MilestoneType.knowledge:
        return 'Knowledge';
      case MilestoneType.skill:
        return 'Skill';
      case MilestoneType.practice:
        return 'Practice';
      case MilestoneType.assessment:
        return 'Assessment';
      default:
        return 'Other';
    }
  }
}

enum MilestoneType {
  knowledge,
  skill,
  practice,
  assessment,
}

class DailyTask {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isCompleted;
  final DateTime? completedAt;
  final TaskType type;
  final int estimatedMinutes;
  final String? reflection;
  final List<String> obstacles;

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
    this.completedAt,
    this.type = TaskType.study,
    this.estimatedMinutes = 30,
    this.reflection,
    this.obstacles = const [],
  });

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      type: TaskType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TaskType.study,
      ),
      estimatedMinutes: json['estimated_minutes'] ?? 30,
      reflection: json['reflection'],
      obstacles: List<String>.from(json['obstacles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'type': type.toString().split('.').last,
      'estimated_minutes': estimatedMinutes,
      'reflection': reflection,
      'obstacles': obstacles,
    };
  }

  DailyTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? isCompleted,
    DateTime? completedAt,
    TaskType? type,
    int? estimatedMinutes,
    String? reflection,
    List<String>? obstacles,
  }) {
    return DailyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      type: type ?? this.type,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      reflection: reflection ?? this.reflection,
      obstacles: obstacles ?? this.obstacles,
    );
  }

  Color get typeColor {
    switch (type) {
      case TaskType.study:
        return Colors.blue;
      case TaskType.practice:
        return Colors.green;
      case TaskType.review:
        return Colors.orange;
      case TaskType.assessment:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String get typeLabel {
    switch (type) {
      case TaskType.study:
        return 'Study';
      case TaskType.practice:
        return 'Practice';
      case TaskType.review:
        return 'Review';
      case TaskType.assessment:
        return 'Assessment';
      default:
        return 'Other';
    }
  }
}

enum TaskType {
  study,
  practice,
  review,
  assessment,
}

class ProgressAnalytics {
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalStudySessions;
  final int totalPracticeSessions;
  final int totalQuestionsAnswered;
  final int correctAnswers;
  final double averageAccuracy;
  final int totalStudyMinutes;
  final List<DailyProgress> dailyProgress;
  final Map<String, double> categoryAccuracy;
  final List<String> commonObstacles;

  ProgressAnalytics({
    required this.periodStart,
    required this.periodEnd,
    required this.totalStudySessions,
    required this.totalPracticeSessions,
    required this.totalQuestionsAnswered,
    required this.correctAnswers,
    required this.averageAccuracy,
    required this.totalStudyMinutes,
    required this.dailyProgress,
    required this.categoryAccuracy,
    required this.commonObstacles,
  });

  double get accuracyPercentage => averageAccuracy * 100;

  int get incorrectAnswers => totalQuestionsAnswered - correctAnswers;

  double get studyEfficiency {
    if (totalStudyMinutes == 0) return 0.0;
    return correctAnswers / totalStudyMinutes;
  }

  int get streakDays {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < dailyProgress.length; i++) {
      final day = dailyProgress[i];
      if (day.date.isBefore(now)) {
        if (day.totalMinutes > 0) {
          streak++;
        } else {
          break;
        }
      }
    }
    return streak;
  }
}

class DailyProgress {
  final DateTime date;
  final int studyMinutes;
  final int practiceMinutes;
  final int questionsAnswered;
  final int correctAnswers;
  final String? reflection;
  final List<String> obstacles;

  DailyProgress({
    required this.date,
    required this.studyMinutes,
    required this.practiceMinutes,
    required this.questionsAnswered,
    required this.correctAnswers,
    this.reflection,
    this.obstacles = const [],
  });

  int get totalMinutes => studyMinutes + practiceMinutes;

  double get accuracy {
    if (questionsAnswered == 0) return 0.0;
    return correctAnswers / questionsAnswered;
  }

  bool get hasActivity => totalMinutes > 0 || questionsAnswered > 0;

  DailyProgress copyWith({
    DateTime? date,
    int? studyMinutes,
    int? practiceMinutes,
    int? questionsAnswered,
    int? correctAnswers,
    String? reflection,
    List<String>? obstacles,
  }) {
    return DailyProgress(
      date: date ?? this.date,
      studyMinutes: studyMinutes ?? this.studyMinutes,
      practiceMinutes: practiceMinutes ?? this.practiceMinutes,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      reflection: reflection ?? this.reflection,
      obstacles: obstacles ?? this.obstacles,
    );
  }
}