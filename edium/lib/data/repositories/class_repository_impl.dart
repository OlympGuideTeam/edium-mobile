import 'package:edium/data/datasources/class/class_datasource.dart';
import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/domain/entities/class_summary.dart';
import 'package:edium/domain/repositories/class_repository.dart';

class ClassRepositoryImpl implements IClassRepository {
  final IClassDatasource _datasource;

  ClassRepositoryImpl(this._datasource);

  @override
  Future<String> createClass({required String title}) {
    return _datasource.createClass(title: title);
  }

  @override
  Future<List<ClassSummary>> getMyClasses({required String role}) async {
    final models = await _datasource.getMyClasses(role: role);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ClassDetail> getClassDetail({required String classId}) async {
    final model = await _datasource.getClassDetail(classId: classId);
    return model.toEntity();
  }

  @override
  Future<void> updateClass({
    required String classId,
    required String title,
  }) {
    return _datasource.updateClass(classId: classId, title: title);
  }

  @override
  Future<void> deleteClass({required String classId}) {
    return _datasource.deleteClass(classId: classId);
  }

  @override
  Future<void> removeMember({
    required String classId,
    required String userId,
  }) {
    return _datasource.removeMember(classId: classId, userId: userId);
  }

  @override
  Future<String> getInviteLink({
    required String classId,
    required String role,
  }) {
    return _datasource.getInviteLink(classId: classId, role: role);
  }

  @override
  Future<void> deleteCourse({required String courseId}) {
    return _datasource.deleteCourse(courseId: courseId);
  }
}
