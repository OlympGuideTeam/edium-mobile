part of 'class_detail_model.dart';

class CourseSummaryModel {
  final String id;
  final String title;
  final String teacherName;
  final int moduleCount;
  final int elementCount;
  final bool isTeacher;

  const CourseSummaryModel({
    required this.id,
    required this.title,
    required this.teacherName,
    required this.moduleCount,
    required this.elementCount,
    required this.isTeacher,
  });

  factory CourseSummaryModel.fromJson(Map<String, dynamic> json) {
    return CourseSummaryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      teacherName: json['teacher_name'] as String,
      moduleCount: json['module_count'] as int,
      elementCount: (json['element_count'] ?? 0) as int,
      isTeacher: json['is_teacher'] as bool,
    );
  }

  CourseSummary toEntity() {
    return CourseSummary(
      id: id,
      title: title,
      teacherName: teacherName,
      moduleCount: moduleCount,
      elementCount: elementCount,
      isTeacher: isTeacher,
    );
  }
}

