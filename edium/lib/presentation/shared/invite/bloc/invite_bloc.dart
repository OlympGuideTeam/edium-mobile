import 'package:edium/domain/usecases/class/accept_invitation_usecase.dart';
import 'package:edium/domain/usecases/class/get_invitation_usecase.dart';
import 'package:edium/presentation/shared/invite/bloc/invite_event.dart';
import 'package:edium/presentation/shared/invite/bloc/invite_state.dart';
import 'package:edium/services/network/api_exception.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InviteBloc extends Bloc<InviteEvent, InviteState> {
  final GetInvitationUsecase _getInvitation;
  final AcceptInvitationUsecase _acceptInvitation;
  final String invitationId;

  InviteBloc({
    required GetInvitationUsecase getInvitation,
    required AcceptInvitationUsecase acceptInvitation,
    required this.invitationId,
  })  : _getInvitation = getInvitation,
        _acceptInvitation = acceptInvitation,
        super(const InviteInitial()) {
    on<InviteScreenOpened>(_onScreenOpened);
    on<InviteAcceptRequested>(_onAccept);
    on<InviteDeclineRequested>(_onDecline);
  }

  Future<void> _onScreenOpened(
    InviteScreenOpened event,
    Emitter<InviteState> emit,
  ) async {
    emit(const InviteLoading());
    try {
      final detail = await _getInvitation(invitationId: invitationId);
      emit(InviteLoaded(detail));
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        emit(const InviteUnauthenticated());
      } else {
        emit(InviteLoadError(e.message));
      }
    } catch (e) {
      emit(InviteLoadError(e.toString()));
    }
  }

  Future<void> _onAccept(
    InviteAcceptRequested event,
    Emitter<InviteState> emit,
  ) async {
    emit(const InviteAccepting());
    try {
      final classId = await _acceptInvitation(invitationId: invitationId);
      emit(InviteAcceptSuccess(classId));
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        emit(const InviteAlreadyMember());
      } else {
        emit(InviteAcceptError(e.message));
      }
    } catch (e) {
      emit(InviteAcceptError(e.toString()));
    }
  }

  void _onDecline(InviteDeclineRequested event, Emitter<InviteState> emit) {
    emit(const InviteDeclined());
  }
}
