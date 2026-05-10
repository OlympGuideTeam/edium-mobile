part of 'quiz_attempt_model.dart';

class QuizQuestionForStudentModel {
  final String id;
  final String type;
  final String text;
  final String? imageId;
  final int maxScore;
  final List<QuestionOptionForStudentModel>? options;
  final Map<String, dynamic>? metadata;

  const QuizQuestionForStudentModel({
    required this.id,
    required this.type,
    required this.text,
    this.imageId,
    required this.maxScore,
    this.options,
    this.metadata,
  });

  factory QuizQuestionForStudentModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionForStudentModel(
      id: json['id'] as String,
      type: json['type'] as String,
      text: json['text'] as String,
      imageId: json['image_id'] as String?,
      maxScore: json['max_score'] as int? ?? 10,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => QuestionOptionForStudentModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'text': text,
        if (imageId != null) 'image_id': imageId,
        'max_score': maxScore,
        if (options != null)
          'options': options!.map((e) => e.toJson()).toList(),
        if (metadata != null) 'metadata': metadata,
      };

  QuizQuestionForStudent toEntity() {
    final qType = _parseType(type);
    return QuizQuestionForStudent(
      id: id,
      type: qType,
      text: text,
      imageId: imageId,
      maxScore: maxScore,
      options: options?.map((e) => e.toEntity()).toList(),
      metadata: metadata,
    );
  }

  static QuizQuestionType _parseType(String t) {
    switch (t) {
      case 'multiple_choice':
        return QuizQuestionType.multipleChoice;
      case 'with_given_answer':
        return QuizQuestionType.withGivenAnswer;
      case 'with_free_answer':
        return QuizQuestionType.withFreeAnswer;
      case 'drag':
        return QuizQuestionType.drag;
      case 'connection':
        return QuizQuestionType.connection;
      default:
        return QuizQuestionType.singleChoice;
    }
  }
}

