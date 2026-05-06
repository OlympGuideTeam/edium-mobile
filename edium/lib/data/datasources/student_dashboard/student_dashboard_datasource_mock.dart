import 'package:edium/data/datasources/student_dashboard/student_dashboard_datasource.dart';
import 'package:edium/data/models/student_dashboard_model.dart';

class StudentDashboardDatasourceMock implements IStudentDashboardDatasource {
  @override
  Future<StudentDashboardModel> getDashboard() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return StudentDashboardModel(
      recentGrades: [
        RecentGradeItemModel(
          sessionId: 'mock-sess-grade-1',
          quizTemplateId: 'quiz-uuid-0001',
          quizTitle: 'Квадратные уравнения',
          attemptId: 'attempt-uuid-0001',
          score: 8.5,
          status: 'completed',
          finishedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        RecentGradeItemModel(
          sessionId: 'mock-sess-grade-2',
          quizTemplateId: 'quiz-uuid-0002',
          quizTitle: 'Физика: оптика',
          attemptId: 'attempt-uuid-0002',
          score: null,
          status: 'grading',
          finishedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        RecentGradeItemModel(
          sessionId: 'mock-sess-grade-3',
          quizTemplateId: 'quiz-uuid-0003',
          quizTitle: 'История России — итоговый тест',
          attemptId: 'attempt-uuid-0003',
          score: 6.0,
          status: 'published',
          finishedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ],
      activeTests: [
        ActiveTestItemModel(
          sessionId: 'mock-sess-active-1',
          quizTemplateId: 'quiz-uuid-0010',
          quizTitle: 'Алгебра: функции и графики',
          totalTimeLimitSec: 3600,
          sessionFinishedAt: DateTime.now().add(const Duration(days: 2)),
          attemptId: null,
          attemptStatus: null,
        ),
        ActiveTestItemModel(
          sessionId: 'mock-sess-active-2',
          quizTemplateId: 'quiz-uuid-0011',
          quizTitle: 'Биология: клетка и её строение',
          totalTimeLimitSec: null,
          sessionFinishedAt: DateTime.now().add(const Duration(hours: 20)),
          attemptId: 'attempt-uuid-0020',
          attemptStatus: 'in_progress',
        ),
      ],
    );
  }
}
