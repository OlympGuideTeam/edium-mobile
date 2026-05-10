part of 'live_student_screen.dart';

class _ConfirmButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _ConfirmButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.mono900,
          disabledBackgroundColor: AppColors.liveDarkCard,
          disabledForegroundColor: AppColors.liveDarkMuted,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text(
          'Подтвердить',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

