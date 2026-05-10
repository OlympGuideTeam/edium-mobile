part of 'live_student_screen.dart';

class _AnsweredOverlay extends StatelessWidget {
  final LiveQuestion question;
  final Map<String, dynamic> myAnswer;

  const _AnsweredOverlay({required this.question, required this.myAnswer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAnswerDisplay(),
        const SizedBox(height: 20),
        _WaitingBanner(),
      ],
    );
  }

  Widget _buildAnswerDisplay() {
    switch (question.type) {
      case QuestionType.multiChoice:
        final selectedIds = ((myAnswer['selected_option_ids'] as List<dynamic>? ??
                    myAnswer['option_ids'] as List<dynamic>?) ??
                [])
            .map((e) => e.toString())
            .toSet();
        return Column(
          children: question.options.map((opt) {
            final isSelected = selectedIds.contains(opt.id);
            return _LockedOption(
              isSelected: isSelected,
              indicator: _CheckDot(isSelected: isSelected),
              text: opt.text,
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.liveAccent, size: 20)
                  : null,
            );
          }).toList(),
        );

      case QuestionType.withGivenAnswer:
      case QuestionType.withFreeAnswer:
        final text = myAnswer['text'] as String? ?? '';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.liveDarkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.liveAccent, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.liveAccent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );

      case QuestionType.drag:
        final order = ((myAnswer['order'] as List<dynamic>?) ?? [])
            .map((e) => e.toString())
            .toList();
        return Column(
          children: order.asMap().entries.map((e) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.liveDarkSurface,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.liveAccent, width: 1.5),
              ),
              child: Row(
                children: [
                  Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.liveDarkMuted),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(e.value,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.white)),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case QuestionType.connection:
        final rawPairs = (myAnswer['pairs'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v.toString())) ??
            {};
        return _AnsweredConnectionDisplay(
          question: question,
          myPairs: rawPairs,
        );

      default:
        final selectedId = myAnswer['selected_option_id'] as String? ??
            myAnswer['option_id'] as String?;
        return Column(
          children: question.options.map((opt) {
            final isSelected = selectedId == opt.id;
            return _LockedOption(
              isSelected: isSelected,
              indicator: _RadioDot(isSelected: isSelected),
              text: opt.text,
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.liveAccent, size: 20)
                  : null,
            );
          }).toList(),
        );
    }
  }
}

