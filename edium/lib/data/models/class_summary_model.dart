import 'package:edium/domain/entities/class_summary.dart';

class ClassSummaryModel {
  final String id;
  final String title;
  final String ownerName;
  final int studentCount;
  final bool isOwner;

  const ClassSummaryModel({
    required this.id,
    required this.title,
    required this.ownerName,
    required this.studentCount,
    required this.isOwner,
  });

  factory ClassSummaryModel.fromJson(Map<String, dynamic> json) {
    return ClassSummaryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      ownerName: json['owner_name'] as String,
      studentCount: json['student_count'] as int,
      isOwner: json['is_owner'] as bool,
    );
  }

  ClassSummary toEntity() {
    return ClassSummary(
      id: id,
      title: title,
      ownerName: ownerName,
      studentCount: studentCount,
      isOwner: isOwner,
    );
  }
}
