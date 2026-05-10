part of 'profile_state.dart';

class ProfileLoaded extends ProfileState {
  final User user;
  final UserStatistic statistic;

  const ProfileLoaded({required this.user, required this.statistic});
}

