class MemberShort {
  final String id;
  final String name;

  const MemberShort({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberShort &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MemberShort(id: $id, name: $name)';
}

class CourseSummary {
  final String id;
  final String title;
  final String teacherName;
  final int moduleCount;
  final int quizCount;
  final bool isTeacher;

  const CourseSummary({
    required this.id,
    required this.title,
    required this.teacherName,
    required this.moduleCount,
    required this.quizCount,
    required this.isTeacher,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseSummary &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CourseSummary(id: $id, title: $title)';
}

class ClassDetail {
  final String id;
  final String title;
  final String ownerName;
  final bool isOwner;
  final List<MemberShort> students;
  final List<CourseSummary> courses;
  final List<MemberShort> teachers;

  const ClassDetail({
    required this.id,
    required this.title,
    required this.ownerName,
    required this.isOwner,
    required this.students,
    required this.courses,
    required this.teachers,
  });

  int get studentCount => students.length;

  ClassDetail copyWith({
    String? title,
    List<MemberShort>? students,
    List<CourseSummary>? courses,
  }) {
    return ClassDetail(
      id: id,
      title: title ?? this.title,
      ownerName: ownerName,
      isOwner: isOwner,
      students: students ?? this.students,
      courses: courses ?? this.courses,
      teachers: teachers,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassDetail &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ClassDetail(id: $id, title: $title)';
}
