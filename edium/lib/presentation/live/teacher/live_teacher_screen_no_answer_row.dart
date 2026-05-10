part of 'live_teacher_screen.dart';

class _NoAnswerRow extends StatelessWidget {
  final LiveLobbyParticipant participant;
  final bool isLast;

  const _NoAnswerRow({required this.participant, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return _ParticipantRow(
      name: participant.name,
      isLast: isLast,
      trailing: const Text(
        'не ответил',
        style: TextStyle(fontSize: 12, color: AppColors.mono400),
      ),
      dotColor: AppColors.mono300,
    );
  }
}

String _participantInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

