part of 'invite_screen.dart';

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

