part of 'student_question_review_sheet.dart';

class _ChoiceAnswerBlock extends StatelessWidget {
  final List<QuestionOptionForStudent> options;
  final Set<String> selectedIds;
  final Set<String> correctIds;

  const _ChoiceAnswerBlock({
    required this.options,
    required this.selectedIds,
    required this.correctIds,
  });

  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((o) {
        final isPicked = selectedIds.contains(o.id);
        final isCorrect = correctIds.contains(o.id);


        final Color bg;
        final Color border;
        if (isCorrect && isPicked) {
          bg = _greenBg;
          border = _green;
        } else if (isCorrect && !isPicked) {
          bg = _greenBg;
          border = _green;
        } else if (!isCorrect && isPicked) {
          bg = _redBg;
          border = _red;
        } else {
          bg = Colors.white;
          border = AppColors.mono150;
        }


        Widget? badge;
        if (isCorrect && isPicked) {
          badge = _OptionBadge(label: 'Ваш ответ ✓', color: _green);
        } else if (isCorrect && !isPicked) {
          badge = _OptionBadge(label: 'Правильно', color: _green);
        } else if (!isCorrect && isPicked) {
          badge = _OptionBadge(label: 'Ваш ответ', color: _red);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  o.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: (isCorrect || isPicked)
                        ? AppColors.mono900
                        : AppColors.mono400,
                    fontWeight: isCorrect
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                badge,
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

