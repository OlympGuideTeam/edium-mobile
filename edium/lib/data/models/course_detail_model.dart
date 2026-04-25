import 'package:edium/domain/entities/course_detail.dart';

class CourseDraftModel {
  final String id;
  final String quizTemplateId;
  final CourseItemPayloadModel? payload;

  const CourseDraftModel({
    required this.id,
    required this.quizTemplateId,
    this.payload,
  });

  factory CourseDraftModel.fromJson(Map<String, dynamic> json) {
    final payloadJson = json['payload'] as Map<String, dynamic>?;
    return CourseDraftModel(
      id: json['id'] as String,
      quizTemplateId: json['quiz_template_id'] as String,
      payload: payloadJson != null
          ? CourseItemPayloadModel.fromJson(payloadJson)
          : null,
    );
  }

  CourseDraft toEntity() => CourseDraft(
        id: id,
        quizTemplateId: quizTemplateId,
        payload: payload?.toEntity(),
      );
}

class CourseItemPayloadModel {
  final String? title;
  final String mode;
  final int? totalTimeLimitSec;
  final int? questionTimeLimitSec;
  final bool? shuffleQuestions;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  const CourseItemPayloadModel({
    this.title,
    required this.mode,
    this.totalTimeLimitSec,
    this.questionTimeLimitSec,
    this.shuffleQuestions,
    this.startedAt,
    this.finishedAt,
  });

  factory CourseItemPayloadModel.fromJson(Map<String, dynamic> json) {
    return CourseItemPayloadModel(
      title: json['title'] as String?,
      mode: json['mode'] as String? ?? 'test',
      totalTimeLimitSec: json['total_time_limit_sec'] as int?,
      questionTimeLimitSec: json['question_time_limit_sec'] as int?,
      shuffleQuestions: json['shuffle_questions'] as bool?,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'] as String)
          : null,
      finishedAt: json['finished_at'] != null
          ? DateTime.tryParse(json['finished_at'] as String)
          : null,
    );
  }

  CourseItemPayload toEntity() => CourseItemPayload(
        title: title,
        mode: mode,
        totalTimeLimitSec: totalTimeLimitSec,
        questionTimeLimitSec: questionTimeLimitSec,
        shuffleQuestions: shuffleQuestions,
        startedAt: startedAt,
        finishedAt: finishedAt,
      );
}

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
  });

  factory CourseItemModel.fromJson(Map<String, dynamic> json,
      {int orderIndex = 0}) {
    final payloadJson = json['payload'] as Map<String, dynamic>?;
    return CourseItemModel(
      id: json['id'] as String,
      refId: json['object_id'] as String,
      type: json['type'] as String,
      orderIndex: (json['order_index'] as int?) ?? orderIndex,
      attemptId: json['attempt_id'] as String?,
      score: (json['score'] as num?)?.toDouble(),
      title: (json['title'] as String?) ?? payloadJson?['title'] as String?,
      quizType: (json['quiz_type'] as String?) ?? payloadJson?['mode'] as String?,
      state: json['state'] as String?,
      startTime: (json['start_time'] as String?) ?? payloadJson?['started_at'] as String?,
      endTime: (json['end_time'] as String?) ?? payloadJson?['finished_at'] as String?,
      needEvaluation: (json['need_evaluation'] as bool?) ?? false,
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
    );
  }
}

class ModuleDetailModel {
  final String id;
  final String title;
  final int elementCount;
  final List<CourseItemModel> items;

  const ModuleDetailModel({
    required this.id,
    required this.title,
    required this.elementCount,
    required this.items,
  });

  factory ModuleDetailModel.fromJson(Map<String, dynamic> json) {
    return ModuleDetailModel(
      id: json['id'] as String,
      title: json['title'] as String,
      elementCount: json['element_count'] as int,
      items: (json['items'] as List<dynamic>? ?? [])
          .asMap()
          .entries
          .map((e) => CourseItemModel.fromJson(
                e.value as Map<String, dynamic>,
                orderIndex: e.key,
              ))
          .toList(),
    );
  }

  ModuleDetail toEntity() {
    return ModuleDetail(
      id: id,
      title: title,
      elementCount: elementCount,
      items: items.map((i) => i.toEntity()).toList(),
    );
  }
}

class CourseDetailModel {
  final String id;
  final String title;
  final String teacherName;
  final int moduleCount;
  final int elementCount;
  final bool isTeacher;
  final List<ModuleDetailModel> modules;
  final List<CourseDraftModel> drafts;

  const CourseDetailModel({
    required this.id,
    required this.title,
    required this.teacherName,
    required this.moduleCount,
    required this.elementCount,
    required this.isTeacher,
    required this.modules,
    this.drafts = const [],
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailModel(
      id: json['id'] as String,
      title: json['title'] as String,
      teacherName: json['teacher_name'] as String,
      moduleCount: json['module_count'] as int,
      elementCount: json['element_count'] as int,
      isTeacher: json['is_teacher'] as bool,
      modules: (json['modules'] as List<dynamic>? ?? [])
          .map((e) => ModuleDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      drafts: (json['drafts'] as List<dynamic>? ?? [])
          .map((e) => CourseDraftModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  CourseDetail toEntity() {
    return CourseDetail(
      id: id,
      title: title,
      teacherName: teacherName,
      moduleCount: moduleCount,
      elementCount: elementCount,
      isTeacher: isTeacher,
      modules: modules.map((m) => m.toEntity()).toList(),
      drafts: drafts.map((d) => d.toEntity()).toList(),
    );
  }
}

class SheetScoreModel {
  final String itemId;
  final double? score;

  const SheetScoreModel({required this.itemId, this.score});

  factory SheetScoreModel.fromJson(Map<String, dynamic> json) => SheetScoreModel(
        itemId: json['item_id'] as String,
        score: (json['score'] as num?)?.toDouble(),
      );

  SheetScore toEntity() => SheetScore(itemId: itemId, score: score);
}

class SheetRowModel {
  final String studentId;
  final String studentName;
  final List<SheetScoreModel> scores;

  const SheetRowModel({
    required this.studentId,
    required this.studentName,
    required this.scores,
  });

  factory SheetRowModel.fromJson(Map<String, dynamic> json) => SheetRowModel(
        studentId: json['student_id'] as String,
        studentName: json['student_name'] as String,
        scores: (json['scores'] as List<dynamic>)
            .map((e) => SheetScoreModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  SheetRow toEntity() => SheetRow(
        studentId: studentId,
        studentName: studentName,
        scores: scores.map((s) => s.toEntity()).toList(),
      );
}

class SheetColumnModel {
  final String id;
  final String objectId;

  const SheetColumnModel({required this.id, required this.objectId});

  factory SheetColumnModel.fromJson(Map<String, dynamic> json) =>
      SheetColumnModel(
        id: json['id'] as String,
        objectId: json['object_id'] as String,
      );

  SheetColumn toEntity() => SheetColumn(id: id, objectId: objectId);
}

class CourseSheetModel {
  final List<SheetColumnModel> columns;
  final List<SheetRowModel> rows;

  const CourseSheetModel({required this.columns, required this.rows});

  factory CourseSheetModel.fromJson(Map<String, dynamic> json) =>
      CourseSheetModel(
        columns: (json['items'] as List<dynamic>)
            .map((e) => SheetColumnModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        rows: (json['students'] as List<dynamic>)
            .map((e) => SheetRowModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  CourseSheet toEntity() => CourseSheet(
        columns: columns.map((c) => c.toEntity()).toList(),
        rows: rows.map((r) => r.toEntity()).toList(),
      );
}
