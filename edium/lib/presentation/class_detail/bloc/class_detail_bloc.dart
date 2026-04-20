import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/services/network/api_exception.dart';
import 'package:edium/domain/usecases/class/delete_class_usecase.dart';
import 'package:edium/domain/usecases/class/delete_course_usecase.dart';
import 'package:edium/domain/usecases/class/get_class_detail_usecase.dart';
import 'package:edium/domain/usecases/class/get_invite_link_usecase.dart';
import 'package:edium/domain/usecases/class/remove_member_usecase.dart';
import 'package:edium/domain/usecases/class/update_class_usecase.dart';
import 'package:edium/presentation/class_detail/bloc/class_detail_event.dart';
import 'package:edium/presentation/class_detail/bloc/class_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassDetailBloc extends Bloc<ClassDetailEvent, ClassDetailState> {
  final GetClassDetailUsecase _getClassDetail;
  final UpdateClassUsecase _updateClass;
  final DeleteClassUsecase _deleteClass;
  final DeleteCourseUsecase _deleteCourse;
  final RemoveMemberUsecase _removeMember;
  final GetInviteLinkUsecase _getInviteLink;
  final String classId;

  ClassDetailBloc({
    required GetClassDetailUsecase getClassDetail,
    required UpdateClassUsecase updateClass,
    required DeleteClassUsecase deleteClass,
    required DeleteCourseUsecase deleteCourse,
    required RemoveMemberUsecase removeMember,
    required GetInviteLinkUsecase getInviteLink,
    required this.classId,
  })  : _getClassDetail = getClassDetail,
        _updateClass = updateClass,
        _deleteClass = deleteClass,
        _deleteCourse = deleteCourse,
        _removeMember = removeMember,
        _getInviteLink = getInviteLink,
        super(const ClassDetailInitial()) {
    on<LoadClassDetailEvent>(_onLoad);
    on<UpdateClassTitleEvent>(_onUpdateTitle);
    on<DeleteClassEvent>(_onDelete);
    on<DeleteCourseEvent>(_onDeleteCourse);
    on<RemoveMemberEvent>(_onRemoveMember);
    on<GetInviteLinkEvent>(_onGetInviteLink);
  }

  ClassDetail? get _currentDetail {
    final s = state;
    if (s is ClassDetailLoaded) return s.classDetail;
    if (s is ClassTitleUpdated) return s.classDetail;
    if (s is MemberRemoved) return s.classDetail;
    if (s is CourseDeleted) return s.classDetail;
    if (s is InviteLinkCopied) return s.classDetail;
    if (s is ClassDetailActionError) return s.classDetail;
    return null;
  }

  Future<void> _onLoad(
    LoadClassDetailEvent event,
    Emitter<ClassDetailState> emit,
  ) async {
    emit(const ClassDetailLoading());
    try {
      final detail = await _getClassDetail(classId: event.classId);
      emit(ClassDetailLoaded(detail));
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        emit(const ClassNotFound());
      } else {
        emit(ClassDetailError(e.message));
      }
    } catch (e) {
      emit(ClassDetailError(e.toString()));
    }
  }

  Future<void> _onUpdateTitle(
    UpdateClassTitleEvent event,
    Emitter<ClassDetailState> emit,
  ) async {
    final detail = _currentDetail;
    if (detail == null) return;
    try {
      await _updateClass(classId: classId, title: event.newTitle);
      final updated = detail.copyWith(title: event.newTitle);
      emit(ClassTitleUpdated(updated));
    } catch (e) {
      emit(ClassDetailActionError(e.toString(), detail));
    }
  }

  Future<void> _onDelete(
    DeleteClassEvent event,
    Emitter<ClassDetailState> emit,
  ) async {
    final detail = _currentDetail;
    if (detail == null) return;
    try {
      await _deleteClass(classId: classId);
      emit(const ClassDeleted());
    } catch (e) {
      emit(ClassDetailActionError(e.toString(), detail));
    }
  }

  Future<void> _onDeleteCourse(
    DeleteCourseEvent event,
    Emitter<ClassDetailState> emit,
  ) async {
    final detail = _currentDetail;
    if (detail == null) return;
    try {
      await _deleteCourse(courseId: event.courseId);
      final updated = detail.copyWith(
        courses: detail.courses.where((c) => c.id != event.courseId).toList(),
      );
      emit(CourseDeleted(updated));
    } catch (e) {
      emit(ClassDetailActionError(e.toString(), detail));
    }
  }

  Future<void> _onRemoveMember(
    RemoveMemberEvent event,
    Emitter<ClassDetailState> emit,
  ) async {
    final detail = _currentDetail;
    if (detail == null) return;
    try {
      await _removeMember(classId: classId, userId: event.userId);
      final updated = detail.copyWith(
        students: detail.students.where((s) => s.id != event.userId).toList(),
      );
      emit(MemberRemoved(updated, event.userId));
    } catch (e) {
      emit(ClassDetailActionError(e.toString(), detail));
    }
  }

  Future<void> _onGetInviteLink(
    GetInviteLinkEvent event,
    Emitter<ClassDetailState> emit,
  ) async {
    final detail = _currentDetail;
    if (detail == null) return;
    try {
      final link = await _getInviteLink(classId: classId, role: event.role);
      emit(InviteLinkCopied(detail, link));
    } catch (e) {
      emit(ClassDetailActionError(e.toString(), detail));
    }
  }
}
