enum UserRole {
  teacher('teacher'),
  student('student');

  final String rawValue;
  const UserRole(this.rawValue);
}