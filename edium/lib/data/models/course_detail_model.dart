import 'package:edium/domain/entities/course_detail.dart';

part 'course_detail_model_course_item_payload_model.dart';
part 'course_detail_model_course_item_model.dart';
part 'course_detail_model_module_detail_model.dart';
part 'course_detail_model_course_detail_model.dart';
part 'course_detail_model_sheet_score_model.dart';
part 'course_detail_model_sheet_row_model.dart';
part 'course_detail_model_sheet_column_model.dart';
part 'course_detail_model_course_sheet_model.dart';


class CourseDraftModel {
  final String id;
  final String quizTemplateId;
  final CourseItemPayloadModel? payload;

  const CourseDraftModel({
    required this.id,
    required this.quizTemplateId,
    this.payload,
  });

  factory CourseDraftModel.fromJson(Map<String, dynamic> json) {
    final payloadJson = json['payload'] as Map<String, dynamic>?;
    return CourseDraftModel(
      id: json['id'] as String,
      quizTemplateId: json['quiz_template_id'] as String,
      payload: payloadJson != null
          ? CourseItemPayloadModel.fromJson(payloadJson)
          : null,
    );
  }

  CourseDraft toEntity() => CourseDraft(
        id: id,
        quizTemplateId: quizTemplateId,
        payload: payload?.toEntity(),
      );
}

