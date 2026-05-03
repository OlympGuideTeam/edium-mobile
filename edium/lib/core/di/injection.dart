import 'package:edium/core/config/api_config.dart';
import 'package:edium/core/router/app_router.dart' show resetAppRouterAfterGetItClear;
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/data/datasources/live/live_datasource.dart';
import 'package:edium/data/datasources/live/live_datasource_impl.dart';
import 'package:edium/data/datasources/live/live_datasource_mock.dart';
import 'package:edium/data/repositories/live_repository_impl.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/services/live_ws/live_ws_service.dart';
import 'package:edium/data/datasources/attempt_cache/attempt_cache_datasource.dart';
import 'package:edium/data/datasources/attempt_cache/attempt_cache_datasource_hive.dart';
import 'package:edium/data/datasources/class/class_datasource.dart';
import 'package:edium/data/datasources/class/class_datasource_impl.dart';
import 'package:edium/data/datasources/class/class_datasource_mock.dart';
import 'package:edium/data/datasources/library_quiz/library_quiz_datasource.dart';
import 'package:edium/data/datasources/library_quiz/library_quiz_datasource_impl.dart';
import 'package:edium/data/datasources/library_quiz/library_quiz_datasource_mock.dart';
import 'package:edium/data/datasources/quiz/quiz_datasource.dart';
import 'package:edium/data/datasources/quiz/quiz_datasource_hive.dart';
import 'package:edium/data/datasources/quiz/quiz_datasource_impl.dart';
import 'package:edium/data/datasources/quiz_session/quiz_session_datasource.dart';
import 'package:edium/data/datasources/quiz_session/quiz_session_datasource_impl.dart';
import 'package:edium/data/datasources/quiz_session/quiz_session_datasource_hive.dart';
import 'package:edium/data/datasources/test_session/test_session_datasource.dart';
import 'package:edium/data/datasources/test_session/test_session_datasource_impl.dart';
import 'package:edium/data/datasources/test_session/test_session_datasource_mock.dart';
import 'package:edium/data/datasources/user/user_datasource.dart';
import 'package:edium/data/datasources/user/user_datasource_impl.dart';
import 'package:edium/data/datasources/user/user_datasource_mock.dart';
import 'package:edium/data/repositories/auth_repository_impl.dart';
import 'package:edium/data/repositories/auth_repository_mock.dart';
import 'package:edium/data/repositories/class_repository_impl.dart';
import 'package:edium/data/repositories/library_quiz_repository_impl.dart';
import 'package:edium/data/repositories/quiz_repository_impl.dart';
import 'package:edium/data/repositories/quiz_session_repository_impl.dart';
import 'package:edium/data/repositories/test_session_repository_impl.dart';
import 'package:edium/data/repositories/user_repository_impl.dart';
import 'package:edium/domain/repositories/auth_repository.dart';
import 'package:edium/domain/repositories/class_repository.dart';
import 'package:edium/domain/repositories/library_quiz_repository.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/repositories/quiz_session_repository.dart';
import 'package:edium/domain/repositories/test_session_repository.dart';
import 'package:edium/domain/repositories/user_repository.dart';
import 'package:edium/domain/usecases/auth/logout_usecase.dart';
import 'package:edium/domain/usecases/auth/register_usecase.dart';
import 'package:edium/domain/usecases/auth/send_otp_usecase.dart';
import 'package:edium/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:edium/domain/usecases/test_session/finish_attempt_usecase.dart' as test_session_finish;
import 'package:edium/domain/usecases/test_session/get_attempt_review_usecase.dart';
import 'package:edium/domain/usecases/test_session/get_test_session_meta_usecase.dart';
import 'package:edium/domain/usecases/test_session/list_session_attempts_usecase.dart';
import 'package:edium/domain/usecases/test_session/persist_answer_locally_usecase.dart';
import 'package:edium/domain/usecases/test_session/start_or_resume_attempt_usecase.dart';
import 'package:edium/domain/usecases/test_session/grade_submission_usecase.dart';
import 'package:edium/domain/usecases/test_session/complete_attempt_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/create_attempt_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/finish_attempt_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/get_attempt_result_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/get_public_quizzes_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/get_quiz_for_student_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/submit_attempt_answer_usecase.dart';
import 'package:edium/domain/usecases/quiz/create_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/domain/usecases/quiz/get_quiz_results_usecase.dart';
import 'package:edium/domain/usecases/quiz/get_quizzes_usecase.dart';
import 'package:edium/domain/usecases/quiz/like_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz_session/complete_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz_session/get_my_sessions_usecase.dart';
import 'package:edium/domain/usecases/quiz_session/start_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz_session/submit_answer_usecase.dart';
import 'package:edium/data/datasources/course/course_datasource.dart';
import 'package:edium/data/datasources/course/course_datasource_impl.dart';
import 'package:edium/data/datasources/course/course_datasource_mock.dart';
import 'package:edium/data/repositories/course_repository_impl.dart';
import 'package:edium/domain/repositories/course_repository.dart';
import 'package:edium/domain/usecases/course/create_course_usecase.dart';
import 'package:edium/domain/usecases/course/create_module_usecase.dart';
import 'package:edium/domain/usecases/course/get_course_detail_usecase.dart';
import 'package:edium/domain/usecases/course/get_course_sheet_usecase.dart';
import 'package:edium/domain/usecases/course/get_module_detail_usecase.dart';
import 'package:edium/domain/usecases/class/create_class_usecase.dart';
import 'package:edium/domain/usecases/class/delete_class_usecase.dart';
import 'package:edium/domain/usecases/class/delete_course_usecase.dart';
import 'package:edium/domain/usecases/class/get_class_detail_usecase.dart';
import 'package:edium/data/datasources/invitation/invitation_datasource.dart';
import 'package:edium/data/datasources/invitation/invitation_datasource_impl.dart';
import 'package:edium/data/datasources/invitation/invitation_datasource_mock.dart';
import 'package:edium/data/repositories/invitation_repository_impl.dart';
import 'package:edium/domain/repositories/invitation_repository.dart';
import 'package:edium/domain/usecases/class/accept_invitation_usecase.dart';
import 'package:edium/domain/usecases/class/get_invitation_usecase.dart';
import 'package:edium/domain/usecases/class/get_invite_link_usecase.dart';
import 'package:edium/domain/usecases/class/get_my_classes_usecase.dart';
import 'package:edium/domain/usecases/class/remove_member_usecase.dart';
import 'package:edium/domain/usecases/class/update_class_usecase.dart';
import 'package:edium/domain/usecases/user/delete_account_usecase.dart';
import 'package:edium/domain/usecases/user/get_me_usecase.dart';
import 'package:edium/domain/usecases/user/get_user_statistic_usecase.dart';
import 'package:edium/domain/usecases/live/get_active_lobby_usecase.dart';
import 'package:edium/domain/usecases/user/set_role_usecase.dart';
import 'package:edium/domain/usecases/user/update_profile_usecase.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/services/doorman_api_service/doorman_api_service.dart';
import 'package:edium/services/doorman_api_service/doorman_api_service_interface.dart';
import 'package:edium/services/herald_api_service/herald_api_service.dart';
import 'package:edium/services/herald_api_service/herald_api_service_interface.dart';
import 'package:edium/services/herald_api_service/herald_api_service_mock.dart';
import 'package:edium/services/network/dio_handler.dart';
import 'package:edium/services/navigation_block_service/navigation_block_service.dart';
import 'package:edium/services/notification_service/deep_link_service.dart';
import 'package:edium/services/notification_service/notification_service.dart';
import 'package:edium/services/screen_protection/screen_protection_service.dart';
import 'package:edium/services/token_storage/token_storage.dart';
import 'package:edium/services/token_storage/token_storage_interface.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> reinitializeDependencies(AppEnvironment env) async {
  ApiConfig.environment = env;
  await ProfileStorage.saveEnvironment(env);
  final notificationService = getIt<NotificationService>();
  final deepLinkService = getIt<DeepLinkService>();
  await getIt.reset();
  resetAppRouterAfterGetItClear();
  await initializeDependencies(
    notificationService: notificationService,
    deepLinkService: deepLinkService,
  );
  getIt<AuthBloc>().add(const AppStarted());
}

Future<void> initializeDependencies({
  NotificationService? notificationService,
  DeepLinkService? deepLinkService,
}) async {

  getIt.registerSingleton<ITokenStorage>(TokenStorage());
  getIt.registerSingleton<ProfileStorage>(ProfileStorage());
  getIt.registerSingleton<NotificationService>(notificationService ?? NotificationService());
  getIt.registerSingleton<DeepLinkService>(deepLinkService ?? DeepLinkService());
  getIt.registerLazySingleton<NavigationBlockService>(() => NavigationBlockService());
  getIt.registerLazySingleton<ScreenProtectionService>(() => ScreenProtectionService());


  await DioHandler.setup();

  getIt.registerSingleton<IDoormanApiService>(
    DoormanApiService(getIt<DioHandler>().dio),
  );
  if (ApiConfig.useMock) {
    getIt.registerSingleton<IHeraldApiService>(HeraldApiServiceMock());
  } else {
    getIt.registerSingleton<IHeraldApiService>(
      HeraldApiService(getIt<DioHandler>().dio),
    );
  }

  if (ApiConfig.useMock) {
    getIt.registerLazySingleton<IUserDatasource>(
        () => UserDatasourceMock(getIt<ProfileStorage>()));
    getIt.registerLazySingleton<IQuizDatasource>(
        () => QuizDatasourceHive(getIt<ProfileStorage>()));
    getIt.registerLazySingleton<IQuizSessionDatasource>(
        () => QuizSessionDatasourceHive());
    getIt.registerLazySingleton<ILibraryQuizDatasource>(
        () => LibraryQuizDatasourceMock());
    getIt.registerLazySingleton<IClassDatasource>(
        () => ClassDatasourceMock());
    getIt.registerLazySingleton<IInvitationDatasource>(
        () => InvitationDatasourceMock());
    getIt.registerLazySingleton<ICourseDatasource>(
        () => CourseDatasourceMock(getIt<ProfileStorage>()));
    getIt.registerLazySingleton<ITestSessionDatasource>(
        () => TestSessionDatasourceMock());
  } else {
    getIt.registerLazySingleton<IUserDatasource>(
        () => UserDatasourceImpl(getIt<DioHandler>().dio));
    getIt.registerLazySingleton<IQuizDatasource>(
        () => QuizDatasourceImpl(getIt<DioHandler>().dio));
    getIt.registerLazySingleton<IQuizSessionDatasource>(
        () => QuizSessionDatasourceImpl(getIt<DioHandler>().dio));
    getIt.registerLazySingleton<ILibraryQuizDatasource>(
        () => LibraryQuizDatasourceImpl(getIt<DioHandler>().dio));
    getIt.registerLazySingleton<IClassDatasource>(
        () => ClassDatasourceImpl(getIt<DioHandler>().dio));
    getIt.registerLazySingleton<IInvitationDatasource>(
        () => InvitationDatasourceImpl(getIt<DioHandler>().dio));
    getIt.registerLazySingleton<ICourseDatasource>(
        () => CourseDatasourceImpl(getIt<DioHandler>().dio));
    getIt.registerLazySingleton<ITestSessionDatasource>(
        () => TestSessionDatasourceImpl(getIt<DioHandler>().dio));
  }

  getIt.registerLazySingleton<IAttemptCacheDatasource>(
      () => AttemptCacheDatasourceHive());

  if (ApiConfig.useMock) {
    getIt.registerLazySingleton<IAuthRepository>(() => AuthRepositoryMock(getIt()));
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
  getIt.registerLazySingleton<ILibraryQuizRepository>(
    () => LibraryQuizRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<IClassRepository>(
    () => ClassRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<IInvitationRepository>(
    () => InvitationRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<ICourseRepository>(
    () => CourseRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<ITestSessionRepository>(
    () => TestSessionRepositoryImpl(
      datasource: getIt(),
      cache: getIt(),
    ),
  );

  getIt.registerLazySingleton(() => SendOtpUsecase(getIt()));
  getIt.registerLazySingleton(() => VerifyOtpUsecase(getIt()));
  getIt.registerLazySingleton(() => RegisterUsecase(getIt()));
  getIt.registerLazySingleton(() => LogoutUsecase(getIt()));
  getIt.registerLazySingleton(() => GetMeUsecase(getIt()));
  getIt.registerLazySingleton(() => SetRoleUsecase(getIt()));
  getIt.registerLazySingleton(() => GetUserStatisticUsecase(getIt()));
  getIt.registerLazySingleton(() => UpdateProfileUsecase(getIt()));
  getIt.registerLazySingleton(() => DeleteAccountUsecase(getIt()));
  getIt.registerLazySingleton(() => GetMyClassesUsecase(getIt()));
  getIt.registerLazySingleton(() => CreateClassUsecase(getIt()));
  getIt.registerLazySingleton(() => GetClassDetailUsecase(getIt()));
  getIt.registerLazySingleton(() => UpdateClassUsecase(getIt()));
  getIt.registerLazySingleton(() => DeleteClassUsecase(getIt()));
  getIt.registerLazySingleton(() => DeleteCourseUsecase(getIt()));
  getIt.registerLazySingleton(() => CreateCourseUsecase(getIt()));
  getIt.registerLazySingleton(() => CreateModuleUsecase(getIt()));
  getIt.registerLazySingleton(() => GetCourseDetailUsecase(getIt()));
  getIt.registerLazySingleton(() => GetModuleDetailUsecase(getIt()));
  getIt.registerLazySingleton(() => GetCourseSheetUsecase(getIt()));
  getIt.registerLazySingleton(() => RemoveMemberUsecase(getIt()));
  getIt.registerLazySingleton(() => GetInviteLinkUsecase(getIt()));
  getIt.registerLazySingleton(() => GetInvitationUsecase(getIt()));
  getIt.registerLazySingleton(() => AcceptInvitationUsecase(getIt()));
  getIt.registerLazySingleton(() => GetQuizzesUsecase(getIt()));
  getIt.registerLazySingleton(() => CreateQuizUsecase(getIt()));
  getIt.registerLazySingleton(() => CreateSessionUsecase(getIt()));
  getIt.registerLazySingleton(() => LikeQuizUsecase(getIt()));
  getIt.registerLazySingleton(() => GetQuizResultsUsecase(getIt()));
  getIt.registerLazySingleton(() => StartQuizUsecase(getIt()));
  getIt.registerLazySingleton(() => SubmitAnswerUsecase(getIt()));
  getIt.registerLazySingleton(() => CompleteQuizUsecase(getIt()));
  getIt.registerLazySingleton(() => GetMySessionsUsecase(getIt()));
  getIt.registerLazySingleton(() => GetPublicQuizzesUsecase(getIt()));
  getIt.registerLazySingleton(() => GetQuizForStudentUsecase(getIt()));
  getIt.registerLazySingleton(() => CreateAttemptUsecase(getIt()));
  getIt.registerLazySingleton(() => SubmitAttemptAnswerUsecase(getIt()));
  getIt.registerLazySingleton(() => FinishAttemptUsecase(getIt()));
  getIt.registerLazySingleton(() => GetAttemptResultUsecase(getIt()));
  getIt.registerLazySingleton(() => GetTestSessionMetaUsecase(getIt()));
  getIt.registerLazySingleton(() => StartOrResumeAttemptUsecase(getIt()));
  getIt.registerLazySingleton(() => PersistAnswerLocallyUsecase(getIt()));
  getIt.registerLazySingleton(
      () => test_session_finish.FinishTestAttemptUsecase(getIt()));
  getIt.registerLazySingleton(() => ListSessionAttemptsUsecase(getIt()));
  getIt.registerLazySingleton(() => GetAttemptReviewUsecase(getIt()));
  getIt.registerLazySingleton(() => GradeSubmissionUsecase(getIt()));
  getIt.registerLazySingleton(() => CompleteAttemptUsecase(getIt()));

  // Live quiz
  if (ApiConfig.useMock) {
    getIt.registerLazySingleton<ILiveDatasource>(
      () => LiveDatasourceMock(),
    );
  } else {
    getIt.registerLazySingleton<ILiveDatasource>(
      () => LiveDatasourceImpl(getIt<DioHandler>().dio),
    );
  }
  getIt.registerLazySingleton<ILiveRepository>(
    () => LiveRepositoryImpl(getIt()),
  );
  getIt.registerFactory<LiveWsService>(() => LiveWsService());
  getIt.registerLazySingleton(() => GetActiveLobbyUsecase(
    classRepo: getIt(),
    courseRepo: getIt(),
    liveRepo: getIt(),
  ));

  getIt.registerSingleton<AuthBloc>(
    AuthBloc(
      sendOtp: getIt(),
      verifyOtp: getIt(),
      register: getIt(),
      logout: getIt(),
      getMe: getIt(),
      profileStorage: getIt(),
      dioHandler: getIt(),
      notificationService: getIt(),
      heraldApiService: getIt(),
      deepLinkService: getIt(),
    ),
  );
}
