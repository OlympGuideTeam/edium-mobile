import 'package:edium/data/models/class_summary_model.dart';

abstract class IClassDatasource {
  Future<List<ClassSummaryModel>> getMyClasses({required String role});
}
