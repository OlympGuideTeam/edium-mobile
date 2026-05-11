import 'package:bloc_test/bloc_test.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/repositories/course_repository.dart';
import 'package:edium/domain/usecases/course/create_module_usecase.dart';
import 'package:edium/domain/usecases/course/get_course_detail_usecase.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_bloc.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_event.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCourseRepository extends Mock implements ICourseRepository {}

class MockProfileStorage extends Mock implements ProfileStorage {}

const _fakeCourse = CourseDetail(
  id: 'course-1',
  title: 'Алгебра 10',
  teacherName: 'Пётр Сидоров',
  moduleCount: 2,
  elementCount: 4,
  isTeacher: true,
  modules: [
    ModuleDetail(id: 'mod-1', title: 'Модуль 1', elementCount: 2, items: []),
    ModuleDetail(id: 'mod-2', title: 'Модуль 2', elementCount: 2, items: []),
  ],
  drafts: [],
);

const _courseWithDraft = CourseDetail(
  id: 'course-1',
  title: 'Алгебра 10',
  teacherName: 'Пётр Сидоров',
  moduleCount: 1,
  elementCount: 0,
  isTeacher: true,
  modules: [],
  drafts: [
    CourseDraft(id: 'draft-1', quizTemplateId: 'tmpl-1'),
  ],
);

CourseDetailBloc _makeBloc(
  MockCourseRepository repo,
  MockProfileStorage storage,
) =>
    CourseDetailBloc(
      getCourseDetail: GetCourseDetailUsecase(repo),
      createModule: CreateModuleUsecase(repo),
      profileStorage: storage,
      courseRepository: repo,
      courseId: 'course-1',
    );

void main() {
  late MockCourseRepository mockRepo;
  late MockProfileStorage mockStorage;

  setUp(() {
    mockRepo = MockCourseRepository();
    mockStorage = MockProfileStorage();
    when(() => mockStorage.getRole()).thenReturn('teacher');
  });

  group('LoadCourseDetailEvent', () {
    blocTest<CourseDetailBloc, CourseDetailState>(
      'загружает курс → CourseDetailLoaded',
      build: () {
        when(() => mockRepo.getCourseDetail(courseId: 'course-1'))
            .thenAnswer((_) async => _fakeCourse);
        return _makeBloc(mockRepo, mockStorage);
      },
      act: (b) => b.add(const LoadCourseDetailEvent('course-1')),
      expect: () => [
        const CourseDetailLoading(),
        isA<CourseDetailLoaded>()
            .having((s) => s.course.title, 'title', 'Алгебра 10')
            .having((s) => s.course.modules.length, 'modules', 2),
      ],
    );

    blocTest<CourseDetailBloc, CourseDetailState>(
      'ошибка загрузки → CourseDetailError',
      build: () {
        when(() => mockRepo.getCourseDetail(courseId: any(named: 'courseId')))
            .thenThrow(Exception('сеть'));
        return _makeBloc(mockRepo, mockStorage);
      },
      act: (b) => b.add(const LoadCourseDetailEvent('course-1')),
      expect: () => [
        const CourseDetailLoading(),
        isA<CourseDetailError>(),
      ],
    );

    blocTest<CourseDetailBloc, CourseDetailState>(
      'роль student → isTeacher=false через _applyRoleGuard',
      build: () {
        when(() => mockStorage.getRole()).thenReturn('student');
        when(() => mockRepo.getCourseDetail(courseId: any(named: 'courseId')))
            .thenAnswer((_) async => _fakeCourse);
        return _makeBloc(mockRepo, mockStorage);
      },
      act: (b) => b.add(const LoadCourseDetailEvent('course-1')),
      expect: () => [
        const CourseDetailLoading(),
        isA<CourseDetailLoaded>()
            .having((s) => s.course.isTeacher, 'isTeacher', false),
      ],
    );
  });

  group('SilentReloadCourseDetailEvent', () {
    blocTest<CourseDetailBloc, CourseDetailState>(
      'тихая перезагрузка обновляет курс без Loading',
      build: () {
        when(() => mockRepo.getCourseDetail(courseId: any(named: 'courseId')))
            .thenAnswer((_) async => _fakeCourse.copyWith(title: 'Алгебра 11'));
        return _makeBloc(mockRepo, mockStorage);
      },
      seed: () => CourseDetailLoaded(_fakeCourse),
      act: (b) => b.add(
        const SilentReloadCourseDetailEvent('course-1'),
      ),
      expect: () => [
        isA<CourseDetailLoaded>()
            .having((s) => s.course.title, 'title', 'Алгебра 11'),
      ],
    );

    blocTest<CourseDetailBloc, CourseDetailState>(
      'тихая перезагрузка при ошибке → возвращает предыдущее состояние',
      build: () {
        when(() => mockRepo.getCourseDetail(courseId: any(named: 'courseId')))
            .thenThrow(Exception('сеть'));
        return _makeBloc(mockRepo, mockStorage);
      },
      seed: () => CourseDetailLoaded(_fakeCourse),
      act: (b) =>
          b.add(const SilentReloadCourseDetailEvent('course-1')),
      expect: () => [
        isA<CourseDetailLoaded>()
            .having((s) => s.course.id, 'id', 'course-1'),
      ],
    );
  });

  group('CreateModuleEvent', () {
    blocTest<CourseDetailBloc, CourseDetailState>(
      'создаёт модуль → CourseModuleCreated с обновлённым курсом',
      build: () {
        when(() => mockRepo.createModule(
              courseId: any(named: 'courseId'),
              title: any(named: 'title'),
            )).thenAnswer((_) async {});
        when(() => mockRepo.getCourseDetail(courseId: any(named: 'courseId')))
            .thenAnswer((_) async => _fakeCourse.copyWith(
                  modules: [
                    ..._fakeCourse.modules,
                    const ModuleDetail(
                        id: 'mod-3', title: 'Новый', elementCount: 0, items: []),
                  ],
                ));
        return _makeBloc(mockRepo, mockStorage);
      },
      seed: () => CourseDetailLoaded(_fakeCourse),
      act: (b) => b.add(const CreateModuleEvent('Новый модуль')),
      expect: () => [
        isA<CourseModuleCreated>()
            .having((s) => s.course.modules.length, 'modules', 3),
      ],
    );

    blocTest<CourseDetailBloc, CourseDetailState>(
      'ошибка создания модуля → CourseDetailActionError',
      build: () {
        when(() => mockRepo.createModule(
              courseId: any(named: 'courseId'),
              title: any(named: 'title'),
            )).thenThrow(Exception('Ошибка'));
        return _makeBloc(mockRepo, mockStorage);
      },
      seed: () => CourseDetailLoaded(_fakeCourse),
      act: (b) => b.add(const CreateModuleEvent('Модуль')),
      expect: () => [isA<CourseDetailActionError>()],
    );
  });

  group('DeleteDraftEvent', () {
    blocTest<CourseDetailBloc, CourseDetailState>(
      'оптимистично удаляет черновик → CourseDraftDeleted',
      build: () {
        when(() => mockRepo.deleteDraft('draft-1'))
            .thenAnswer((_) async {});
        return _makeBloc(mockRepo, mockStorage);
      },
      seed: () => CourseDetailLoaded(_courseWithDraft),
      act: (b) => b.add(const DeleteDraftEvent('draft-1')),
      expect: () => [
        isA<CourseDraftDeleted>()
            .having((s) => s.course.drafts.length, 'drafts', 0),
      ],
    );

    blocTest<CourseDetailBloc, CourseDetailState>(
      'ошибка удаления черновика → CourseDetailActionError с исходным курсом',
      build: () {
        when(() => mockRepo.deleteDraft(any()))
            .thenThrow(Exception('сеть'));
        return _makeBloc(mockRepo, mockStorage);
      },
      seed: () => CourseDetailLoaded(_courseWithDraft),
      act: (b) => b.add(const DeleteDraftEvent('draft-1')),
      expect: () => [
        isA<CourseDraftDeleted>()
            .having((s) => s.course.drafts, 'drafts', isEmpty),
        isA<CourseDetailActionError>()
            .having((s) => s.course.drafts.length, 'drafts', 1),
      ],
    );
  });

  group('ReorderModulesEvent', () {
    blocTest<CourseDetailBloc, CourseDetailState>(
      'оптимистично меняет порядок модулей',
      build: () {
        when(() => mockRepo.reorderModules(
              courseId: any(named: 'courseId'),
              moduleIds: any(named: 'moduleIds'),
            )).thenAnswer((_) async {});
        return _makeBloc(mockRepo, mockStorage);
      },
      seed: () => CourseDetailLoaded(_fakeCourse),
      act: (b) => b.add(const ReorderModulesEvent(['mod-2', 'mod-1'])),
      expect: () => [
        isA<CourseDetailLoaded>()
            .having((s) => s.course.modules.first.id, 'firstId', 'mod-2'),
      ],
    );

    blocTest<CourseDetailBloc, CourseDetailState>(
      'ошибка перестановки → CourseDetailActionError восстанавливает исходный порядок',
      build: () {
        when(() => mockRepo.reorderModules(
              courseId: any(named: 'courseId'),
              moduleIds: any(named: 'moduleIds'),
            )).thenThrow(Exception('ошибка'));
        return _makeBloc(mockRepo, mockStorage);
      },
      seed: () => CourseDetailLoaded(_fakeCourse),
      act: (b) => b.add(const ReorderModulesEvent(['mod-2', 'mod-1'])),
      expect: () => [
        isA<CourseDetailLoaded>()
            .having((s) => s.course.modules.first.id, 'firstId', 'mod-2'),
        isA<CourseDetailActionError>()
            .having((s) => s.course.modules.first.id, 'firstId', 'mod-1'),
      ],
    );
  });

  group('OptimisticQuizAddedEvent', () {
    const _payload = CourseItemPayload(mode: 'test', title: 'Тест по химии');

    blocTest<CourseDetailBloc, CourseDetailState>(
      'добавляет элемент в модуль оптимистично',
      build: () => _makeBloc(mockRepo, mockStorage),
      seed: () => CourseDetailLoaded(_fakeCourse),
      act: (b) => b.add(const OptimisticQuizAddedEvent(
        title: 'Тест по химии',
        mode: 'test',
        moduleId: 'mod-1',
        shuffleQuestions: false,
      )),
      expect: () => [
        isA<CourseDetailLoaded>().having(
          (s) => s.course.modules
              .firstWhere((m) => m.id == 'mod-1')
              .items
              .length,
          'items',
          1,
        ),
      ],
    );

    blocTest<CourseDetailBloc, CourseDetailState>(
      'добавляет черновик если moduleId null',
      build: () => _makeBloc(mockRepo, mockStorage),
      seed: () => CourseDetailLoaded(_fakeCourse),
      act: (b) => b.add(const OptimisticQuizAddedEvent(
        title: 'Шаблон',
        mode: 'test',
        moduleId: null,
        shuffleQuestions: false,
      )),
      expect: () => [
        isA<CourseDetailLoaded>()
            .having((s) => s.course.drafts.length, 'drafts', 1),
      ],
    );
  });
}
