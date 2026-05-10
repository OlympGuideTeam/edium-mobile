part of 'course_detail.dart';

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

