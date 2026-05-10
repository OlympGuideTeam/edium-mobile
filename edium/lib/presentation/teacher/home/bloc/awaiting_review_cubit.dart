import 'package:edium/domain/entities/awaiting_review_session.dart';
import 'package:edium/domain/usecases/test_session/get_awaiting_review_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'awaiting_review_state.dart';
part 'awaiting_review_cubit_awaiting_review_initial.dart';
part 'awaiting_review_cubit_awaiting_review_loading.dart';
part 'awaiting_review_cubit_awaiting_review_loaded.dart';
part 'awaiting_review_cubit_awaiting_review_error.dart';

class AwaitingReviewCubit extends Cubit<AwaitingReviewState> {
  final GetAwaitingReviewUsecase _usecase;

  AwaitingReviewCubit(this._usecase) : super(const AwaitingReviewInitial());

  Future<void> load() async {
    emit(const AwaitingReviewLoading());
    try {
      final sessions = await _usecase();
      emit(AwaitingReviewLoaded(sessions));
    } catch (e) {
      emit(AwaitingReviewError(e.toString()));
    }
  }
}
