import 'package:edium/domain/entities/question.dart';

class AnswerOptionModel {
  final String id;
  final String text;
  final bool isCorrect;

  const AnswerOptionModel({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory AnswerOptionModel.fromJson(Map<String, dynamic> json) {
    return AnswerOptionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'is_correct': isCorrect,
      };

  AnswerOption toEntity() =>
      AnswerOption(id: id, text: text, isCorrect: isCorrect);

  factory AnswerOptionModel.fromEntity(AnswerOption e) =>
      AnswerOptionModel(id: e.id, text: e.text, isCorrect: e.isCorrect);
}

class QuestionModel {
  final String id;
  final String text;
  final String type;
  final List<AnswerOptionModel> options;
  final String? explanation;
  final String? correctAnswer; // for text_input type
  final int orderIndex;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    this.explanation,
    this.correctAnswer,
    required this.orderIndex,
  });

  /// Teacher create flow uses [answer_options]; stored quizzes use [options].
  /// Normalizes to a shape [fromJson] accepts.
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
      };

  Question toEntity() {
    QuestionType qType;
    switch (type) {
      case 'multi_choice':
      case 'multiple_choice':
        qType = QuestionType.multiChoice;
        break;
      case 'text_input':
        qType = QuestionType.textInput;
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
    );
  }

  factory QuestionModel.fromEntity(Question q) {
    String typeStr;
    switch (q.type) {
      case QuestionType.multiChoice:
        typeStr = 'multi_choice';
        break;
      case QuestionType.textInput:
        typeStr = 'text_input';
        break;
      default:
        typeStr = 'single_choice';
    }
    return QuestionModel(
      id: q.id,
      text: q.text,
      type: typeStr,
      options: q.options.map(AnswerOptionModel.fromEntity).toList(),
      explanation: q.explanation,
      orderIndex: q.orderIndex,
    );
  }
}
