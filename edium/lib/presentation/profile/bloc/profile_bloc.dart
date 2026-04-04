import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edium/domain/usecases/user/get_me_usecase.dart';
import 'package:edium/domain/usecases/user/get_user_statistic_usecase.dart';
import 'package:edium/presentation/profile/bloc/profile_event.dart';
import 'package:edium/presentation/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetMeUsecase _getMe;
  final GetUserStatisticUsecase _getStatistic;

  ProfileBloc({
    required GetMeUsecase getMe,
    required GetUserStatisticUsecase getStatistic,
  })  : _getMe = getMe,
        _getStatistic = getStatistic,
        super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final results = await Future.wait([
        _getMe(),
        _getStatistic(),
      ]);
      emit(ProfileLoaded(
        user: results[0] as dynamic,
        statistic: results[1] as dynamic,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
