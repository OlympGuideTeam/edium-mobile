import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/entities/user_statistic.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final User user;
  final UserStatistic statistic;

  const ProfileLoaded({required this.user, required this.statistic});
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);
}
