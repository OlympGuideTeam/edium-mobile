import 'package:edium/data/models/attempt_cache_entry.dart';
import 'package:edium/data/models/quiz_attempt_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttemptCacheEntry', () {
    test('encode/decode round-trip сохраняет все поля', () {
      final entry = AttemptCacheEntry(
        sessionId: 'sess-1',
        attemptId: 'att-1',
        questions: const [
          QuizQuestionForStudentModel(
            id: 'q1',
            type: 'single_choice',
            text: 'Какой тип?',
            maxScore: 10,
          ),
        ],
        answers: {
          'q1': {'selected_option_id': 'opt-a'},
        },
        startedAt: DateTime.utc(2026, 4, 22, 10),
        expiresAt: DateTime.utc(2026, 4, 23, 10),
      );

      final restored = AttemptCacheEntry.decode(entry.encode());

      expect(restored.sessionId, 'sess-1');
      expect(restored.attemptId, 'att-1');
      expect(restored.questions, hasLength(1));
      expect(restored.questions.first.id, 'q1');
      expect(restored.answers['q1'], {'selected_option_id': 'opt-a'});
      expect(restored.startedAt, DateTime.utc(2026, 4, 22, 10));
      expect(restored.expiresAt, DateTime.utc(2026, 4, 23, 10));
    });

    test('isExpired = true если expiresAt прошёл', () {
      final e = AttemptCacheEntry(
        sessionId: 's',
        attemptId: 'a',
        questions: const [],
        answers: {},
        startedAt: DateTime.utc(2026, 1, 1),
        expiresAt: DateTime.utc(2026, 1, 2),
      );
      expect(e.isExpired(DateTime.utc(2026, 1, 3)), isTrue);
      expect(e.isExpired(DateTime.utc(2026, 1, 1, 12)), isFalse);
    });

    test('isExpired = false если expiresAt=null', () {
      final e = AttemptCacheEntry(
        sessionId: 's',
        attemptId: 'a',
        questions: const [],
        answers: {},
        startedAt: DateTime.utc(2026, 1, 1),
      );
      expect(e.isExpired(DateTime.utc(2030, 1, 1)), isFalse);
    });
  });
}
