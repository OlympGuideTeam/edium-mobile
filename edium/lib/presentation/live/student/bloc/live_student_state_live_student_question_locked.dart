part of 'live_student_state.dart';

class LiveStudentQuestionLocked extends LiveStudentState {
  final LiveQuestion question;
  final int questionIndex;
  final int questionTotal;
  final LiveCorrectAnswer correctAnswer;
  final LiveQuestionStats stats;
  final LiveStudentResult? myResult;
  final List<String>? wordCloud;
  final Map<String, dynamic>? myAnswer;

  LiveStudentQuestionLocked({
    required this.question,
    required this.questionIndex,
    required this.questionTotal,
    required this.correctAnswer,
    required this.stats,
    this.myResult,
    this.wordCloud,
    this.myAnswer,
  });
}

