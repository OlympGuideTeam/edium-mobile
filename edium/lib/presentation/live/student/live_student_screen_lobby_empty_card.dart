part of 'live_student_screen.dart';

class _LobbyEmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.liveDarkBorder),
      ),
      child: const Column(
        children: [
          Icon(Icons.people_outline, color: AppColors.liveDarkMuted, size: 32),
          SizedBox(height: 8),
          Text(
            'Ждём участников...',
            style: TextStyle(color: AppColors.liveDarkMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

