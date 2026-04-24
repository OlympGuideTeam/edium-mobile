import 'package:edium/data/datasources/class/class_datasource.dart';
import 'package:edium/data/models/class_detail_model.dart';
import 'package:edium/data/models/class_summary_model.dart';

class ClassDatasourceMock implements IClassDatasource {
  final List<ClassSummaryModel> _createdClasses = [];
  final Map<String, ClassDetailModel> _classDetails = {};
  final Set<String> _deletedClasses = {};

  @override
  Future<String> createClass({required String title}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = 'class-new-${DateTime.now().millisecondsSinceEpoch}';
    _createdClasses.add(ClassSummaryModel(
      id: id,
      title: title,
      ownerName: 'Иван Петров',
      studentCount: 0,
      isOwner: true,
    ));
    return id;
  }

  @override
  Future<List<ClassSummaryModel>> getMyClasses({required String role}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (role == 'teacher') {
      return [
        ..._createdClasses,
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

  ClassDetailModel _defaultDetail(String classId) {
    return ClassDetailModel(
      id: classId,
      title: '7А — Математика',
      ownerName: 'Иван Петров',
      isOwner: true,
      students: const [
        MemberShortModel(id: 'student-1', name: 'Мария', surname: 'Кузнецова'),
        MemberShortModel(id: 'student-2', name: 'Дмитрий', surname: 'Волков'),
        MemberShortModel(id: 'student-3', name: 'Анна', surname: 'Соколова'),
        MemberShortModel(id: 'student-4', name: 'Артём', surname: 'Новиков'),
      ],
      courses: const [
        CourseSummaryModel(
          id: 'course-1',
          title: 'Алгебра 7 класс',
          teacherName: 'Иван Петров',
          moduleCount: 4,
          elementCount: 12,
          isTeacher: true,
        ),
        CourseSummaryModel(
          id: 'course-2',
          title: 'Геометрия 7 класс',
          teacherName: 'Иван Петров',
          moduleCount: 3,
          elementCount: 8,
          isTeacher: true,
        ),
        CourseSummaryModel(
          id: 'course-3',
          title: 'Информатика',
          teacherName: 'Елена Смирнова',
          moduleCount: 5,
          elementCount: 15,
          isTeacher: false,
        ),
      ],
      teachers: const [
        MemberShortModel(id: 'teacher-1', name: 'Иван', surname: 'Петров'),
        MemberShortModel(id: 'teacher-2', name: 'Елена', surname: 'Смирнова'),
      ],
    );
  }

  @override
  Future<ClassDetailModel> getClassDetail({required String classId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _classDetails[classId] ?? _defaultDetail(classId);
  }

  @override
  Future<void> updateClass({
    required String classId,
    required String title,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final current = _classDetails[classId] ?? _defaultDetail(classId);
    _classDetails[classId] = ClassDetailModel(
      id: current.id,
      title: title,
      ownerName: current.ownerName,
      isOwner: current.isOwner,
      students: current.students,
      courses: current.courses,
      teachers: current.teachers,
    );
  }

  @override
  Future<void> deleteClass({required String classId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _deletedClasses.add(classId);
    _classDetails.remove(classId);
  }

  @override
  Future<void> removeMember({
    required String classId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final current = _classDetails[classId] ?? _defaultDetail(classId);
    _classDetails[classId] = ClassDetailModel(
      id: current.id,
      title: current.title,
      ownerName: current.ownerName,
      isOwner: current.isOwner,
      students: current.students.where((s) => s.id != userId).toList(),
      courses: current.courses,
      teachers: current.teachers,
    );
  }

  @override
  Future<String> getInviteLink({
    required String classId,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 'https://edium.ru/invite/mock-$role-$classId';
  }

  @override
  Future<void> deleteCourse({required String courseId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
