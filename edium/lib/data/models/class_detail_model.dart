import 'package:edium/domain/entities/class_detail.dart';

part 'class_detail_model_course_summary_model.dart';
part 'class_detail_model_class_detail_model.dart';


class MemberShortModel {
  final String id;
  final String name;
  final String surname;

  const MemberShortModel({
    required this.id,
    required this.name,
    this.surname = '',
  });

  factory MemberShortModel.fromJson(Map<String, dynamic> json) {
    return MemberShortModel(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String? ?? '',
    );
  }

  MemberShort toEntity() {
    return MemberShort(id: id, name: name, surname: surname);
  }
}

