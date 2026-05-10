import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'live_library_state.dart';
part 'live_library_cubit_live_library_initial.dart';
part 'live_library_cubit_live_library_loading.dart';
part 'live_library_cubit_live_library_loaded.dart';
part 'live_library_cubit_live_library_error.dart';

class LiveLibraryCubit extends Cubit<LiveLibraryState> {
  final ILiveRepository _repo;

  LiveLibraryCubit(this._repo) : super(const LiveLibraryInitial());

  Future<void> load() async {
    emit(const LiveLibraryLoading());
    try {
      final sessions = await _repo.getMyLiveSessions();
      emit(LiveLibraryLoaded(sessions));
    } catch (e) {
      emit(LiveLibraryError(e.toString()));
    }
  }
}
