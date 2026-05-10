part of 'course_detail.dart';

class CourseDraft {
  final String id;
  final String quizTemplateId;
  final CourseItemPayload? payload;

  const CourseDraft({
    required this.id,
    required this.quizTemplateId,
    this.payload,
  });

  String get title => payload?.title ?? '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseDraft && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

