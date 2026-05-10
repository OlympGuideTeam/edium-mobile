part of 'course_detail_model.dart';

class SheetColumnModel {
  final String id;
  final String objectId;
  final String? title;

  const SheetColumnModel({
    required this.id,
    required this.objectId,
    this.title,
  });

  factory SheetColumnModel.fromJson(Map<String, dynamic> json) =>
      SheetColumnModel(
        id: json['id'] as String,
        objectId: (json['ref_id'] ?? json['object_id']) as String,
        title: json['title'] as String?,
      );

  SheetColumn toEntity() =>
      SheetColumn(id: id, objectId: objectId, title: title);
}

