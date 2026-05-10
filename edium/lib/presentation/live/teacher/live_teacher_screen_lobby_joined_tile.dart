part of 'live_teacher_screen.dart';

class _LobbyJoinedTile extends StatelessWidget {
  final LiveLobbyParticipant participant;
  final VoidCallback onKick;

  const _LobbyJoinedTile({required this.participant, required this.onKick});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: AppColors.error,
        child: Dismissible(
          key: ValueKey(participant.attemptId),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => EdiumConfirmDialog.show(
            context,
            title: 'Исключить участника?',
            body: '${participant.name} будет удалён из квиза.',
            confirmLabel: 'Исключить',
            cancelLabel: 'Отмена',
            isDestructive: true,
          ),
          onDismissed: (_) => onKick(),
          background: Container(
            color: AppColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.person_remove_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mono150),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.mono100,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _participantInitials(participant.name),
                    style: const TextStyle(
                      color: AppColors.mono600,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    participant.name,
                    style: const TextStyle(
                      color: AppColors.mono900,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

