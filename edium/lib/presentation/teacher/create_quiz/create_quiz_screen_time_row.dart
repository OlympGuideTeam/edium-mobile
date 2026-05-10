part of 'create_quiz_screen.dart';

class _TimeRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final int? valueSec;
  final String unit;
  final int unitDivisor;
  final int sliderMinUnits;
  final int sliderMaxUnits;
  final int sliderStep;
  final int defaultValueSec;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onValueChanged;

  const _TimeRow({
    super.key,
    required this.label,
    this.subtitle,
    required this.valueSec,
    required this.unit,
    required this.unitDivisor,
    required this.sliderMinUnits,
    required this.sliderMaxUnits,
    required this.sliderStep,
    required this.defaultValueSec,
    required this.onToggle,
    required this.onValueChanged,
  });

  int get _currentUnits =>
      valueSec != null ? (valueSec! / unitDivisor).round() : sliderMinUnits;

  int get _divisions => (sliderMaxUnits - sliderMinUnits) ~/ sliderStep;

  String get _displayText => '$_currentUnits $unit';

  Future<void> _showInputDialog(BuildContext context) async {
    final ctrl = TextEditingController(text: '$_currentUnits');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => _TimeInputDialog(
        controller: ctrl,
        unit: unit,
        minValue: sliderMinUnits,
        maxValue: sliderMaxUnits,
      ),
    );
    if (result != null) {
      final clamped = result.clamp(sliderMinUnits, sliderMaxUnits);
      onValueChanged(clamped * unitDivisor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.mono700)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.mono400, fontSize: 11)),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: valueSec != null ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: valueSec == null,
                      child: GestureDetector(
                        onTap: () => _showInputDialog(context),
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
                  _MonoSwitch(
                      value: valueSec != null, onChanged: onToggle),
                ],
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: valueSec != null
              ? Padding(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, bottom: 12),
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.mono900,
                      inactiveTrackColor: AppColors.mono150,
                      thumbColor: AppColors.mono900,
                      overlayColor:
                          AppColors.mono900.withValues(alpha: 0.08),
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: _currentUnits.toDouble().clamp(
                          sliderMinUnits.toDouble(),
                          sliderMaxUnits.toDouble()),
                      min: sliderMinUnits.toDouble(),
                      max: sliderMaxUnits.toDouble(),
                      divisions: _divisions,
                      onChanged: (v) =>
                          onValueChanged(v.round() * unitDivisor),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

