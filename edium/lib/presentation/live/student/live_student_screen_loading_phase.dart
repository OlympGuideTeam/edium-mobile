part of 'live_student_screen.dart';

class _LoadingPhase extends StatelessWidget {
  final String quizTitle;
  const _LoadingPhase({required this.quizTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.liveAccent),
            const SizedBox(height: 24),
            Text(
              quizTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Подключение...',
              style: TextStyle(color: AppColors.liveDarkMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

