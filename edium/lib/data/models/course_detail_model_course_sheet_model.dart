part of 'course_detail_model.dart';

class CourseSheetModel {
  final List<SheetColumnModel> columns;
  final List<SheetRowModel> rows;

  const CourseSheetModel({required this.columns, required this.rows});

  factory CourseSheetModel.fromJson(Map<String, dynamic> json) =>
      CourseSheetModel(
        columns: (json['items'] as List<dynamic>? ?? [])
            .map((e) => SheetColumnModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        rows: (json['students'] as List<dynamic>? ?? [])
            .map((e) => SheetRowModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  CourseSheet toEntity() => CourseSheet(
        columns: columns.map((c) => c.toEntity()).toList(),
        rows: rows.map((r) => r.toEntity()).toList(),
      );
}

