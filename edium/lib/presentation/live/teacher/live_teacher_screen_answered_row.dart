part of 'live_teacher_screen.dart';

class _AnsweredRow extends StatelessWidget {
  final LiveLobbyParticipant participant;
  final LiveTeacherParticipantAnswer? result;
  final bool isLast;

  const _AnsweredRow({
    required this.participant,
    required this.result,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final timeSec = result != null ? (result!.timeTakenMs / 1000).round() : null;
    final isCorrect = result?.isCorrect ?? false;

    return _ParticipantRow(
      name: participant.name,
      isLast: isLast,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (timeSec != null)
            Text(
              '$timeSec с',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.mono400,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 18,
            color: isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
          ),
        ],
      ),
      dotColor: isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
    );
  }
}

