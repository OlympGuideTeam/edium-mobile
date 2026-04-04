import 'package:edium/data/datasources/class/class_datasource.dart';
import 'package:edium/domain/entities/class_summary.dart';
import 'package:edium/domain/repositories/class_repository.dart';

class ClassRepositoryImpl implements IClassRepository {
  final IClassDatasource _datasource;

  ClassRepositoryImpl(this._datasource);

  @override
  Future<List<ClassSummary>> getMyClasses({required String role}) async {
    final models = await _datasource.getMyClasses(role: role);
    return models.map((m) => m.toEntity()).toList();
  }
}
