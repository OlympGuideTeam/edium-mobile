part of 'live_teacher_screen.dart';

class _TeacherLoadingPhase extends StatelessWidget {
  final String quizTitle;
  const _TeacherLoadingPhase({required this.quizTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.mono900),
            const SizedBox(height: 24),
            Text(quizTitle, style: AppTextStyles.heading3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Подключение...', style: AppTextStyles.screenSubtitle),
          ],
        ),
      ),
    );
  }
}

