import 'package:bloc_test/bloc_test.dart';
import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus, QuizQuestionType;
import 'package:edium/domain/repositories/test_session_repository.dart';
import 'package:edium/domain/usecases/test_session/get_attempt_review_usecase.dart';
import 'package:edium/domain/usecases/test_session/grade_submission_usecase.dart';
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_bloc.dart';
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_event.dart';
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTestSessionRepository extends Mock implements ITestSessionRepository {}

final _fakeReview = AttemptReview(
  attemptId: 'att-1',
  userId: 'user-1',
  status: AttemptStatus.graded,
  score: null,
  startedAt: DateTime(2026, 4, 24),
  answers: const [
    AnswerReview(
      submissionId: 'sub-1',
      questionId: 'q-1',
      questionType: QuizQuestionType.withFreeAnswer,
      questionText: 'Объясните…',
      answerData: {'text': 'ответ ученика'},
    ),
  ],
);

void main() {
  late MockTestSessionRepository mockRepo;
  late TeacherGradeBloc bloc;

  setUp(() {
    mockRepo = MockTestSessionRepository();
    bloc = TeacherGradeBloc(
      getReview: GetAttemptReviewUsecase(mockRepo),
      gradeSubmission: GradeSubmissionUsecase(mockRepo),
    );
  });

  tearDown(() => bloc.close());

  group('LoadTeacherGradeEvent', () {
    blocTest<TeacherGradeBloc, TeacherGradeState>(
      'загружает AttemptReview → эмитит Loaded',
      build: () {
        when(() => mockRepo.getAttemptReview('att-1'))
            .thenAnswer((_) async => _fakeReview);
        return bloc;
      },
      act: (b) => b.add(const LoadTeacherGradeEvent('att-1')),
      expect: () => [
        const TeacherGradeLoading(),
        TeacherGradeLoaded(review: _fakeReview),
      ],
    );

    blocTest<TeacherGradeBloc, TeacherGradeState>(
      'при ошибке → эмитит Error',
      build: () {
        when(() => mockRepo.getAttemptReview(any()))
            .thenThrow(Exception('сеть'));
        return bloc;
      },
      act: (b) => b.add(const LoadTeacherGradeEvent('att-1')),
      expect: () => [
        const TeacherGradeLoading(),
        isA<TeacherGradeError>(),
      ],
    );
  });

  group('CompleteGradingEvent', () {
    blocTest<TeacherGradeBloc, TeacherGradeState>(
      'отправляет батч оценок → эмитит Completed',
      build: () {
        when(() => mockRepo.gradeAttempt(
              attemptId: any(named: 'attemptId'),
              grades: any(named: 'grades'),
            )).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => TeacherGradeLoaded(
        review: _fakeReview,
        localGrades: {'sub-1': (score: 15.0, feedback: 'Хорошо')},
      ),
      act: (b) => b.add(const CompleteGradingEvent('att-1')),
      expect: () => [
        isA<TeacherGradeLoaded>().having((s) => s.isSaving, 'isSaving', true),
        const TeacherGradeCompleted(),
      ],
      verify: (_) {
        verify(() => mockRepo.gradeAttempt(
              attemptId: 'att-1',
              grades: any(named: 'grades'),
            )).called(1);
      },
    );

    blocTest<TeacherGradeBloc, TeacherGradeState>(
      'при ошибке grade → остаётся в Loaded с saveError',
      build: () {
        when(() => mockRepo.gradeAttempt(
              attemptId: any(named: 'attemptId'),
              grades: any(named: 'grades'),
            )).thenThrow(Exception('timeout'));
        return bloc;
      },
      seed: () => TeacherGradeLoaded(
        review: _fakeReview,
        localGrades: {'sub-1': (score: 15.0, feedback: null)},
      ),
      act: (b) => b.add(const CompleteGradingEvent('att-1')),
      expect: () => [
        isA<TeacherGradeLoaded>().having((s) => s.isSaving, 'isSaving', true),
        isA<TeacherGradeLoaded>().having((s) => s.saveError, 'saveError', isNotNull),
      ],
    );
  });
}
