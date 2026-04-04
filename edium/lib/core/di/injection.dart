import 'package:edium/core/config/api_config.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/data/datasources/quiz/quiz_datasource.dart';
import 'package:edium/data/datasources/quiz/quiz_datasource_hive.dart';
import 'package:edium/data/datasources/quiz/quiz_datasource_impl.dart';
import 'package:edium/data/datasources/quiz_session/quiz_session_datasource.dart';
import 'package:edium/data/datasources/quiz_session/quiz_session_datasource_impl.dart';
import 'package:edium/data/datasources/quiz_session/quiz_session_datasource_hive.dart';
import 'package:edium/data/datasources/user/user_datasource.dart';
import 'package:edium/data/datasources/user/user_datasource_impl.dart';
import 'package:edium/data/datasources/user/user_datasource_mock.dart';
import 'package:edium/data/repositories/auth_repository_impl.dart';
import 'package:edium/data/repositories/auth_repository_mock.dart';
import 'package:edium/data/repositories/quiz_repository_impl.dart';
import 'package:edium/data/repositories/quiz_session_repository_impl.dart';
import 'package:edium/data/repositories/user_repository_impl.dart';
import 'package:edium/domain/repositories/auth_repository.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/repositories/quiz_session_repository.dart';
import 'package:edium/domain/repositories/user_repository.dart';
import 'package:edium/domain/usecases/auth/logout_usecase.dart';
import 'package:edium/domain/usecases/auth/send_otp_usecase.dart';
import 'package:edium/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:edium/domain/usecases/quiz/create_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz/get_quiz_results_usecase.dart';
import 'package:edium/domain/usecases/quiz/get_quizzes_usecase.dart';
import 'package:edium/domain/usecases/quiz/like_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz_session/complete_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz_session/get_my_sessions_usecase.dart';
import 'package:edium/domain/usecases/quiz_session/start_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz_session/submit_answer_usecase.dart';
import 'package:edium/domain/usecases/user/delete_account_usecase.dart';
import 'package:edium/domain/usecases/user/get_me_usecase.dart';
import 'package:edium/domain/usecases/user/get_user_statistic_usecase.dart';
import 'package:edium/domain/usecases/user/set_role_usecase.dart';
import 'package:edium/domain/usecases/user/update_profile_usecase.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/services/doorman_api_service/doorman_api_service.dart';
import 'package:edium/services/doorman_api_service/doorman_api_service_interface.dart';
import 'package:edium/services/network/dio_handler.dart';
import 'package:edium/services/token_storage/token_storage.dart';
import 'package:edium/services/token_storage/token_storage_interface.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {

  getIt.registerSingleton<ITokenStorage>(TokenStorage());
  getIt.registerSingleton<ProfileStorage>(ProfileStorage());


  await DioHandler.setup();

  getIt.registerSingleton<IDoormanApiService>(
    DoormanApiService(getIt<DioHandler>().dio),
  );

  if (ApiConfig.useMock) {
    getIt.registerLazySingleton<IUserDatasource>(
        () => UserDatasourceMock(getIt<ProfileStorage>()));
    getIt.registerLazySingleton<IQuizDatasource>(
        () => QuizDatasourceHive(getIt<ProfileStorage>()));
    getIt.registerLazySingleton<IQuizSessionDatasource>(
        () => QuizSessionDatasourceHive());
  } else {
    getIt.registerLazySingleton<IUserDatasource>(
        () => UserDatasourceImpl(getIt<DioHandler>().dio));
    getIt.registerLazySingleton<IQuizDatasource>(
        () => QuizDatasourceImpl(getIt<DioHandler>().dio));
    getIt.registerLazySingleton<IQuizSessionDatasource>(
        () => QuizSessionDatasourceImpl(getIt<DioHandler>().dio));
  }

  if (ApiConfig.useMock) {
    getIt.registerLazySingleton<IAuthRepository>(() => AuthRepositoryMock());
  } else {
    getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(
        doorman: getIt(),
        tokenStorage: getIt(),
      ),
    );
  }

  getIt.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<IQuizRepository>(
    () => QuizRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<IQuizSessionRepository>(
    () => QuizSessionRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton(() => SendOtpUsecase(getIt()));
  getIt.registerLazySingleton(() => VerifyOtpUsecase(getIt()));
  getIt.registerLazySingleton(() => LogoutUsecase(getIt()));
  getIt.registerLazySingleton(() => GetMeUsecase(getIt()));
  getIt.registerLazySingleton(() => SetRoleUsecase(getIt()));
  getIt.registerLazySingleton(() => GetUserStatisticUsecase(getIt()));
  getIt.registerLazySingleton(() => UpdateProfileUsecase(getIt()));
  getIt.registerLazySingleton(() => DeleteAccountUsecase(getIt()));
  getIt.registerLazySingleton(() => GetQuizzesUsecase(getIt()));
  getIt.registerLazySingleton(() => CreateQuizUsecase(getIt()));
  getIt.registerLazySingleton(() => LikeQuizUsecase(getIt()));
  getIt.registerLazySingleton(() => GetQuizResultsUsecase(getIt()));
  getIt.registerLazySingleton(() => StartQuizUsecase(getIt()));
  getIt.registerLazySingleton(() => SubmitAnswerUsecase(getIt()));
  getIt.registerLazySingleton(() => CompleteQuizUsecase(getIt()));
  getIt.registerLazySingleton(() => GetMySessionsUsecase(getIt()));

  getIt.registerSingleton<AuthBloc>(
    AuthBloc(
      sendOtp: getIt(),
      verifyOtp: getIt(),
      logout: getIt(),
      getMe: getIt(),
      profileStorage: getIt(),
    ),
  );
}
