import 'package:edium/data/datasources/class/class_datasource.dart';
import 'package:edium/data/models/class_summary_model.dart';

class ClassDatasourceMock implements IClassDatasource {
  @override
  Future<List<ClassSummaryModel>> getMyClasses({required String role}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (role == 'teacher') {
      return const [
        ClassSummaryModel(
          id: 'class-1',
          title: '7А — Математика',
          ownerName: 'Иван Петров',
          studentCount: 24,
          isOwner: true,
        ),
        ClassSummaryModel(
          id: 'class-2',
          title: '8Б — Физика',
          ownerName: 'Иван Петров',
          studentCount: 18,
          isOwner: true,
        ),
        ClassSummaryModel(
          id: 'class-3',
          title: '9В — История',
          ownerName: 'Мария Сидорова',
          studentCount: 22,
          isOwner: false,
        ),
        ClassSummaryModel(
          id: 'class-4',
          title: '10А — Химия',
          ownerName: 'Иван Петров',
          studentCount: 15,
          isOwner: true,
        ),
      ];
    }

    return const [
      ClassSummaryModel(
        id: 'class-1',
        title: '7А — Математика',
        ownerName: 'Иван Петров',
        studentCount: 24,
        isOwner: false,
      ),
      ClassSummaryModel(
        id: 'class-5',
        title: '7А — Русский язык',
        ownerName: 'Анна Козлова',
        studentCount: 24,
        isOwner: false,
      ),
      ClassSummaryModel(
        id: 'class-3',
        title: '9В — История',
        ownerName: 'Мария Сидорова',
        studentCount: 22,
        isOwner: false,
      ),
    ];
  }
}
