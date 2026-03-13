import 'package:edium/domain/usecases/quiz/create_quiz_usecase.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_event.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateQuizBloc extends Bloc<CreateQuizEvent, CreateQuizState> {
  final CreateQuizUsecase _createQuiz;

  CreateQuizBloc(this._createQuiz) : super(const CreateQuizState()) {
    on<UpdateTitleEvent>((e, emit) => emit(state.copyWith(title: e.title)));
    on<UpdateSubjectEvent>((e, emit) => emit(state.copyWith(subject: e.subject)));
    on<UpdateSettingsEvent>(
        (e, emit) => emit(state.copyWith(settings: e.settings)));
    on<AddQuestionEvent>((e, emit) =>
        emit(state.copyWith(questions: [...state.questions, e.question])));
    on<RemoveQuestionEvent>((e, emit) {
      final updated = List<Map<String, dynamic>>.from(state.questions)
        ..removeAt(e.index);
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
    emit(state.copyWith(isSubmitting: true));
    try {
      await _createQuiz(
        title: state.title,
        subject: state.subject,
        settings: state.settings,
        questions: state.questions,
      );
      emit(state.copyWith(isSubmitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }
}
