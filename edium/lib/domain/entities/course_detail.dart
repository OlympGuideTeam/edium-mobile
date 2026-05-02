class CourseItemPayload {
  final String? title;
  final String mode; // test | live
  final int? totalTimeLimitSec;
  final int? questionTimeLimitSec;
  final bool? shuffleQuestions;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  const CourseItemPayload({
    this.title,
    required this.mode,
    this.totalTimeLimitSec,
    this.questionTimeLimitSec,
    this.shuffleQuestions,
    this.startedAt,
    this.finishedAt,
  });
}

class CourseItem {
  final String id;
  final String refId;
  final String type;
  final int orderIndex;
  final String? attemptId;
  final double? score;
  final CourseItemPayload? payload;

  // Новые поля из Caesar `QuizShort`:
  final String? title;
  final String? quizType;        // 'test' | 'live'
  final String? state;           // для async: 'not_started' | 'in_progress' | 'completed'
  final DateTime? startTime;
  final DateTime? endTime;
  final bool needEvaluation;
  final String? quizTemplateId;  // ID шаблона квиза в Riddler (≠ session ID)

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

class ModuleDetail {
  final String id;
  final String title;
  final int elementCount;
  final List<CourseItem> items;

  const ModuleDetail({
    required this.id,
    required this.title,
    required this.elementCount,
    required this.items,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModuleDetail &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ModuleDetail(id: $id, title: $title)';
}

class CourseDraft {
  final String id;
  final String quizTemplateId;
  final CourseItemPayload? payload;

  const CourseDraft({
    required this.id,
    required this.quizTemplateId,
    this.payload,
  });

  String get title => payload?.title ?? '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseDraft && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CourseDetail {
  final String id;
  final String title;
  final String teacherName;
  final int moduleCount;
  final int elementCount;
  final bool isTeacher;
  final List<ModuleDetail> modules;
  final List<CourseDraft> drafts;

  const CourseDetail({
    required this.id,
    required this.title,
    required this.teacherName,
    required this.moduleCount,
    required this.elementCount,
    required this.isTeacher,
    required this.modules,
    this.drafts = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseDetail &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CourseDetail(id: $id, title: $title)';

  CourseDetail copyWith({
    String? id,
    String? title,
    String? teacherName,
    int? moduleCount,
    int? elementCount,
    bool? isTeacher,
    List<ModuleDetail>? modules,
    List<CourseDraft>? drafts,
  }) {
    return CourseDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      teacherName: teacherName ?? this.teacherName,
      moduleCount: moduleCount ?? this.moduleCount,
      elementCount: elementCount ?? this.elementCount,
      isTeacher: isTeacher ?? this.isTeacher,
      modules: modules ?? this.modules,
      drafts: drafts ?? this.drafts,
    );
  }
}

class SheetScore {
  final String itemId;
  final double? score;

  const SheetScore({required this.itemId, this.score});
}

class SheetRow {
  final String studentId;
  final String studentName;
  final List<SheetScore> scores;

  const SheetRow({
    required this.studentId,
    required this.studentName,
    required this.scores,
  });
}

class SheetColumn {
  final String id;
  final String objectId;

  const SheetColumn({required this.id, required this.objectId});
}

class CourseSheet {
  final List<SheetColumn> columns;
  final List<SheetRow> rows;

  const CourseSheet({required this.columns, required this.rows});
}
