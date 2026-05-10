part of 'teacher_grade_question_screen.dart';

class _ScoreChip extends StatelessWidget {
  final int value;
  final bool isSelected;
  final TextEditingController controller;

  const _ScoreChip({
    required this.value,
    required this.isSelected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.text = value.toString(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mono900 : Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          border: Border.all(
            color: isSelected ? AppColors.mono900 : AppColors.mono150,
            width: AppDimens.borderWidth,
          ),
        ),
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.mono600,
          ),
          child: Text('$value'),
        ),
      ),
    );
  }
}

