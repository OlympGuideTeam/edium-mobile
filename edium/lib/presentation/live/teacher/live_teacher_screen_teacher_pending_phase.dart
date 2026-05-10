part of 'live_teacher_screen.dart';

class _TeacherPendingPhase extends StatelessWidget {
  final LiveTeacherPending state;
  final VoidCallback onStartLobby;

  const _TeacherPendingPhase({required this.state, required this.onStartLobby});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      appBar: AppBar(
        backgroundColor: AppColors.mono50,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(state.quizTitle, style: AppTextStyles.heading3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.mono100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt_rounded, color: AppColors.mono400, size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text('Сессия создана', style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    Text(
                      '${state.questionCount} вопрос${_suffix(state.questionCount)}',
                      style: AppTextStyles.screenSubtitle,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onStartLobby,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mono900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Открыть лобби',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _suffix(int n) {
    if (n % 10 == 1 && n % 100 != 11) return '';
    if (n % 10 >= 2 && n % 10 <= 4 && !(n % 100 >= 12 && n % 100 <= 14)) return 'а';
    return 'ов';
  }
}

