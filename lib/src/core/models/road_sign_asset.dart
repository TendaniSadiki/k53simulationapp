import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class RoadSignAsset extends Equatable {
  final String id;
  final String bucketId;
  final String fileName;
  final String filePath;
  final String fileFormat;
  final int fileSize;
  final int width;
  final int height;
  final DateTime uploadedAt;
  final DateTime? capturedAt;
  final String? location;
  final String? signType;
  final String? condition;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final bool isActive;

  const RoadSignAsset({
    required this.id,
    required this.bucketId,
    required this.fileName,
    required this.filePath,
    required this.fileFormat,
    required this.fileSize,
    required this.width,
    required this.height,
    required this.uploadedAt,
    this.capturedAt,
    this.location,
    this.signType,
    this.condition,
    this.tags = const [],
    this.metadata = const {},
    this.isActive = true,
  });

  factory RoadSignAsset.create({
    required String bucketId,
    required String fileName,
    required String filePath,
    required String fileFormat,
    required int fileSize,
    required int width,
    required int height,
    String? location,
    String? signType,
    String? condition,
    List<String> tags = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    return RoadSignAsset(
      id: const Uuid().v4(),
      bucketId: bucketId,
      fileName: fileName,
      filePath: filePath,
      fileFormat: fileFormat,
      fileSize: fileSize,
      width: width,
      height: height,
      uploadedAt: DateTime.now(),
      capturedAt: DateTime.now(),
      location: location,
      signType: signType,
      condition: condition,
      tags: tags,
      metadata: metadata,
    );
  }

  factory RoadSignAsset.fromJson(Map<String, dynamic> json) {
    return RoadSignAsset(
      id: json['id'] as String,
      bucketId: json['bucket_id'] as String,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      fileFormat: json['file_format'] as String,
      fileSize: json['file_size'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      capturedAt: json['captured_at'] != null 
          ? DateTime.parse(json['captured_at'] as String)
          : null,
      location: json['location'] as String?,
      signType: json['sign_type'] as String?,
      condition: json['condition'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bucket_id': bucketId,
      'file_name': fileName,
      'file_path': filePath,
      'file_format': fileFormat,
      'file_size': fileSize,
      'width': width,
      'height': height,
      'uploaded_at': uploadedAt.toIso8601String(),
      if (capturedAt != null) 'captured_at': capturedAt!.toIso8601String(),
      'location': location,
      'sign_type': signType,
      'condition': condition,
      'tags': tags,
      'metadata': metadata,
      'is_active': isActive,
    };
  }

  RoadSignAsset copyWith({
    String? fileName,
    String? filePath,
    String? fileFormat,
    int? fileSize,
    int? width,
    int? height,
    String? location,
    String? signType,
    String? condition,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    bool? isActive,
  }) {
    return RoadSignAsset(
      id: id,
      bucketId: bucketId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileFormat: fileFormat ?? this.fileFormat,
      fileSize: fileSize ?? this.fileSize,
      width: width ?? this.width,
      height: height ?? this.height,
      uploadedAt: uploadedAt,
      capturedAt: capturedAt,
      location: location ?? this.location,
      signType: signType ?? this.signType,
      condition: condition ?? this.condition,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper methods
  String get displayName => fileName.split('.').first;
  String get fileExtension => fileName.split('.').last.toLowerCase();
  double get aspectRatio => width / height;
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return fileName.toLowerCase().contains(lowerQuery) ||
        (location?.toLowerCase().contains(lowerQuery) ?? false) ||
        (signType?.toLowerCase().contains(lowerQuery) ?? false) ||
        tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  @override
  List<Object?> get props => [
        id,
        bucketId,
        fileName,
        filePath,
        fileFormat,
        fileSize,
        width,
        height,
        uploadedAt,
        capturedAt,
        location,
        signType,
        condition,
        tags,
        metadata,
        isActive,
      ];
}