import 'package:edium/data/models/class_detail_model.dart';
import 'package:edium/data/models/class_summary_model.dart';

abstract class IClassDatasource {
  Future<List<ClassSummaryModel>> getMyClasses({required String role});
  Future<String> createClass({required String title});
  Future<ClassDetailModel> getClassDetail({required String classId});
  Future<void> updateClass({required String classId, required String title});
  Future<void> deleteClass({required String classId});
  Future<void> removeMember({required String classId, required String userId});
  Future<String> getInviteLink({required String classId, required String role});
  Future<void> deleteCourse({required String courseId});
}
