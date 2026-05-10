part of 'course_detail_model.dart';

class ModuleDetailModel {
  final String id;
  final String title;
  final int elementCount;
  final List<CourseItemModel> items;

  const ModuleDetailModel({
    required this.id,
    required this.title,
    required this.elementCount,
    required this.items,
  });

  factory ModuleDetailModel.fromJson(Map<String, dynamic> json) {
    return ModuleDetailModel(
      id: json['id'] as String,
      title: json['title'] as String,
      elementCount: json['element_count'] as int,
      items: (json['items'] as List<dynamic>? ?? [])
          .asMap()
          .entries
          .map((e) => CourseItemModel.fromJson(
                e.value as Map<String, dynamic>,
                orderIndex: e.key,
              ))
          .toList(),
    );
  }

  ModuleDetail toEntity() {
    return ModuleDetail(
      id: id,
      title: title,
      elementCount: elementCount,
      items: items.map((i) => i.toEntity()).toList(),
    );
  }
}

