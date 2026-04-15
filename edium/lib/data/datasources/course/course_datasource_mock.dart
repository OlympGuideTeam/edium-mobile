import 'package:edium/data/datasources/course/course_datasource.dart';
import 'package:edium/domain/entities/course_detail.dart';

class CourseDatasourceMock implements ICourseDatasource {
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
    return CourseDetail(
      id: courseId,
      title: 'Алгебра 10 класс',
      teacherName: 'Пётр Сидоров',
      moduleCount: 3,
      elementCount: 7,
      isTeacher: true,
      modules: [
        ModuleDetail(
          id: 'module-1',
          title: 'Модуль 1: Многочлены',
          elementCount: 3,
          items: [
            CourseItem(
              id: 'item-1',
              refId: 'quiz-uuid-0001',
              type: 'quiz',
              orderIndex: 0,
              attemptId: 'attempt-uuid-0001',
              score: 87.5,
            ),
            CourseItem(
              id: 'item-2',
              refId: 'quiz-uuid-0002',
              type: 'quiz',
              orderIndex: 1,
              attemptId: null,
              score: null,
            ),
            CourseItem(
              id: 'item-3',
              refId: 'quiz-uuid-0003',
              type: 'quiz',
              orderIndex: 2,
              attemptId: 'attempt-uuid-0003',
              score: 60.0,
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
              refId: 'quiz-uuid-0004',
              type: 'quiz',
              orderIndex: 0,
              attemptId: null,
              score: null,
            ),
            CourseItem(
              id: 'item-5',
              refId: 'quiz-uuid-0005',
              type: 'quiz',
              orderIndex: 1,
              attemptId: null,
              score: null,
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
              refId: 'quiz-uuid-0006',
              type: 'quiz',
              orderIndex: 0,
              attemptId: null,
              score: null,
            ),
            CourseItem(
              id: 'item-7',
              refId: 'quiz-uuid-0007',
              type: 'quiz',
              orderIndex: 1,
              attemptId: null,
              score: null,
            ),
          ],
        ),
      ],
    );
  }
}
