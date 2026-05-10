part of 'live_student_event.dart';

class LiveStudentSubmitAnswer extends LiveStudentEvent {
  final String questionId;
  final Map<String, dynamic> answerData;

  LiveStudentSubmitAnswer({
    required this.questionId,
    required this.answerData,
  });
}

