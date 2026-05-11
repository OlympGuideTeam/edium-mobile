import 'dart:async';

import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/entities/student_dashboard.dart';
import 'package:edium/domain/repositories/class_repository.dart';
import 'package:edium/domain/usecases/student_dashboard/get_student_dashboard_usecase.dart';
import 'package:edium/services/course_live_notify/course_live_notify_service.dart';
import 'package:edium/services/token_storage/token_storage_interface.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'student_dashboard_state.dart';
part 'student_dashboard_cubit_student_dashboard_initial.dart';
part 'student_dashboard_cubit_student_dashboard_loading.dart';
part 'student_dashboard_cubit_student_dashboard_loaded.dart';
part 'student_dashboard_cubit_student_dashboard_error.dart';

class StudentDashboardCubit extends Cubit<StudentDashboardState> {
  final GetStudentDashboardUsecase _usecase;
  final CourseLiveNotifyService _notifyService;
  final ITokenStorage _tokenStorage;
  final IClassRepository _classRepo;

  StreamSubscription<List<CourseLiveItem>>? _liveItemsSub;

  StudentDashboardCubit(
    this._usecase,
    this._notifyService,
    this._tokenStorage,
    this._classRepo,
  ) : super(const StudentDashboardInitial());

  Future<void> load() async {
    emit(const StudentDashboardLoading());
    try {
      final dashboard = await _usecase();
      emit(StudentDashboardLoaded(dashboard));
    } catch (e) {
      emit(StudentDashboardError(e.toString()));
    }
    await _connectLiveNotify();
  }

  Future<void> refresh() => load();

  @override
  Future<void> close() async {
    await _liveItemsSub?.cancel();
    await _notifyService.disconnect();
    return super.close();
  }


  Future<void> _connectLiveNotify() async {
    await _liveItemsSub?.cancel();
    await _notifyService.disconnect();

    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) return;

      final courseIds = await _resolveCourseIds();
      if (courseIds.isEmpty) return;

      await _notifyService.connect(token, courseIds);

      _liveItemsSub = _notifyService.stream.listen((items) {
        _onLiveItems(items);
      });


      _onLiveItems(_notifyService.currentItems);
    } catch (e) {
      debugPrint('StudentDashboardCubit: live connect failed: $e');
    }
  }

  void _onLiveItems(List<CourseLiveItem> items) {
    final first = items.isNotEmpty ? items.first : null;
    final meta = first == null
        ? null
        : LiveSessionMeta(
            sessionId: first.sessionId,
            quizTemplateId: '',
            quizTitle: first.quizTitle,
            questionCount: 0,
            source: 'course',
            phase: LivePhase.lobby,
            questionTimeLimitSec: first.questionTimeLimitSec,
            isAnonymousAllowed: false,
            participantsCount: 0,
          );

    final current = state;
    if (current is StudentDashboardLoaded) {
      emit(StudentDashboardLoaded(current.dashboard, activeLive: meta));
    }
  }

  Future<List<String>> _resolveCourseIds() async {
    final classes = await _classRepo.getMyClasses(role: 'student');
    if (classes.isEmpty) return [];

    final courseIds = <String>[];
    for (final cls in classes) {
      try {
        final detail = await _classRepo.getClassDetail(classId: cls.id);
        courseIds.addAll(detail.courses.map((c) => c.id));
      } catch (_) {}
    }
    return courseIds;
  }
}
