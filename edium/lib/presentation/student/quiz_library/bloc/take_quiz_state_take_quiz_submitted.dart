part of 'take_quiz_state.dart';

class TakeQuizSubmitted extends TakeQuizState {
  final String attemptId;
  const TakeQuizSubmitted({required this.attemptId});
  @override
  List<Object?> get props => [attemptId];
}

