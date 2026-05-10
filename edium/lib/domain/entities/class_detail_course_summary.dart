part of 'class_detail.dart';

class CourseSummary {
  final String id;
  final String title;
  final String teacherName;
  final int moduleCount;
  final int elementCount;
  final bool isTeacher;

  const CourseSummary({
    required this.id,
    required this.title,
    required this.teacherName,
    required this.moduleCount,
    required this.elementCount,
    required this.isTeacher,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseSummary &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CourseSummary(id: $id, title: $title, elementCount: $elementCount)';
}

