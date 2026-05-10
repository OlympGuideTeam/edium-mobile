part of 'take_quiz_state.dart';

class TakeQuizError extends TakeQuizState {
  final String message;
  const TakeQuizError(this.message);
  @override
  List<Object?> get props => [message];
}

