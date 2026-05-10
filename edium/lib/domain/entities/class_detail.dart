
part 'class_detail_course_summary.dart';
part 'class_detail_class_detail.dart';

class MemberShort {
  final String id;
  final String name;
  final String surname;

  const MemberShort({
    required this.id,
    required this.name,
    required this.surname,
  });

  String get fullName => '$name $surname'.trim();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberShort &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MemberShort(id: $id, name: $name, surname: $surname)';
}

