class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeTier tier;
  final BadgeCategory category;
  final int targetValue;
  final bool isHidden;
  final DateTime createdAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.tier,
    required this.category,
    required this.targetValue,
    this.isHidden = false,
    required this.createdAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      tier: BadgeTier.values.firstWhere(
        (e) => e.toString().split('.').last == json['tier'],
        orElse: () => BadgeTier.bronze,
      ),
      category: BadgeCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => BadgeCategory.learning,
      ),
      targetValue: json['target_value'],
      isHidden: json['is_hidden'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'tier': tier.toString().split('.').last,
      'category': category.toString().split('.').last,
      'target_value': targetValue,
      'is_hidden': isHidden,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum BadgeTier {
  bronze,
  silver,
  gold,
  platinum,
}

enum BadgeCategory {
  learning,
  accuracy,
  consistency,
  speed,
  social,
  mastery,
}

class UserBadge {
  final String id;
  final String userId;
  final String badgeId;
  final int progress;
  final bool unlocked;
  final DateTime? unlockedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserBadge({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.progress,
    required this.unlocked,
    this.unlockedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['id'],
      userId: json['user_id'],
      badgeId: json['badge_id'],
      progress: json['progress'],
      unlocked: json['unlocked'],
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'badge_id': badgeId,
      'progress': progress,
      'unlocked': unlocked,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}