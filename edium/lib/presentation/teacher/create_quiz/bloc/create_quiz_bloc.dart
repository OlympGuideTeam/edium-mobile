import 'package:edium/domain/usecases/quiz/create_quiz_usecase.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_event.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateQuizBloc extends Bloc<CreateQuizEvent, CreateQuizState> {
  final CreateQuizUsecase _createQuiz;

  CreateQuizBloc(this._createQuiz) : super(const CreateQuizState()) {
    on<UpdateTitleEvent>((e, emit) => emit(state.copyWith(title: e.title)));
    on<UpdateDescriptionEvent>((e, emit) => emit(state.copyWith(description: e.description)));
    on<UpdateTotalTimeLimitEvent>((e, emit) => emit(
          e.seconds == null
              ? state.copyWith(clearTotalTimeLimit: true)
              : state.copyWith(totalTimeLimitSec: e.seconds),
        ));
    on<UpdateQuestionTimeLimitEvent>((e, emit) => emit(
          e.seconds == null
              ? state.copyWith(clearQuestionTimeLimit: true)
              : state.copyWith(questionTimeLimitSec: e.seconds),
        ));
    on<UpdateShuffleQuestionsEvent>(
        (e, emit) => emit(state.copyWith(shuffleQuestions: e.shuffle)));
    on<AddQuestionEvent>((e, emit) =>
        emit(state.copyWith(questions: [...state.questions, e.question])));
    on<RemoveQuestionEvent>((e, emit) {
      final updated = List<Map<String, dynamic>>.from(state.questions)
        ..removeAt(e.index);
      emit(state.copyWith(questions: updated));
    });
    on<ReplaceQuestionEvent>((e, emit) {
      final updated = List<Map<String, dynamic>>.from(state.questions);
      updated[e.index] = e.question;
      emit(state.copyWith(questions: updated));
    });
    on<SubmitQuizEvent>(_onSubmit);
    on<ResetCreateQuizEvent>((_, emit) => emit(const CreateQuizState()));
  }

  Future<void> _onSubmit(
    SubmitQuizEvent event,
    Emitter<CreateQuizState> emit,
  ) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _createQuiz(
        title: state.title,
        description: state.description.isEmpty ? null : state.description,
        totalTimeLimitSec: state.totalTimeLimitSec,
        questionTimeLimitSec: state.questionTimeLimitSec,
        shuffleQuestions: state.shuffleQuestions,
        questions: state.questions,
      );
      emit(state.copyWith(isSubmitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }
}
