part of 'course_detail.dart';

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

