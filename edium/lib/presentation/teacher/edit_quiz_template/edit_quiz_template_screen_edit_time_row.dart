part of 'edit_quiz_template_screen.dart';

class _EditTimeRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final int? valueSec;
  final String unit;
  final int unitDivisor;
  final int minUnits;
  final int maxUnits;
  final int sliderStep;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onChanged;

  const _EditTimeRow({
    required this.label,
    required this.subtitle,
    required this.valueSec,
    required this.unit,
    required this.unitDivisor,
    required this.minUnits,
    required this.maxUnits,
    required this.sliderStep,
    required this.onToggle,
    required this.onChanged,
  });

  int get _currentUnits =>
      valueSec != null ? (valueSec! / unitDivisor).round() : minUnits;

  int get _divisions => (maxUnits - minUnits) ~/ sliderStep;

  String get _displayText => '$_currentUnits $unit';

  Future<void> _showInput(BuildContext context) async {
    final ctrl = TextEditingController(text: '$_currentUnits');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => _EditTimeInputDialog(
        controller: ctrl,
        unit: unit,
        minValue: minUnits,
        maxValue: maxUnits,
      ),
    );
    if (result != null) {
      onChanged(result.clamp(minUnits, maxUnits) * unitDivisor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.mono700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.mono400, fontSize: 11)),
                  ],
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: valueSec != null ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: valueSec == null,
                  child: GestureDetector(
                    onTap: () => _showInput(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mono100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _displayText,
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
              _EditMonoSwitch(value: valueSec != null, onChanged: onToggle),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: valueSec != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.mono900,
                      inactiveTrackColor: AppColors.mono150,
                      thumbColor: AppColors.mono900,
                      overlayColor: AppColors.mono900.withValues(alpha: 0.08),
                      trackHeight: 2,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: _currentUnits.toDouble().clamp(
                            minUnits.toDouble(), maxUnits.toDouble()),
                      min: minUnits.toDouble(),
                      max: maxUnits.toDouble(),
                      divisions: _divisions,
                      onChanged: (v) => onChanged(v.round() * unitDivisor),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

