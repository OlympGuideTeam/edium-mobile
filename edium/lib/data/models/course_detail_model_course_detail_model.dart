part of 'course_detail_model.dart';

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

