
part 'course_detail_course_item.dart';
part 'course_detail_module_detail.dart';
part 'course_detail_course_draft.dart';
part 'course_detail_course_detail.dart';
part 'course_detail_sheet_score.dart';
part 'course_detail_sheet_row.dart';
part 'course_detail_sheet_column.dart';
part 'course_detail_course_sheet.dart';

class CourseItemPayload {
  final String? title;
  final String mode;
  final int? totalTimeLimitSec;
  final int? questionTimeLimitSec;
  final bool? shuffleQuestions;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  const CourseItemPayload({
    this.title,
    required this.mode,
    this.totalTimeLimitSec,
    this.questionTimeLimitSec,
    this.shuffleQuestions,
    this.startedAt,
    this.finishedAt,
  });
}

