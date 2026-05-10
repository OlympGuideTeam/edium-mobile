part of 'course_detail.dart';

class SheetColumn {
  final String id;
  final String objectId;

  final String? title;

  const SheetColumn({
    required this.id,
    required this.objectId,
    this.title,
  });
}

