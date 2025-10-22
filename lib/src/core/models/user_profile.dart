class UserProfile {
  final String id;
  final String? handle;
  final int learnerCode;
  final String locale;
  final DateTime? studyGoalDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Dual Point System
  final int dailyPoints;
  final int gamingPoints;
  final int totalPoints;
  final int level;
  final int loginStreak;
  final DateTime? lastLoginDate;
  final DateTime? lastDailyPointsDate;

  UserProfile({
    required this.id,
    required this.handle,
    required this.learnerCode,
    required this.locale,
    required this.studyGoalDate,
    required this.createdAt,
    required this.updatedAt,
    this.dailyPoints = 0,
    this.gamingPoints = 0,
    this.totalPoints = 0,
    this.level = 1,
    this.loginStreak = 0,
    this.lastLoginDate,
    this.lastDailyPointsDate,
  });

  // Helper method to create from Supabase response
  factory UserProfile.fromSupabase(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] as String,
      handle: data['handle'] as String?,
      learnerCode: data['learner_code'] as int,
      locale: data['locale'] as String,
      studyGoalDate: data['study_goal_date'] != null
          ? DateTime.parse(data['study_goal_date'] as String)
          : null,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
      dailyPoints: data['daily_points'] as int? ?? 0,
      gamingPoints: data['gaming_points'] as int? ?? 0,
      totalPoints: data['total_points'] as int? ?? 0,
      level: data['level'] as int? ?? 1,
      loginStreak: data['login_streak'] as int? ?? 0,
      lastLoginDate: data['last_login_date'] != null
          ? DateTime.parse(data['last_login_date'] as String)
          : null,
      lastDailyPointsDate: data['last_daily_points_date'] != null
          ? DateTime.parse(data['last_daily_points_date'] as String)
          : null,
    );
  }

  // Convert to Supabase insert/update format
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'handle': handle,
      'learner_code': learnerCode,
      'locale': locale,
      'study_goal_date': studyGoalDate?.toIso8601String(),
      'daily_points': dailyPoints,
      'gaming_points': gamingPoints,
      'total_points': totalPoints,
      'level': level,
      'login_streak': loginStreak,
      'last_login_date': lastLoginDate?.toIso8601String(),
      'last_daily_points_date': lastDailyPointsDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for immutability
  UserProfile copyWith({
    String? id,
    String? handle,
    int? learnerCode,
    String? locale,
    DateTime? studyGoalDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? dailyPoints,
    int? gamingPoints,
    int? totalPoints,
    int? level,
    int? loginStreak,
    DateTime? lastLoginDate,
    DateTime? lastDailyPointsDate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      handle: handle ?? this.handle,
      learnerCode: learnerCode ?? this.learnerCode,
      locale: locale ?? this.locale,
      studyGoalDate: studyGoalDate ?? this.studyGoalDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dailyPoints: dailyPoints ?? this.dailyPoints,
      gamingPoints: gamingPoints ?? this.gamingPoints,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      loginStreak: loginStreak ?? this.loginStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      lastDailyPointsDate: lastDailyPointsDate ?? this.lastDailyPointsDate,
    );
  }

  // Helper methods for point management
  UserProfile addDailyPoints(int points) {
    return copyWith(
      dailyPoints: dailyPoints + points,
      totalPoints: totalPoints + points,
      lastDailyPointsDate: DateTime.now(),
    );
  }

  UserProfile addGamingPoints(int points) {
    return copyWith(
      gamingPoints: gamingPoints + points,
      totalPoints: totalPoints + points,
    );
  }

  UserProfile updateLoginStreak(int streak) {
    return copyWith(
      loginStreak: streak,
      lastLoginDate: DateTime.now(),
    );
  }

  UserProfile updateLevel(int newLevel) {
    return copyWith(level: newLevel);
  }

  // Check if user can claim daily points today
  bool canClaimDailyPoints() {
    if (lastDailyPointsDate == null) return true;
    final now = DateTime.now();
    final lastClaim = lastDailyPointsDate!;
    return now.day != lastClaim.day || now.month != lastClaim.month || now.year != lastClaim.year;
  }

  // Check if user has logged in today
  bool hasLoggedInToday() {
    if (lastLoginDate == null) return false;
    final now = DateTime.now();
    final lastLogin = lastLoginDate!;
    return now.day == lastLogin.day && now.month == lastLogin.month && now.year == lastLogin.year;
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, handle: $handle, learnerCode: $learnerCode, '
        'dailyPoints: $dailyPoints, gamingPoints: $gamingPoints, totalPoints: $totalPoints, '
        'level: $level, loginStreak: $loginStreak)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}