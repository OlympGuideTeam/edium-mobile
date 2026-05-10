part of 'teacher_grade_attempt_screen.dart';

class _ScoreChip extends StatelessWidget {
  final int value;
  final bool isSelected;
  final TextEditingController controller;
  final VoidCallback? onSelected;

  const _ScoreChip({
    required this.value,
    required this.isSelected,
    required this.controller,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.text = value.toString();
        onSelected?.call();
      },
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

