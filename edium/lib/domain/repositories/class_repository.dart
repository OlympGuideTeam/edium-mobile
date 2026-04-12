import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/domain/entities/class_summary.dart';

abstract class IClassRepository {
  Future<List<ClassSummary>> getMyClasses({required String role});
  Future<String> createClass({required String title});
  Future<ClassDetail> getClassDetail({required String classId});
  Future<void> updateClass({required String classId, required String title});
  Future<void> deleteClass({required String classId});
  Future<void> removeMember({required String classId, required String userId});
  Future<String> getInviteLink({required String classId, required String role});
  Future<void> deleteCourse({required String courseId});
}
