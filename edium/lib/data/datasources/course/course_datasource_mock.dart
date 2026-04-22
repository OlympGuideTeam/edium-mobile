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
        payload: CourseItemPayload(
          title: 'Степени и многочлены',
          mode: 'test',
          totalTimeLimitSec: 1800,
          startedAt: null,
          finishedAt: null,
        ),
      ),
      CourseItem(
        id: 'item-2',
        refId: 'quiz-uuid-0002',
        type: 'quiz',
        orderIndex: 1,
        payload: CourseItemPayload(
          title: 'Разложение на множители',
          mode: 'live',
          questionTimeLimitSec: 30,
        ),
      ),
      CourseItem(
        id: 'item-3',
        refId: 'quiz-uuid-0003',
        type: 'quiz',
        orderIndex: 2,
        attemptId: 'attempt-uuid-0003',
        score: 60.0,
        payload: CourseItemPayload(
          title: 'Итоговый тест по многочленам',
          mode: 'test',
          totalTimeLimitSec: 2700,
          startedAt: null,
          finishedAt: null,
        ),
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
        payload: CourseItemPayload(
          title: 'Линейные уравнения',
          mode: 'test',
          totalTimeLimitSec: 900,
        ),
      ),
      CourseItem(
        id: 'item-5',
        refId: 'quiz-uuid-0005',
        type: 'quiz',
        orderIndex: 1,
        payload: CourseItemPayload(
          title: 'Квадратные уравнения',
          mode: 'test',
          totalTimeLimitSec: 1200,
        ),
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
        payload: CourseItemPayload(
          title: 'Понятие функции',
          mode: 'live',
          questionTimeLimitSec: 45,
        ),
      ),
      CourseItem(
        id: 'item-7',
        refId: 'quiz-uuid-0007',
        type: 'quiz',
        orderIndex: 1,
        payload: CourseItemPayload(
          title: 'Графики функций',
          mode: 'test',
          totalTimeLimitSec: 1500,
        ),
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
      modules: _mockModules.values
          .map((m) => ModuleDetail(id: m.id, title: m.title, elementCount: m.elementCount, items: const []))
          .toList(),
      drafts: _mockDrafts,
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
}
