import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/data/datasources/course/course_datasource.dart';
import 'package:edium/domain/entities/course_detail.dart';

class CourseDatasourceMock implements ICourseDatasource {
  final ProfileStorage _profileStorage;

  CourseDatasourceMock(this._profileStorage);

  @override
  Future<String> createCourse({
    required String title,
    required String classId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'course-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> createModule({
    required String courseId,
    required String title,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<CourseDetail> getCourseDetail({required String courseId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final isTeacher = _profileStorage.getRole() == 'teacher';
    return CourseDetail(
      id: courseId,
      title: 'Алгебра 10 класс',
      teacherName: 'Пётр Сидоров',
      moduleCount: 3,
      elementCount: 7,
      isTeacher: isTeacher,
      modules: [
        ModuleDetail(
          id: 'module-1',
          title: 'Модуль 1: Многочлены',
          elementCount: 3,
          items: [
            CourseItem(
              id: 'item-1',
              refId: 'mock-test-sess-1',
              type: 'quiz',
              orderIndex: 0,
              attemptId: 'mock-att-1-A',
              score: 87.5,
              title: 'Многочлены: проверочный',
              quizType: 'test',
              state: 'completed',
            ),
            CourseItem(
              id: 'item-2',
              refId: 'mock-test-sess-2',
              type: 'quiz',
              orderIndex: 1,
              title: 'Уравнения I',
              quizType: 'test',
              state: 'in_progress',
            ),
            CourseItem(
              id: 'item-3',
              refId: 'mock-test-sess-3',
              type: 'quiz',
              orderIndex: 2,
              title: 'Функции — вводный',
              quizType: 'test',
              state: 'not_started',
              startTime: DateTime.utc(2030, 1, 1, 9),
              endTime: DateTime.utc(2030, 1, 10, 23, 59),
            ),
          ],
        ),
        ModuleDetail(
          id: 'module-2',
          title: 'Модуль 2: Уравнения',
          elementCount: 2,
          items: [
            CourseItem(
              id: 'item-4',
              refId: 'mock-test-sess-2',
              type: 'quiz',
              orderIndex: 0,
              title: 'Уравнения I (повтор)',
              quizType: 'test',
              state: 'not_started',
            ),
            CourseItem(
              id: 'item-5',
              refId: 'mock-test-sess-3',
              type: 'quiz',
              orderIndex: 1,
              title: 'Функции (тест)',
              quizType: 'test',
              state: 'not_started',
            ),
          ],
        ),
        ModuleDetail(
          id: 'module-3',
          title: 'Модуль 3: Функции',
          elementCount: 2,
          items: [
            CourseItem(
              id: 'item-6',
              refId: 'mock-test-sess-1',
              type: 'quiz',
              orderIndex: 0,
              title: 'Многочлены — итог',
              quizType: 'test',
              state: 'not_started',
            ),
            CourseItem(
              id: 'item-7',
              refId: 'mock-test-sess-2',
              type: 'quiz',
              orderIndex: 1,
              title: 'Уравнения — итог',
              quizType: 'test',
              state: 'not_started',
            ),
          ],
        ),
      ],
    );
  }
}
