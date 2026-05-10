part of 'edit_quiz_template_screen.dart';

class _EditTimeInputDialog extends StatefulWidget {
  final TextEditingController controller;
  final String unit;
  final int minValue;
  final int maxValue;

  const _EditTimeInputDialog({
    required this.controller,
    required this.unit,
    required this.minValue,
    required this.maxValue,
  });

  @override
  State<_EditTimeInputDialog> createState() => _EditTimeInputDialogState();
}

class _EditTimeInputDialogState extends State<_EditTimeInputDialog> {
  String? _error;

  void _confirm() {
    final v = int.tryParse(widget.controller.text.trim());
    if (v == null) {
      setState(() => _error = 'Введите число');
      return;
    }
    if (v < widget.minValue || v > widget.maxValue) {
      setState(() =>
          _error = 'От ${widget.minValue} до ${widget.maxValue} ${widget.unit}');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Введите значение',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.mono900)),
            const SizedBox(height: 4),
            Text('${widget.minValue}–${widget.maxValue} ${widget.unit}',
                style: AppTextStyles.helperText),
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.fieldText.copyWith(color: AppColors.mono900),
              cursorColor: AppColors.mono900,
              decoration: InputDecoration(
                suffixText: widget.unit,
                suffixStyle: AppTextStyles.fieldText.copyWith(color: AppColors.mono400),
                filled: true,
                fillColor: AppColors.mono25,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.mono150),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.mono150),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.mono700, width: 1.5),
                ),
                errorText: _error,
                errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
              onSubmitted: (_) => _confirm(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.mono150),
                      ),
                      child: Center(
                        child: Text('Отмена',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mono600,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _confirm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.mono900,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text('Готово',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

