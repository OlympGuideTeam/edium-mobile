part of 'course_detail_model.dart';

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

