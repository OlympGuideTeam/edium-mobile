import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/usecases/class/accept_invitation_usecase.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/shared/invite/bloc/invite_bloc.dart';
import 'package:edium/presentation/shared/invite/bloc/invite_event.dart';
import 'package:edium/presentation/shared/invite/bloc/invite_state.dart';
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
  @override
  void initState() {
    super.initState();
    final authState = getIt<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<InviteBloc>().add(const InviteAcceptRequested());
    } else {
      context.read<InviteBloc>().add(const InviteScreenOpened());
    }
  }

  void _navigateHome() {
    final authState = getIt<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final role = authState.user.role;
      if (role?.name == 'teacher') {
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
        if (state is InviteAcceptSuccess || state is InviteAlreadyMember) {
          _navigateHome();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.mono25,
        body: SafeArea(
          child: BlocBuilder<InviteBloc, InviteState>(
            builder: (context, state) {
              if (state is InviteAccepting) {
                return const _LoadingBody();
              }
              if (state is InviteAcceptError) {
                return _ErrorBody(
                  message: state.message,
                  onRetry: () => context
                      .read<InviteBloc>()
                      .add(const InviteAcceptRequested()),
                );
              }
              return _InviteBody(invitationId: widget.invitationId);
            },
          ),
        ),
      ),
    );
  }
}

class _InviteBody extends StatelessWidget {
  final String invitationId;
  const _InviteBody({required this.invitationId});

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
            'Войдите в Edium, чтобы принять\nприглашение и присоединиться.',
            style: AppTextStyles.body.copyWith(color: AppColors.mono400),
          ),
          const Spacer(),
          _PrimaryButton(
            label: 'Войти и принять',
            onTap: () => context.push('/phone'),
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
