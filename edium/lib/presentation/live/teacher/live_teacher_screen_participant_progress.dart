part of 'live_teacher_screen.dart';

class _ParticipantProgress extends StatelessWidget {
  final List<LiveLobbyParticipant> participants;
  final Map<String, LiveTeacherParticipantAnswer> answeredMap;
  final DateTime deadlineAt;
  final int timeLimitSec;
  final bool isLocked;

  const _ParticipantProgress({
    required this.participants,
    required this.answeredMap,
    required this.deadlineAt,
    required this.timeLimitSec,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) return const SizedBox.shrink();

    final pending = participants.where((p) => !answeredMap.containsKey(p.attemptId)).toList();
    final answered = participants.where((p) => answeredMap.containsKey(p.attemptId)).toList();


    final questionStartedAt = timeLimitSec > 0
        ? deadlineAt.subtract(Duration(seconds: timeLimitSec))
        : DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        if (!isLocked) ...[
          _SectionLabel(
            label: 'Ещё отвечают',
            trailing: '${pending.length}',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.mono150),
            ),
            child: pending.isEmpty
                ? const _AllPendingAnsweredPlaceholder()
                : Column(
                    children: pending.asMap().entries.map((e) {
                      final isLast = e.key == pending.length - 1;
                      return _PendingRow(
                        participant: e.value,
                        questionStartedAt: questionStartedAt,
                        isLast: isLast,
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 16),
        ],

        _SectionLabel(label: 'Ответили', trailing: '${answered.length}'),
        const SizedBox(height: 8),
        if (answered.isEmpty)
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.mono150),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Ожидаем ответов...',
              style: TextStyle(fontSize: 13, color: AppColors.mono300),
              textAlign: TextAlign.center,
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.mono150),
            ),
            child: Column(
              children: answered.asMap().entries.map((e) {
                final isLast = e.key == answered.length - 1;
                final result = answeredMap[e.value.attemptId];
                return _AnsweredRow(
                  participant: e.value,
                  result: result,
                  isLast: isLast,
                );
              }).toList(),
            ),
          ),

        if (isLocked && pending.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionLabel(label: 'Не ответили', trailing: '${pending.length}'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.mono150),
            ),
            child: Column(
              children: pending.asMap().entries.map((e) {
                final isLast = e.key == pending.length - 1;
                return _NoAnswerRow(participant: e.value, isLast: isLast);
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

