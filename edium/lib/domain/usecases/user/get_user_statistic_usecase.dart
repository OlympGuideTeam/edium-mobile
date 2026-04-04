import 'package:edium/domain/entities/user_statistic.dart';
import 'package:edium/domain/repositories/user_repository.dart';

class GetUserStatisticUsecase {
  final IUserRepository _repository;

  GetUserStatisticUsecase(this._repository);

  Future<UserStatistic> call() => _repository.getStatistic();
}
