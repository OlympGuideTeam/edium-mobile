import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/presentation/teacher/course_detail/course_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CourseItem item({String? state, double? score}) => CourseItem(
        id: 'id',
        refId: 'ref',
        type: 'quiz',
        orderIndex: 0,
        state: state,
        score: score,
      );

  group('studentTestActionLabel', () {
    test('null state → Начать →', () {
      expect(studentTestActionLabel(item()), 'Начать →');
    });

    test('not_started → Начать →', () {
      expect(studentTestActionLabel(item(state: 'not_started')), 'Начать →');
    });

    test('in_progress → Продолжить →', () {
      expect(studentTestActionLabel(item(state: 'in_progress')), 'Продолжить →');
    });

    test('waiting → Ожидает', () {
      expect(studentTestActionLabel(item(state: 'waiting')), 'Ожидает');
    });

    test('running → Идёт', () {
      expect(studentTestActionLabel(item(state: 'running')), 'Идёт');
    });

    test('completed → Завершён', () {
      expect(studentTestActionLabel(item(state: 'completed')), 'Завершён');
    });
  });
}
