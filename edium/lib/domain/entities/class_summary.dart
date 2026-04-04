class ClassSummary {
  final String id;
  final String title;
  final String ownerName;
  final int studentCount;
  final bool isOwner;

  const ClassSummary({
    required this.id,
    required this.title,
    required this.ownerName,
    required this.studentCount,
    required this.isOwner,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassSummary &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ClassSummary(id: $id, title: $title)';
}
