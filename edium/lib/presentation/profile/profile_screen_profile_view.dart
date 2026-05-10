part of 'profile_screen.dart';

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.mono900,
                strokeWidth: 2,
              ),
            );
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style:
                        const TextStyle(fontSize: 15, color: AppColors.mono400),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context
                        .read<ProfileBloc>()
                        .add(const LoadProfileEvent()),
                    child: const Text(
                      'Повторить',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mono900,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          final loaded = state as ProfileLoaded;
          return _ProfileContent(
            user: loaded.user,
            statistic: loaded.statistic,
          );
        },
      ),
    );
  }
}

