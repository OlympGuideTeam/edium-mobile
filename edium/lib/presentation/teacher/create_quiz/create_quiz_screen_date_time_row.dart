part of 'create_quiz_screen.dart';

class _DateTimeRow extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<bool> onToggle;
  final ValueChanged<DateTime> onPick;

  const _DateTimeRow({
    super.key,
    required this.label,
    required this.value,
    required this.onToggle,
    required this.onPick,
  });

  static final _dateFmt = DateFormat('d MMM, HH:mm', 'ru');

  Future<void> _pick(BuildContext context) async {
    final initial = value ?? DateTime.now();
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EdiumDateTimePicker(initial: initial),
    );
    if (result != null && context.mounted) {
      onPick(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.mono700),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: value != null ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: value == null,
              child: GestureDetector(
                onTap: () => _pick(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mono100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value != null ? _dateFmt.format(value!) : '—',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mono900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _MonoSwitch(value: value != null, onChanged: onToggle),
        ],
      ),
    );
  }
}

