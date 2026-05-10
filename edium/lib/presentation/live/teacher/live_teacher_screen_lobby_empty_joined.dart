part of 'live_teacher_screen.dart';

class _LobbyEmptyJoined extends StatelessWidget {
  const _LobbyEmptyJoined();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mono150),
      ),
      child: const Column(
        children: [
          Icon(Icons.people_outline, color: AppColors.mono300, size: 32),
          SizedBox(height: 8),
          Text(
            'Ждём участников...',
            style: TextStyle(color: AppColors.mono400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

