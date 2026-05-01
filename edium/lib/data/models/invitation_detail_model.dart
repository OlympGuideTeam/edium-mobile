import 'package:edium/domain/entities/invitation_detail.dart';

class InvitationDetailModel {
  final String classTitle;
  final int studentCount;
  final String role;

  const InvitationDetailModel({
    required this.classTitle,
    required this.studentCount,
    required this.role,
  });

  factory InvitationDetailModel.fromJson(Map<String, dynamic> json) {
    return InvitationDetailModel(
      classTitle: json['class_title'] as String,
      studentCount: json['class_student_count'] as int,
      role: json['role'] as String,
    );
  }

  InvitationDetail toEntity() {
    return InvitationDetail(
      classTitle: classTitle,
      studentCount: studentCount,
      role: role,
    );
  }
}
