part of 'invite_screen.dart';

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

