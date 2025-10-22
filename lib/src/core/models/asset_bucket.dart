import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class AssetBucket extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int assetCount;
  final Map<String, dynamic> metadata;

  const AssetBucket({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.assetCount = 0,
    this.metadata = const {},
  });

  factory AssetBucket.create({
    required String name,
    required String description,
    required String category,
    Map<String, dynamic> metadata = const {},
  }) {
    final now = DateTime.now();
    return AssetBucket(
      id: const Uuid().v4(),
      name: name,
      description: description,
      category: category,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }

  factory AssetBucket.fromJson(Map<String, dynamic> json) {
    return AssetBucket(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      assetCount: json['asset_count'] as int? ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'asset_count': assetCount,
      'metadata': metadata,
    };
  }

  AssetBucket copyWith({
    String? name,
    String? description,
    String? category,
    int? assetCount,
    Map<String, dynamic>? metadata,
  }) {
    return AssetBucket(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      assetCount: assetCount ?? this.assetCount,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        createdAt,
        updatedAt,
        assetCount,
        metadata,
      ];
}