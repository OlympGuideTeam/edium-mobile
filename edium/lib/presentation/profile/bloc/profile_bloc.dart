import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edium/domain/entities/user_statistic.dart';
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
      final user = await _getMe();
      UserStatistic statistic;
      try {
        statistic = await _getStatistic();
      } catch (_) {
        statistic = const UserStatistic(
          classTeacherCount: 0,
          studentCount: 0,
          courseTeacherCount: 0,
          courseStudentCount: 0,
          quizCountPassed: 0,
          avgQuizScore: 0,
          quizSessionsConducted: 0,
        );
      }
      emit(ProfileLoaded(user: user, statistic: statistic));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
