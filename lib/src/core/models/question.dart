class Question {
  final String id;
  final String category;
  final int learnerCode;
  final String questionText;
  final List<QuestionOption> options;
  final int correctIndex;
  final String explanation;
  final int version;
  final bool isActive;
  final int difficultyLevel;
  final String? imageUrl;
  final String? videoUrl;
  final String? audioUrl;
  final Map<String, String>? localizedTexts;
  final DateTime createdAt;
  final DateTime updatedAt;

  Question({
    required this.id,
    required this.category,
    required this.learnerCode,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.version,
    required this.isActive,
    this.difficultyLevel = 2,
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
    this.localizedTexts,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper method to create from Supabase response
  factory Question.fromSupabase(Map<String, dynamic> data) {
    final optionsJson = data['options'] as List<dynamic>;
    final options = optionsJson.map((option) {
      if (option is Map<String, dynamic>) {
        return QuestionOption.fromJson(option);
      }
      return QuestionOption(text: option.toString());
    }).toList();

    // Parse localized texts if available
    Map<String, String>? localizedTexts;
    if (data['localized_texts'] != null) {
      localizedTexts = Map<String, String>.from(data['localized_texts'] as Map);
    }

    return Question(
      id: data['id'] as String,
      category: data['category'] as String,
      learnerCode: data['learner_code'] as int,
      questionText: data['question_text'] as String,
      options: options,
      correctIndex: data['correct_index'] as int,
      explanation: data['explanation'] as String,
      version: data['version'] as int? ?? 1,
      isActive: data['is_active'] as bool? ?? true,
      difficultyLevel: data['difficulty_level'] as int? ?? 2,
      imageUrl: data['image_url'] as String?,
      videoUrl: data['video_url'] as String?,
      audioUrl: data['audio_url'] as String?,
      localizedTexts: localizedTexts,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  // Check if answer is correct
  bool isAnswerCorrect(int chosenIndex) {
    return chosenIndex == correctIndex;
  }

  // Get correct option
  QuestionOption get correctOption {
    return options[correctIndex];
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'learner_code': learnerCode,
      'question_text': questionText,
      'options': options.map((option) => option.toJson()).toList(),
      'correct_index': correctIndex,
      'explanation': explanation,
      'version': version,
      'is_active': isActive,
      'difficulty_level': difficultyLevel,
      if (imageUrl != null) 'image_url': imageUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (localizedTexts != null) 'localized_texts': localizedTexts,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Question(id: $id, category: $category, learnerCode: $learnerCode, questionText: $questionText)';
  }
}

class QuestionOption {
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final Map<String, String>? localizedTexts;

  QuestionOption({
    required this.text,
    this.imageUrl,
    this.audioUrl,
    this.localizedTexts,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    Map<String, String>? localizedTexts;
    if (json['localizedTexts'] != null) {
      localizedTexts = Map<String, String>.from(json['localizedTexts'] as Map);
    }

    return QuestionOption(
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      localizedTexts: localizedTexts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (localizedTexts != null) 'localizedTexts': localizedTexts,
    };
  }

  @override
  String toString() {
    return text;
  }
}