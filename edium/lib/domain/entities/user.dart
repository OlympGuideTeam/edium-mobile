enum UserRole { teacher, student }

class User {
  final String id;
  final String name;
  final String? surname;
  final String phone;
  final UserRole? role;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    this.surname,
    required this.phone,
    this.role,
    this.avatarUrl,
  });

  User copyWith({
    String? id,
    String? name,
    String? surname,
    String? phone,
    UserRole? role,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, name: $name, surname: $surname, role: $role)';
}
