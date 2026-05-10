part of 'live_teacher_screen.dart';

class _TeacherErrorPhase extends StatelessWidget {
  final String message;
  const _TeacherErrorPhase({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppColors.mono300, size: 48),
              const SizedBox(height: 16),
              Text(message,
                  style: AppTextStyles.screenSubtitle, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

