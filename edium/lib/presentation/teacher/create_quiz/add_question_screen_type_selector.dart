part of 'add_question_screen.dart';

class _TypeSelector extends StatelessWidget {
  final _QType selected;
  final ValueChanged<_QType> onSelect;

  const _TypeSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: _QType.values.map((t) {
          final isSelected = t == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.mono900 : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.mono900 : AppColors.mono200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.icon,
                        size: 13,
                        color: isSelected ? Colors.white : AppColors.mono400),
                    const SizedBox(width: 5),
                    Text(
                      t.label,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? Colors.white : AppColors.mono600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

