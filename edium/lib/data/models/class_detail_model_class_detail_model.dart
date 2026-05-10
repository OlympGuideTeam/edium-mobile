part of 'class_detail_model.dart';

class ClassDetailModel {
  final String id;
  final String title;
  final String ownerName;
  final bool isOwner;
  final List<MemberShortModel> students;
  final List<CourseSummaryModel> courses;
  final List<MemberShortModel> teachers;

  const ClassDetailModel({
    required this.id,
    required this.title,
    required this.ownerName,
    required this.isOwner,
    required this.students,
    required this.courses,
    required this.teachers,
  });

  factory ClassDetailModel.fromJson(Map<String, dynamic> json) {
    return ClassDetailModel(
      id: json['id'] as String,
      title: json['title'] as String,
      ownerName: json['owner_name'] as String,
      isOwner: json['is_owner'] as bool,
      students: (json['students'] as List<dynamic>? ?? [])
          .map((e) => MemberShortModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      courses: (json['courses'] as List<dynamic>? ?? [])
          .map((e) => CourseSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      teachers: (json['teachers'] as List<dynamic>? ?? [])
          .map((e) => MemberShortModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ClassDetail toEntity() {
    return ClassDetail(
      id: id,
      title: title,
      ownerName: ownerName,
      isOwner: isOwner,
      students: students.map((m) => m.toEntity()).toList(),
      courses: courses.map((c) => c.toEntity()).toList(),
      teachers: teachers.map((m) => m.toEntity()).toList(),
    );
  }
}

