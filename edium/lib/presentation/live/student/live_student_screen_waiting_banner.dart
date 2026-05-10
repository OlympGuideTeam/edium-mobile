part of 'live_student_screen.dart';

class _WaitingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.liveDarkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_top_rounded,
              color: AppColors.liveDarkMuted, size: 18),
          SizedBox(width: 8),
          Text(
            'Ждём других участников...',
            style: TextStyle(color: AppColors.liveDarkMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

