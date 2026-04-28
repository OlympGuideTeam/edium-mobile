import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/data/datasources/course/course_datasource.dart';
import 'package:edium/domain/entities/course_detail.dart';

const _mockModules = <String, ModuleDetail>{
  'module-1': ModuleDetail(
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
        title: 'Степени и многочлены',
        quizType: 'test',
        state: 'completed',
      ),
      CourseItem(
        id: 'item-2',
        refId: 'quiz-uuid-0002',
        type: 'quiz',
        orderIndex: 1,
        title: 'Разложение на множители',
        quizType: 'live',
        state: 'not_started',
      ),
      CourseItem(
        id: 'item-3',
        refId: 'quiz-uuid-0003',
        type: 'quiz',
        orderIndex: 2,
        attemptId: 'attempt-uuid-0003',
        score: 60.0,
        title: 'Итоговый тест по многочленам',
        quizType: 'test',
        state: 'completed',
      ),
    ],
  ),
  'module-2': ModuleDetail(
    id: 'module-2',
    title: 'Модуль 2: Уравнения',
    elementCount: 2,
    items: [
      CourseItem(
        id: 'item-4',
        refId: 'quiz-uuid-0004',
        type: 'quiz',
        orderIndex: 0,
        title: 'Линейные уравнения',
        quizType: 'test',
        state: 'in_progress',
      ),
      CourseItem(
        id: 'item-5',
        refId: 'quiz-uuid-0005',
        type: 'quiz',
        orderIndex: 1,
        title: 'Квадратные уравнения',
        quizType: 'test',
        state: 'not_started',
      ),
    ],
  ),
  'module-3': ModuleDetail(
    id: 'module-3',
    title: 'Модуль 3: Функции',
    elementCount: 2,
    items: [
      CourseItem(
        id: 'item-6',
        refId: 'quiz-uuid-0006',
        type: 'quiz',
        orderIndex: 0,
        title: 'Понятие функции',
        quizType: 'live',
        state: 'running',
      ),
      CourseItem(
        id: 'item-7',
        refId: 'quiz-uuid-0007',
        type: 'quiz',
        orderIndex: 1,
        title: 'Графики функций',
        quizType: 'test',
        state: 'not_started',
      ),
    ],
  ),
  'module-mon': ModuleDetail(
    id: 'module-mon',
    title: 'Мониторинг (демо)',
    elementCount: 3,
    items: [
      CourseItem(
        id: 'mon-item-1',
        refId: 'mock-mon-sess-1',
        type: 'quiz',
        orderIndex: 0,
        title: 'Линейная алгебра',
        quizType: 'test',
        state: 'in_progress',
      ),
      CourseItem(
        id: 'mon-item-2',
        refId: 'mock-mon-sess-2',
        type: 'quiz',
        orderIndex: 1,
        title: 'Квадратные уравнения',
        quizType: 'test',
        state: 'in_progress',
        needEvaluation: true,
      ),
      CourseItem(
        id: 'mon-item-3',
        refId: 'mock-mon-sess-3',
        type: 'quiz',
        orderIndex: 2,
        title: 'Многочлены',
        quizType: 'test',
        state: 'in_progress',
      ),
    ],
  ),
};

const _mockDrafts = [
  CourseDraft(
    id: 'draft-1',
    quizTemplateId: '1',
    payload: CourseItemPayload(
      title: 'Производные и интегралы',
      mode: 'test',
      totalTimeLimitSec: 1800,
    ),
  ),
  CourseDraft(
    id: 'draft-2',
    quizTemplateId: '2',
    payload: CourseItemPayload(
      title: 'Тригонометрия: базовый курс',
      mode: 'live',
      questionTimeLimitSec: 30,
    ),
  ),
];

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
      moduleCount: 4,
      elementCount: 10,
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
        ModuleDetail(
          id: 'module-mon',
          title: 'Мониторинг (демо)',
          elementCount: 3,
          items: const [],
        ),
      ],
    );
  }

  @override
  Future<ModuleDetail> getModuleDetail({required String moduleId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockModules[moduleId] ??
        ModuleDetail(id: moduleId, title: 'Модуль', elementCount: 0, items: const []);
  }

  @override
  Future<void> deleteDraft(String draftId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> reorderModules({
    required String courseId,
    required List<String> moduleIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<CourseSheet> getCourseSheet({required String courseId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const CourseSheet(
      columns: [
        SheetColumn(id: 'item-1', objectId: 'quiz-uuid-0001'),
        SheetColumn(id: 'item-2', objectId: 'quiz-uuid-0002'),
        SheetColumn(id: 'item-3', objectId: 'quiz-uuid-0003'),
        SheetColumn(id: 'item-4', objectId: 'quiz-uuid-0004'),
        SheetColumn(id: 'item-5', objectId: 'quiz-uuid-0005'),
      ],
      rows: [
        SheetRow(
          studentId: 'stud-1',
          studentName: 'Мария Кузнецова',
          scores: [
            SheetScore(itemId: 'item-1', score: 85.0),
            SheetScore(itemId: 'item-2', score: 72.0),
            SheetScore(itemId: 'item-3'),
            SheetScore(itemId: 'item-4', score: 91.0),
            SheetScore(itemId: 'item-5', score: 60.0),
          ],
        ),
        SheetRow(
          studentId: 'stud-2',
          studentName: 'Алексей Петров',
          scores: [
            SheetScore(itemId: 'item-1', score: 91.5),
            SheetScore(itemId: 'item-2'),
            SheetScore(itemId: 'item-3', score: 60.0),
            SheetScore(itemId: 'item-4', score: 45.0),
            SheetScore(itemId: 'item-5'),
          ],
        ),
        SheetRow(
          studentId: 'stud-3',
          studentName: 'Ирина Смирнова',
          scores: [
            SheetScore(itemId: 'item-1'),
            SheetScore(itemId: 'item-2', score: 55.0),
            SheetScore(itemId: 'item-3', score: 88.0),
            SheetScore(itemId: 'item-4'),
            SheetScore(itemId: 'item-5', score: 77.0),
          ],
        ),
        SheetRow(
          studentId: 'stud-4',
          studentName: 'Дмитрий Новиков',
          scores: [
            SheetScore(itemId: 'item-1', score: 100.0),
            SheetScore(itemId: 'item-2', score: 95.0),
            SheetScore(itemId: 'item-3', score: 82.0),
            SheetScore(itemId: 'item-4', score: 78.0),
            SheetScore(itemId: 'item-5', score: 90.0),
          ],
        ),
      ],
    );
  }
}
