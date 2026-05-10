part of 'live_teacher_screen.dart';

class _LobbyNotJoinedRow extends StatelessWidget {
  final String name;
  final bool isLast;

  const _LobbyNotJoinedRow({required this.name, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.mono100, width: 1)),
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
              _participantInitials(name),
              style: const TextStyle(
                color: AppColors.mono300,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.mono400,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Text(
            'не вошёл',
            style: TextStyle(fontSize: 12, color: AppColors.mono300),
          ),
        ],
      ),
    );
  }
}

