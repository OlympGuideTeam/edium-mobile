part of 'edit_quiz_template_screen.dart';

class _EditSettingsCard extends StatelessWidget {
  final int? totalTimeLimitSec;
  final int? questionTimeLimitSec;
  final ValueChanged<bool> onTotalTimeToggle;
  final ValueChanged<int> onTotalTimeChanged;
  final ValueChanged<bool> onQuestionTimeToggle;
  final ValueChanged<int> onQuestionTimeChanged;

  const _EditSettingsCard({
    required this.totalTimeLimitSec,
    required this.questionTimeLimitSec,
    required this.onTotalTimeToggle,
    required this.onTotalTimeChanged,
    required this.onQuestionTimeToggle,
    required this.onQuestionTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mono100),
      ),
      child: Column(
        children: [
          _EditTimeRow(
            label: 'Время на весь квиз',
            subtitle: 'Используется в режиме «Тест»',
            valueSec: totalTimeLimitSec,
            unit: 'мин',
            unitDivisor: 60,
            minUnits: 5,
            maxUnits: 90,
            sliderStep: 5,
            onToggle: onTotalTimeToggle,
            onChanged: onTotalTimeChanged,
          ),
          Container(height: 1, color: AppColors.mono100),
          _EditTimeRow(
            label: 'Время на вопрос',
            subtitle: 'Используется в режиме «Лайв»',
            valueSec: questionTimeLimitSec,
            unit: 'сек',
            unitDivisor: 1,
            minUnits: 5,
            maxUnits: 90,
            sliderStep: 5,
            onToggle: onQuestionTimeToggle,
            onChanged: onQuestionTimeChanged,
          ),
        ],
      ),
    );
  }
}

