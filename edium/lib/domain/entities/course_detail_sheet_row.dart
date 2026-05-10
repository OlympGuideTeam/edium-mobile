part of 'course_detail.dart';

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

