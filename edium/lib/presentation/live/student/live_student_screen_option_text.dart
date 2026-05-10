part of 'live_student_screen.dart';

class _OptionText extends StatelessWidget {
  final String text;
  final bool isSelected;
  const _OptionText(this.text, {required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        height: 1.4,
      ),
    );
  }
}

