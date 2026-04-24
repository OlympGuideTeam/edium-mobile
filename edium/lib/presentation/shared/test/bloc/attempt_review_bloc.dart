import 'package:edium/domain/usecases/test_session/get_attempt_review_usecase.dart';
import 'package:edium/presentation/shared/test/bloc/attempt_review_event.dart';
import 'package:edium/presentation/shared/test/bloc/attempt_review_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttemptReviewBloc
    extends Bloc<AttemptReviewEvent, AttemptReviewBlocState> {
  final GetAttemptReviewUsecase _get;

  AttemptReviewBloc(this._get) : super(const AttemptReviewInitial()) {
    on<LoadAttemptReviewEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadAttemptReviewEvent event,
    Emitter<AttemptReviewBlocState> emit,
  ) async {
    emit(const AttemptReviewLoading());
    try {
      final r = await _get(event.attemptId);
      emit(AttemptReviewLoaded(r));
    } catch (e) {
      emit(AttemptReviewError(e.toString()));
    }
  }
}
