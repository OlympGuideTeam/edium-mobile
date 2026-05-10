part of 'live_student_state.dart';

class LiveStudentQuestionActive extends LiveStudentState {
  final LiveQuestion question;
  final int questionIndex;
  final int questionTotal;
  final DateTime deadlineAt;
  final int timeLimitSec;
  final Map<String, dynamic>? myAnswer;

  LiveStudentQuestionActive({
    required this.question,
    required this.questionIndex,
    required this.questionTotal,
    required this.deadlineAt,
    required this.timeLimitSec,
    this.myAnswer,
  });

  bool get hasAnswered => myAnswer != null;

  LiveStudentQuestionActive copyWith({Map<String, dynamic>? myAnswer}) =>
      LiveStudentQuestionActive(
        question: question,
        questionIndex: questionIndex,
        questionTotal: questionTotal,
        deadlineAt: deadlineAt,
        timeLimitSec: timeLimitSec,
        myAnswer: myAnswer ?? this.myAnswer,
      );
}

