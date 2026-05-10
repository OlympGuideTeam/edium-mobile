part of 'live_student_screen.dart';

class _LockedOption extends StatelessWidget {
  final bool isSelected;
  final Widget indicator;
  final String text;
  final Widget? trailing;

  const _LockedOption({
    required this.isSelected,
    required this.indicator,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.liveDarkSurface : AppColors.liveDarkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.liveAccent : AppColors.liveDarkBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              indicator,
              const SizedBox(width: 12),
              Expanded(child: _OptionText(text, isSelected: isSelected)),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

