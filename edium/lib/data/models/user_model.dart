import 'package:edium/domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final String? surname;
  final String phone;
  final String? role;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    this.surname,
    required this.phone,
    this.role,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String?,
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (surname != null) 'surname': surname,
        'phone': phone,
        if (role != null) 'role': role,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

  User toEntity() {
    UserRole? userRole;
    if (role == 'teacher') userRole = UserRole.teacher;
    if (role == 'student') userRole = UserRole.student;
    return User(
      id: id,
      name: name,
      surname: surname,
      phone: phone,
      role: userRole,
      avatarUrl: avatarUrl,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      surname: user.surname,
      phone: user.phone,
      role: user.role?.name,
      avatarUrl: user.avatarUrl,
    );
  }
}
