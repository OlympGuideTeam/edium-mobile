part of 'create_quiz_event.dart';

class SubmitQuizEvent extends CreateQuizEvent {

  final bool saveOnly;

  final String? courseId;

  final String? moduleId;
  const SubmitQuizEvent({this.saveOnly = false, this.courseId, this.moduleId});
  @override
  List<Object?> get props => [saveOnly, courseId, moduleId];
}

