part of 'live_teacher_screen.dart';

class _ParticipantRow extends StatelessWidget {
  final String name;
  final bool isLast;
  final Widget trailing;
  final Color dotColor;

  const _ParticipantRow({
    required this.name,
    required this.isLast,
    required this.trailing,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.mono100, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),

          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Text(
              _participantInitials(name),
              style: const TextStyle(
                  color: AppColors.mono600, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.mono900),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

