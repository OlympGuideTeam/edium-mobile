import 'package:edium/domain/usecases/class/accept_invitation_usecase.dart';
import 'package:edium/presentation/shared/invite/bloc/invite_event.dart';
import 'package:edium/presentation/shared/invite/bloc/invite_state.dart';
import 'package:edium/services/network/api_exception.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InviteBloc extends Bloc<InviteEvent, InviteState> {
  final AcceptInvitationUsecase _acceptInvitation;
  final String invitationId;

  InviteBloc({
    required AcceptInvitationUsecase acceptInvitation,
    required this.invitationId,
  })  : _acceptInvitation = acceptInvitation,
        super(const InviteInitial()) {
    on<InviteScreenOpened>(_onScreenOpened);
    on<InviteAcceptRequested>(_onAccept);
  }

  void _onScreenOpened(InviteScreenOpened event, Emitter<InviteState> emit) {
    // Screen decides whether to auto-accept based on auth state
  }

  Future<void> _onAccept(
    InviteAcceptRequested event,
    Emitter<InviteState> emit,
  ) async {
    emit(const InviteAccepting());
    try {
      await _acceptInvitation(invitationId: invitationId);
      emit(const InviteAcceptSuccess());
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
}
