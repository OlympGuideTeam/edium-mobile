import 'package:edium/domain/entities/class_summary.dart';

abstract class IClassRepository {
  Future<List<ClassSummary>> getMyClasses({required String role});
  Future<String> createClass({required String title});
}
