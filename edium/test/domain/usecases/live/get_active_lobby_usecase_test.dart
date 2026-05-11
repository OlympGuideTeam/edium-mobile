import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/domain/entities/class_summary.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/repositories/class_repository.dart';
import 'package:edium/domain/repositories/course_repository.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/domain/usecases/live/get_active_lobby_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClassRepository extends Mock implements IClassRepository {}

class MockCourseRepository extends Mock implements ICourseRepository {}

class MockLiveRepository extends Mock implements ILiveRepository {}

// Фиктивные сущности
const _classSummary = ClassSummary(
  id: 'cls-1',
  title: '10А',
  ownerName: 'Пётр',
  studentCount: 20,
  isOwner: false,
);

const _classDetail = ClassDetail(
  id: 'cls-1',
  title: '10А',
  ownerName: 'Пётр',
  isOwner: false,
  teachers: [],
  students: [],
  courses: [CourseSummary(id: 'course-1', title: 'Алгебра', teacherName: 'Пётр', moduleCount: 1, elementCount: 2, isTeacher: false)],
);

const _courseDetail = CourseDetail(
  id: 'course-1',
  title: 'Алгебра',
  teacherName: 'Пётр',
  moduleCount: 1,
  elementCount: 2,
  isTeacher: false,
  modules: [
    ModuleDetail(id: 'mod-1', title: 'Модуль 1', elementCount: 2, items: []),
  ],
);

const _moduleWithLive = ModuleDetail(
  id: 'mod-1',
  title: 'Модуль 1',
  elementCount: 1,
  items: [
    CourseItem(
      id: 'item-1',
      refId: 'live-sess-1',
      type: 'quiz',
      orderIndex: 0,
      quizType: 'live',
    ),
  ],
);

const _moduleWithTest = ModuleDetail(
  id: 'mod-1',
  title: 'Модуль 1',
  elementCount: 1,
  items: [
    CourseItem(
      id: 'item-1',
      refId: 'test-sess-1',
      type: 'quiz',
      orderIndex: 0,
      quizType: 'test',
    ),
  ],
);

final _lobbyMeta = LiveSessionMeta(
  sessionId: 'live-sess-1',
  quizTemplateId: 'tmpl-1',
  quizTitle: 'Лайв-квиз',
  questionCount: 5,
  source: 'course',
  phase: LivePhase.lobby,
  joinCode: '123456',
  questionTimeLimitSec: 30,
  isAnonymousAllowed: false,
  participantsCount: 3,
);

final _completedMeta = LiveSessionMeta(
  sessionId: 'live-sess-2',
  quizTemplateId: 'tmpl-2',
  quizTitle: 'Завершённый',
  questionCount: 5,
  source: 'course',
  phase: LivePhase.completed,
  questionTimeLimitSec: 30,
  isAnonymousAllowed: false,
  participantsCount: 0,
);

void main() {
  late MockClassRepository mockClassRepo;
  late MockCourseRepository mockCourseRepo;
  late MockLiveRepository mockLiveRepo;
  late GetActiveLobbyUsecase usecase;

  setUp(() {
    mockClassRepo = MockClassRepository();
    mockCourseRepo = MockCourseRepository();
    mockLiveRepo = MockLiveRepository();
    usecase = GetActiveLobbyUsecase(
      classRepo: mockClassRepo,
      courseRepo: mockCourseRepo,
      liveRepo: mockLiveRepo,
    );
  });

  test('нет классов → возвращает null', () async {
    when(() => mockClassRepo.getMyClasses(role: 'student'))
        .thenAnswer((_) async => []);

    final result = await usecase();

    expect(result, isNull);
    verifyNever(() => mockClassRepo.getClassDetail(classId: any(named: 'classId')));
  });

  test('есть классы, нет курсов → возвращает null', () async {
    when(() => mockClassRepo.getMyClasses(role: 'student'))
        .thenAnswer((_) async => [_classSummary]);
    when(() => mockClassRepo.getClassDetail(classId: 'cls-1')).thenAnswer(
      (_) async => const ClassDetail(
        id: 'cls-1',
        title: '10А',
        ownerName: 'Пётр',
        isOwner: false,
        teachers: [],
        students: [],
        courses: [],
      ),
    );

    final result = await usecase();

    expect(result, isNull);
  });

  test('есть курс, но нет модулей с элементами → возвращает null', () async {
    when(() => mockClassRepo.getMyClasses(role: 'student'))
        .thenAnswer((_) async => [_classSummary]);
    when(() => mockClassRepo.getClassDetail(classId: 'cls-1'))
        .thenAnswer((_) async => _classDetail);
    when(() => mockCourseRepo.getCourseDetail(courseId: 'course-1'))
        .thenAnswer((_) async => const CourseDetail(
              id: 'course-1',
              title: 'Алгебра',
              teacherName: 'Пётр',
              moduleCount: 1,
              elementCount: 0,
              isTeacher: false,
              modules: [
                ModuleDetail(
                    id: 'mod-1', title: 'М1', elementCount: 0, items: []),
              ],
            ));

    final result = await usecase();

    expect(result, isNull);
  });

  test('нет live-элементов (только test) → возвращает null', () async {
    when(() => mockClassRepo.getMyClasses(role: 'student'))
        .thenAnswer((_) async => [_classSummary]);
    when(() => mockClassRepo.getClassDetail(classId: 'cls-1'))
        .thenAnswer((_) async => _classDetail);
    when(() => mockCourseRepo.getCourseDetail(courseId: 'course-1'))
        .thenAnswer((_) async => _courseDetail);
    when(() => mockCourseRepo.getModuleDetail(moduleId: 'mod-1'))
        .thenAnswer((_) async => _moduleWithTest);

    final result = await usecase();

    expect(result, isNull);
    verifyNever(() => mockLiveRepo.getLiveSession(any()));
  });

  test('есть live-сессия в фазе lobby → возвращает её meta', () async {
    when(() => mockClassRepo.getMyClasses(role: 'student'))
        .thenAnswer((_) async => [_classSummary]);
    when(() => mockClassRepo.getClassDetail(classId: 'cls-1'))
        .thenAnswer((_) async => _classDetail);
    when(() => mockCourseRepo.getCourseDetail(courseId: 'course-1'))
        .thenAnswer((_) async => _courseDetail);
    when(() => mockCourseRepo.getModuleDetail(moduleId: 'mod-1'))
        .thenAnswer((_) async => _moduleWithLive);
    when(() => mockLiveRepo.getLiveSession('live-sess-1'))
        .thenAnswer((_) async => _lobbyMeta);

    final result = await usecase();

    expect(result, isNotNull);
    expect(result!.phase, LivePhase.lobby);
    expect(result.sessionId, 'live-sess-1');
  });

  test('live-сессия завершена (не lobby) → возвращает null', () async {
    when(() => mockClassRepo.getMyClasses(role: 'student'))
        .thenAnswer((_) async => [_classSummary]);
    when(() => mockClassRepo.getClassDetail(classId: 'cls-1'))
        .thenAnswer((_) async => _classDetail);
    when(() => mockCourseRepo.getCourseDetail(courseId: 'course-1'))
        .thenAnswer((_) async => _courseDetail);
    when(() => mockCourseRepo.getModuleDetail(moduleId: 'mod-1'))
        .thenAnswer((_) async => _moduleWithLive);
    when(() => mockLiveRepo.getLiveSession('live-sess-1'))
        .thenAnswer((_) async => _completedMeta);

    final result = await usecase();

    expect(result, isNull);
  });

  test('ошибка getLiveSession → пропускает, не падает, возвращает null', () async {
    when(() => mockClassRepo.getMyClasses(role: 'student'))
        .thenAnswer((_) async => [_classSummary]);
    when(() => mockClassRepo.getClassDetail(classId: 'cls-1'))
        .thenAnswer((_) async => _classDetail);
    when(() => mockCourseRepo.getCourseDetail(courseId: 'course-1'))
        .thenAnswer((_) async => _courseDetail);
    when(() => mockCourseRepo.getModuleDetail(moduleId: 'mod-1'))
        .thenAnswer((_) async => _moduleWithLive);
    when(() => mockLiveRepo.getLiveSession('live-sess-1'))
        .thenThrow(Exception('сеть'));

    final result = await usecase();

    expect(result, isNull);
  });
}
