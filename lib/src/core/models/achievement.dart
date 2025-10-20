class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int points;
  final AchievementType type;
  final int targetValue;
  final bool isHidden;
  final DateTime createdAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.points,
    required this.type,
    required this.targetValue,
    this.isHidden = false,
    required this.createdAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      points: (json['points'] is int) ? json['points'] : (json['points']?.toInt() ?? 0),
      type: AchievementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AchievementType.streak,
      ),
      targetValue: json['target_value'],
      isHidden: json['is_hidden'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  factory Achievement.fromSupabase(Map<String, dynamic> data) {
    return Achievement(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      icon: data['icon'] as String,
      points: (data['points'] is int) ? data['points'] : (data['points']?.toInt() ?? 0),
      type: AchievementType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => AchievementType.streak,
      ),
      targetValue: data['target_value'] as int,
      isHidden: data['is_hidden'] ?? false,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'points': points,
      'type': type.toString().split('.').last,
      'target_value': targetValue,
      'is_hidden': isHidden,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum AchievementType {
  streak,
  accuracy,
  completion,
  speed,
  social,
}

class UserAchievement {
  final String id;
  final String userId;
  final String achievementId;
  final int progress;
  final bool unlocked;
  final DateTime? unlockedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.progress,
    required this.unlocked,
    this.unlockedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'],
      userId: json['user_id'],
      achievementId: json['achievement_id'],
      progress: json['progress'],
      unlocked: json['unlocked'],
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  factory UserAchievement.fromSupabase(Map<String, dynamic> data) {
    return UserAchievement(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      achievementId: data['achievement_id'] as String,
      progress: data['progress'] as int,
      unlocked: data['unlocked'] ?? false,
      unlockedAt: data['unlocked_at'] != null
          ? DateTime.parse(data['unlocked_at'] as String)
          : null,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'achievement_id': achievementId,
      'progress': progress,
      'unlocked': unlocked,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}