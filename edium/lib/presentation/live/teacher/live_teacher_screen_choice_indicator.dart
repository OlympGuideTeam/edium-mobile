part of 'live_teacher_screen.dart';

class _ChoiceIndicator extends StatelessWidget {
  final bool isCorrect;
  final bool isMulti;

  const _ChoiceIndicator({required this.isCorrect, required this.isMulti});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      decoration: isMulti
          ? BoxDecoration(
              color: isCorrect ? AppColors.mono900 : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: isCorrect ? AppColors.mono900 : AppColors.mono300,
                width: 1.5,
              ),
            )
          : BoxDecoration(
              color: isCorrect ? AppColors.mono900 : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCorrect ? AppColors.mono900 : AppColors.mono300,
                width: 1.5,
              ),
            ),
      child: isCorrect
          ? Center(
              child: isMulti
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
            )
          : null,
    );
  }
}

