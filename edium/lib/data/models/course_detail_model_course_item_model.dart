part of 'course_detail_model.dart';

class CourseItemModel {
  final String id;
  final String refId;
  final String type;
  final int orderIndex;
  final String? attemptId;
  final double? score;
  final String? title;
  final String? quizType;
  final String? state;
  final String? startTime;
  final String? endTime;
  final bool needEvaluation;
  final String? quizTemplateId;
  final CourseItemPayloadModel? payload;

  const CourseItemModel({
    required this.id,
    required this.refId,
    required this.type,
    required this.orderIndex,
    this.attemptId,
    this.score,
    this.title,
    this.quizType,
    this.state,
    this.startTime,
    this.endTime,
    this.needEvaluation = false,
    this.quizTemplateId,
    this.payload,
  });

  factory CourseItemModel.fromJson(Map<String, dynamic> json,
      {int orderIndex = 0}) {
    final payloadJson = json['payload'] as Map<String, dynamic>?;
    final parsedPayload = payloadJson != null
        ? CourseItemPayloadModel.fromJson(payloadJson)
        : null;
    return CourseItemModel(
      id: json['id'] as String,
      refId: json['object_id'] as String,
      type: json['type'] as String,
      orderIndex: (json['order_index'] as int?) ?? orderIndex,
      attemptId: json['attempt_id'] as String?,
      score: (json['score'] as num?)?.toDouble(),
      title: (json['title'] as String?) ?? parsedPayload?.title,
      quizType: (json['quiz_type'] as String?) ?? parsedPayload?.mode,
      state: json['state'] as String?,
      startTime: (json['start_time'] as String?) ?? payloadJson?['started_at'] as String?,
      endTime: (json['end_time'] as String?) ?? payloadJson?['finished_at'] as String?,
      needEvaluation: (json['need_evaluation'] as bool?) ?? false,
      quizTemplateId: json['quiz_template_id'] as String?,
      payload: parsedPayload,
    );
  }

  CourseItem toEntity() {
    return CourseItem(
      id: id,
      refId: refId,
      type: type,
      orderIndex: orderIndex,
      attemptId: attemptId,
      score: score,
      title: title,
      quizType: quizType,
      state: state,
      startTime: startTime != null ? DateTime.tryParse(startTime!) : null,
      endTime: endTime != null ? DateTime.tryParse(endTime!) : null,
      needEvaluation: needEvaluation,
      quizTemplateId: quizTemplateId,
      payload: payload?.toEntity(),
    );
  }
}

