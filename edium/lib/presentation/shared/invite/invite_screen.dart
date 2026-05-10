import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/invitation_detail.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/usecases/class/accept_invitation_usecase.dart';
import 'package:edium/domain/usecases/class/get_invitation_usecase.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/shared/invite/bloc/invite_bloc.dart';
import 'package:edium/presentation/shared/invite/bloc/invite_event.dart';
import 'package:edium/presentation/shared/invite/bloc/invite_state.dart';
import 'package:edium/services/notification_service/deep_link_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'invite_screen_invite_view.dart';
part 'invite_screen_auth_invite_body.dart';
part 'invite_screen_unauth_invite_body.dart';
part 'invite_screen_already_member_body.dart';
part 'invite_screen_loading_body.dart';
part 'invite_screen_error_body.dart';
part 'invite_screen_primary_button.dart';
part 'invite_screen_secondary_button.dart';


class InviteScreen extends StatelessWidget {
  final String invitationId;

  const InviteScreen({super.key, required this.invitationId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InviteBloc(
        getInvitation: getIt<GetInvitationUsecase>(),
        acceptInvitation: getIt<AcceptInvitationUsecase>(),
        invitationId: invitationId,
      ),
      child: _InviteView(invitationId: invitationId),
    );
  }
}

