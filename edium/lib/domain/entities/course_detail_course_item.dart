part of 'course_detail.dart';

class CourseItem {
  final String id;
  final String refId;
  final String type;
  final int orderIndex;
  final String? attemptId;
  final double? score;
  final CourseItemPayload? payload;


  final String? title;
  final String? quizType;
  final String? state;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool needEvaluation;
  final String? quizTemplateId;

  const CourseItem({
    required this.id,
    required this.refId,
    required this.type,
    required this.orderIndex,
    this.attemptId,
    this.score,
    this.payload,
    this.title,
    this.quizType,
    this.state,
    this.startTime,
    this.endTime,
    this.needEvaluation = false,
    this.quizTemplateId,
  });

  bool get isPassed => score != null;
  bool get isTestQuiz => quizType == 'test';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CourseItem(id: $id, refId: $refId, quizTemplateId: $quizTemplateId, score: $score)';
}

