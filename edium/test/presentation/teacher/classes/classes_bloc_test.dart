import 'package:bloc_test/bloc_test.dart';
import 'package:edium/domain/entities/class_summary.dart';
import 'package:edium/domain/repositories/class_repository.dart';
import 'package:edium/domain/usecases/class/create_class_usecase.dart';
import 'package:edium/domain/usecases/class/delete_class_usecase.dart';
import 'package:edium/domain/usecases/class/get_my_classes_usecase.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_bloc.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_event.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClassRepository extends Mock implements IClassRepository {}

final _fakeClasses = [
  const ClassSummary(
    id: 'cls-1',
    title: '10А — Математика',
    ownerName: 'Пётр Сидоров',
    studentCount: 28,
    isOwner: true,
  ),
  const ClassSummary(
    id: 'cls-2',
    title: '9Б — Физика',
    ownerName: 'Анна Смирнова',
    studentCount: 25,
    isOwner: false,
  ),
];

ClassesBloc _makeBloc(MockClassRepository repo) => ClassesBloc(
      getMyClasses: GetMyClassesUsecase(repo),
      createClass: CreateClassUsecase(repo),
      deleteClass: DeleteClassUsecase(repo),
      role: 'teacher',
    );

void main() {
  late MockClassRepository mockRepo;

  setUp(() {
    mockRepo = MockClassRepository();
  });

  group('LoadClassesEvent', () {
    blocTest<ClassesBloc, ClassesState>(
      'загружает классы → эмитит Loading, Loaded',
      build: () {
        when(() => mockRepo.getMyClasses(role: 'teacher'))
            .thenAnswer((_) async => _fakeClasses);
        return _makeBloc(mockRepo);
      },
      act: (b) => b.add(const LoadClassesEvent()),
      expect: () => [
        const ClassesLoading(),
        isA<ClassesLoaded>()
            .having((s) => s.classes.length, 'length', 2)
            .having((s) => s.filtered.length, 'filtered', 2),
      ],
    );

    blocTest<ClassesBloc, ClassesState>(
      'при ошибке → эмитит ClassesError',
      build: () {
        when(() => mockRepo.getMyClasses(role: any(named: 'role')))
            .thenThrow(Exception('сеть'));
        return _makeBloc(mockRepo);
      },
      act: (b) => b.add(const LoadClassesEvent()),
      expect: () => [
        const ClassesLoading(),
        isA<ClassesError>(),
      ],
    );

    blocTest<ClassesBloc, ClassesState>(
      'повторная загрузка при уже Loaded не эмитит Loading',
      build: () {
        when(() => mockRepo.getMyClasses(role: 'teacher'))
            .thenAnswer((_) async => _fakeClasses);
        return _makeBloc(mockRepo);
      },
      seed: () => ClassesLoaded(classes: _fakeClasses, filtered: _fakeClasses),
      act: (b) => b.add(const LoadClassesEvent()),
      expect: () => [
        isA<ClassesLoaded>(),
      ],
    );
  });

  group('SearchClassesEvent', () {
    blocTest<ClassesBloc, ClassesState>(
      'фильтрует по заголовку без учёта регистра',
      build: () => _makeBloc(mockRepo),
      seed: () => ClassesLoaded(classes: _fakeClasses, filtered: _fakeClasses),
      act: (b) => b.add(const SearchClassesEvent('математика')),
      expect: () => [
        isA<ClassesLoaded>()
            .having((s) => s.filtered.length, 'filtered', 1)
            .having((s) => s.filtered.first.id, 'id', 'cls-1')
            .having((s) => s.searchQuery, 'query', 'математика'),
      ],
    );

    blocTest<ClassesBloc, ClassesState>(
      'пустой запрос восстанавливает полный список',
      build: () => _makeBloc(mockRepo),
      seed: () => ClassesLoaded(
        classes: _fakeClasses,
        filtered: [_fakeClasses.first],
        searchQuery: 'математика',
      ),
      act: (b) => b.add(const SearchClassesEvent('')),
      expect: () => [
        isA<ClassesLoaded>()
            .having((s) => s.filtered.length, 'filtered', 2)
            .having((s) => s.searchQuery, 'query', ''),
      ],
    );

    blocTest<ClassesBloc, ClassesState>(
      'игнорируется если состояние не Loaded',
      build: () => _makeBloc(mockRepo),
      act: (b) => b.add(const SearchClassesEvent('тест')),
      expect: () => [],
    );
  });

  group('CreateClassEvent', () {
    blocTest<ClassesBloc, ClassesState>(
      'создаёт класс → эмитит ClassCreated, перезагружает список',
      build: () {
        when(() => mockRepo.createClass(title: 'Новый класс'))
            .thenAnswer((_) async => 'cls-new');
        when(() => mockRepo.getMyClasses(role: 'teacher'))
            .thenAnswer((_) async => _fakeClasses);
        return _makeBloc(mockRepo);
      },
      act: (b) => b.add(const CreateClassEvent('Новый класс')),
      expect: () => [
        const ClassCreated(),
        const ClassesLoading(),
        isA<ClassesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepo.createClass(title: 'Новый класс')).called(1);
      },
    );

    blocTest<ClassesBloc, ClassesState>(
      'при ошибке создания → эмитит ClassCreateError',
      build: () {
        when(() => mockRepo.createClass(title: any(named: 'title')))
            .thenThrow(Exception('Ошибка'));
        return _makeBloc(mockRepo);
      },
      act: (b) => b.add(const CreateClassEvent('Новый класс')),
      expect: () => [isA<ClassCreateError>()],
    );
  });

  group('DeleteClassEvent', () {
    blocTest<ClassesBloc, ClassesState>(
      'удаляет класс → эмитит ClassDeleted, перезагружает список',
      build: () {
        when(() => mockRepo.deleteClass(classId: 'cls-1'))
            .thenAnswer((_) async {});
        when(() => mockRepo.getMyClasses(role: 'teacher'))
            .thenAnswer((_) async => [_fakeClasses[1]]);
        return _makeBloc(mockRepo);
      },
      act: (b) => b.add(const DeleteClassEvent('cls-1')),
      expect: () => [
        const ClassDeleted(),
        const ClassesLoading(),
        isA<ClassesLoaded>().having((s) => s.classes.length, 'length', 1),
      ],
    );

    blocTest<ClassesBloc, ClassesState>(
      'при ошибке удаления → эмитит ClassDeleteError',
      build: () {
        when(() => mockRepo.deleteClass(classId: any(named: 'classId')))
            .thenThrow(Exception('Нет прав'));
        return _makeBloc(mockRepo);
      },
      act: (b) => b.add(const DeleteClassEvent('cls-1')),
      expect: () => [isA<ClassDeleteError>()],
    );
  });
}
