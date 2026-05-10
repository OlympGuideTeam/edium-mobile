part of 'classes_screen.dart';

class _ClassTile extends StatelessWidget {
  final ClassSummary classSummary;
  final bool isTeacher;

  const _ClassTile({
    required this.classSummary,
    required this.isTeacher,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = isTeacher && classSummary.isOwner;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () async {
          await context.push('/class/${classSummary.id}');
          if (context.mounted) {
            context.read<ClassesBloc>().add(const LoadClassesEvent());
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFDDDDDD),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTeacher) ...[
                      _OwnershipBadge(isOwner: isOwner),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      classSummary.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_studentLabel(classSummary.studentCount)}  ·  ${classSummary.ownerName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCCCCC),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _studentLabel(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return '$count учеников';
    switch (count % 10) {
      case 1:
        return '$count ученик';
      case 2:
      case 3:
      case 4:
        return '$count ученика';
      default:
        return '$count учеников';
    }
  }
}

