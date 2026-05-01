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

class _InviteView extends StatefulWidget {
  final String invitationId;
  const _InviteView({required this.invitationId});

  @override
  State<_InviteView> createState() => _InviteViewState();
}

class _InviteViewState extends State<_InviteView> {
  bool get _isAuthenticated => getIt<AuthBloc>().state is AuthAuthenticated;

  @override
  void initState() {
    super.initState();
    context.read<InviteBloc>().add(const InviteScreenOpened());
  }

  void _navigateHome() {
    final authState = getIt<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final role = authState.user.role;
      if (role == UserRole.teacher) {
        context.go('/teacher/home');
      } else {
        context.go('/student/home');
      }
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InviteBloc, InviteState>(
      listener: (context, state) {
        if (state is InviteAcceptSuccess) {
          final authState = getIt<AuthBloc>().state;
          final homeRoute = authState is AuthAuthenticated && authState.user.role == UserRole.teacher
              ? '/teacher/home'
              : '/student/home';
          context.go(homeRoute);
          context.push('/class/${state.classId}');
        }
        if (state is InviteDeclined) {
          _navigateHome();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.mono25,
        body: SafeArea(
          child: BlocBuilder<InviteBloc, InviteState>(
            builder: (context, state) {
              if (state is InviteLoading || state is InviteAccepting) {
                return const _LoadingBody();
              }
              if (state is InviteAlreadyMember) {
                return _AlreadyMemberBody(onGoHome: _navigateHome);
              }
              if (state is InviteUnauthenticated) {
                return _UnauthInviteBody(
                  invitationId: widget.invitationId,
                  detail: null,
                );
              }
              if (state is InviteLoaded) {
                if (_isAuthenticated) {
                  return _AuthInviteBody(detail: state.detail);
                }
                return _UnauthInviteBody(
                  invitationId: widget.invitationId,
                  detail: state.detail,
                );
              }
              if (state is InviteLoadError) {
                return _ErrorBody(
                  message: state.message,
                  onRetry: () => context
                      .read<InviteBloc>()
                      .add(const InviteScreenOpened()),
                );
              }
              if (state is InviteAcceptError) {
                return _ErrorBody(
                  message: state.message,
                  onRetry: () => context
                      .read<InviteBloc>()
                      .add(const InviteAcceptRequested()),
                );
              }
              return const _LoadingBody();
            },
          ),
        ),
      ),
    );
  }
}

class _AuthInviteBody extends StatelessWidget {
  final InvitationDetail detail;
  const _AuthInviteBody({required this.detail});

  String get _roleLabel => detail.role == 'teacher' ? 'учитель' : 'ученик';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            ),
            child: const Icon(
              Icons.group_outlined,
              size: 32,
              color: AppColors.mono700,
            ),
          ),
          const SizedBox(height: 32),
          Text('Вас пригласили\nв класс', style: AppTextStyles.heading1),
          const SizedBox(height: 12),
          Text(
            detail.classTitle,
            style: AppTextStyles.body.copyWith(color: AppColors.mono900),
          ),
          const SizedBox(height: 4),
          Text(
            '${detail.studentCount} учеников · $_roleLabel',
            style: AppTextStyles.body.copyWith(color: AppColors.mono400),
          ),
          const Spacer(),
          _PrimaryButton(
            label: 'Принять',
            onTap: () => context.read<InviteBloc>().add(const InviteAcceptRequested()),
          ),
          const SizedBox(height: 16),
          _SecondaryButton(
            label: 'Отклонить',
            onTap: () => context.read<InviteBloc>().add(const InviteDeclineRequested()),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _UnauthInviteBody extends StatelessWidget {
  final String invitationId;
  final InvitationDetail? detail;
  const _UnauthInviteBody({required this.invitationId, required this.detail});

  String get _roleLabel => detail?.role == 'teacher' ? 'учитель' : 'ученик';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            ),
            child: const Icon(
              Icons.group_outlined,
              size: 32,
              color: AppColors.mono700,
            ),
          ),
          const SizedBox(height: 32),
          Text('Вас пригласили\nв класс', style: AppTextStyles.heading1),
          const SizedBox(height: 12),
          if (detail != null) ...[
            Text(
              detail!.classTitle,
              style: AppTextStyles.body.copyWith(color: AppColors.mono900),
            ),
            const SizedBox(height: 4),
            Text(
              '${detail!.studentCount} учеников · $_roleLabel',
              style: AppTextStyles.body.copyWith(color: AppColors.mono400),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Войдите в Edium, чтобы принять приглашение.',
            style: AppTextStyles.body.copyWith(color: AppColors.mono400),
          ),
          const Spacer(),
          _PrimaryButton(
            label: 'Войти и принять',
            onTap: () {
              getIt<DeepLinkService>().setPendingRoute(
                '/invite/$invitationId',
                role: detail?.role,
              );
              context.push('/phone');
            },
          ),
          const SizedBox(height: 16),
          _SecondaryButton(
            label: 'Не сейчас',
            onTap: () => context.go('/welcome'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _AlreadyMemberBody extends StatelessWidget {
  final VoidCallback onGoHome;
  const _AlreadyMemberBody({required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 32,
              color: AppColors.mono700,
            ),
          ),
          const SizedBox(height: 32),
          Text('Вы уже в классе', style: AppTextStyles.heading1),
          const SizedBox(height: 12),
          Text(
            'Вы уже являетесь участником этого класса.',
            style: AppTextStyles.body.copyWith(color: AppColors.mono400),
          ),
          const Spacer(),
          _PrimaryButton(label: 'На главную', onTap: onGoHome),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.mono700,
        strokeWidth: 2,
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 32,
              color: AppColors.mono700,
            ),
          ),
          const SizedBox(height: 32),
          Text('Не удалось принять\nприглашение', style: AppTextStyles.heading1),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.mono400),
          ),
          const Spacer(),
          _PrimaryButton(label: 'Попробовать снова', onTap: onRetry),
          const SizedBox(height: 16),
          _SecondaryButton(
            label: 'На главную',
            onTap: () => context.go('/welcome'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonH,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mono900,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
        ),
        child: Text(label, style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonH,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mono700,
          side: const BorderSide(color: AppColors.mono200, width: AppDimens.borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
        ),
        child: Text(label, style: AppTextStyles.subtitle.copyWith(color: AppColors.mono700)),
      ),
    );
  }
}
