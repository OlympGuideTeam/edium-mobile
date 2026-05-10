part of 'live_teacher_screen.dart';

class _QuestionDistribution extends StatelessWidget {
  final LiveQuestion question;
  final LiveQuestionStats? stats;
  final bool showCorrect;
  final LiveCorrectAnswer? correctAnswer;

  const _QuestionDistribution({
    required this.question,
    required this.stats,
    required this.showCorrect,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final type = question.type;
    final isChoice = type == QuestionType.singleChoice || type == QuestionType.multiChoice;

    if (isChoice) {
      return _ChoiceDistribution(
        stats: stats is LiveChoiceStats ? stats as LiveChoiceStats : null,
        options: question.options,
        showCorrect: showCorrect,
        correctAnswer: correctAnswer,
        isMulti: type == QuestionType.multiChoice,
      );
    }

    if (type == QuestionType.withGivenAnswer) {
      return _GivenAnswerDistribution(
        stats: stats is LiveBinaryStats ? stats as LiveBinaryStats : null,
      );
    }

    return _BinaryDistribution(
      stats: stats is LiveBinaryStats ? stats as LiveBinaryStats : null,
    );
  }
}

