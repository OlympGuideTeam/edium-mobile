part of 'live_teacher_screen.dart';

class _TeacherResultsLoadingPhase extends StatelessWidget {
  const _TeacherResultsLoadingPhase();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.mono50,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.mono900),
            SizedBox(height: 16),
            Text('Загрузка результатов...', style: AppTextStyles.screenSubtitle),
          ],
        ),
      ),
    );
  }
}

