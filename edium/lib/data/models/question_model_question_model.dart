part of 'question_model.dart';

class QuestionModel {
  final String id;
  final String text;
  final String type;
  final List<AnswerOptionModel> options;
  final String? explanation;
  final String? correctAnswer;
  final int orderIndex;
  final Map<String, dynamic>? metadata;
  final int? maxScore;
  final String? imageId;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    this.explanation,
    this.correctAnswer,
    required this.orderIndex,
    this.metadata,
    this.maxScore,
    this.imageId,
  });


  static Map<String, dynamic> normalizeTeacherQuestionPayload(
    Map<String, dynamic> raw,
  ) {
    final m = Map<String, dynamic>.from(raw);
    final opts = m['answer_options'];
    if (opts is List &&
        (m['options'] == null ||
            (m['options'] is List && (m['options'] as List).isEmpty))) {
      var i = 0;
      m['options'] = opts.map((o) {
        final om = o as Map<String, dynamic>;
        return {
          'id': om['id'] as String? ??
              'gen_${DateTime.now().microsecondsSinceEpoch}_${i++}',
          'text': om['text'],
          'is_correct': om['is_correct'] ?? false,
        };
      }).toList();
    }
    if (m['type'] == 'multiple_choice') {
      m['type'] = 'multi_choice';
    }
    return m;
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final metaRaw = json['metadata'];
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      type: json['type'] as String,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => AnswerOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      explanation: json['explanation'] as String?,
      correctAnswer: json['correct_answer'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      metadata: metaRaw is Map<String, dynamic>
          ? Map<String, dynamic>.from(metaRaw)
          : null,
      maxScore: json['max_score'] as int?,
      imageId: json['image_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type,
        'options': options.map((e) => e.toJson()).toList(),
        if (explanation != null) 'explanation': explanation,
        if (correctAnswer != null) 'correct_answer': correctAnswer,
        'order_index': orderIndex,
        if (metadata != null) 'metadata': metadata,
        if (maxScore != null) 'max_score': maxScore,
        if (imageId != null) 'image_id': imageId,
      };

  Question toEntity() {
    QuestionType qType;
    switch (type) {
      case 'multi_choice':
      case 'multiple_choice':
        qType = QuestionType.multiChoice;
        break;
      case 'with_free_answer':
        qType = QuestionType.withFreeAnswer;
        break;
      case 'with_given_answer':
        qType = QuestionType.withGivenAnswer;
        break;
      case 'drag':
        qType = QuestionType.drag;
        break;
      case 'connection':
        qType = QuestionType.connection;
        break;
      default:
        qType = QuestionType.singleChoice;
    }
    return Question(
      id: id,
      text: text,
      type: qType,
      options: options.map((e) => e.toEntity()).toList(),
      explanation: explanation,
      orderIndex: orderIndex,
      metadata: metadata != null ? Map<String, dynamic>.from(metadata!) : null,
      maxScore: maxScore,
      imageId: imageId,
    );
  }

  factory QuestionModel.fromEntity(Question q) {
    String typeStr;
    switch (q.type) {
      case QuestionType.multiChoice:
        typeStr = 'multiple_choice';
        break;
      case QuestionType.withFreeAnswer:
        typeStr = 'with_free_answer';
        break;
      case QuestionType.withGivenAnswer:
        typeStr = 'with_given_answer';
        break;
      case QuestionType.drag:
        typeStr = 'drag';
        break;
      case QuestionType.connection:
        typeStr = 'connection';
        break;
      case QuestionType.singleChoice:
        typeStr = 'single_choice';
    }
    return QuestionModel(
      id: q.id,
      text: q.text,
      type: typeStr,
      options: q.options.map(AnswerOptionModel.fromEntity).toList(),
      explanation: q.explanation,
      orderIndex: q.orderIndex,
      metadata: q.metadata != null ? Map<String, dynamic>.from(q.metadata!) : null,
      maxScore: q.maxScore,
      imageId: q.imageId,
    );
  }
}

