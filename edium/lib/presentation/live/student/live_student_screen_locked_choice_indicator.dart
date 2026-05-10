part of 'live_student_screen.dart';

class _LockedChoiceIndicator extends StatelessWidget {
  final bool isCorrect;
  final bool isMulti;
  final bool isSelected;

  const _LockedChoiceIndicator({
    required this.isCorrect,
    required this.isMulti,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    const red = Colors.redAccent;

    final Color borderColor;
    final Color bgColor;
    final Widget? inner;

    if (isSelected && isCorrect) {
      borderColor = green;
      bgColor = green;
      inner = isMulti
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white));
    } else if (isSelected && !isCorrect) {
      borderColor = red;
      bgColor = red;
      inner = isMulti
          ? const Icon(Icons.close, size: 12, color: Colors.white)
          : Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white));
    } else if (!isSelected && isCorrect) {
      borderColor = green.withValues(alpha: 0.6);
      bgColor = green.withValues(alpha: 0.1);
      inner = isMulti
          ? Icon(Icons.check, size: 12, color: green.withValues(alpha: 0.7))
          : Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: green.withValues(alpha: 0.5)));
    } else {
      borderColor = const Color(0xFF4A4A4A);
      bgColor = Colors.transparent;
      inner = null;
    }

    return Container(
      width: 20,
      height: 20,
      decoration: isMulti
          ? BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: borderColor, width: 1.5),
            )
          : BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
            ),
      child: inner != null ? Center(child: inner) : null,
    );
  }
}

