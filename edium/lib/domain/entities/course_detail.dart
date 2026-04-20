class CourseItem {
  final String id;
  final String refId;
  final String type;
  final int orderIndex;
  final String? attemptId;
  final double? score;

  const CourseItem({
    required this.id,
    required this.refId,
    required this.type,
    required this.orderIndex,
    this.attemptId,
    this.score,
  });

  bool get isPassed => score != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CourseItem(id: $id, refId: $refId, score: $score)';
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

  const CourseDraft({required this.id, required this.quizTemplateId});

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
}
