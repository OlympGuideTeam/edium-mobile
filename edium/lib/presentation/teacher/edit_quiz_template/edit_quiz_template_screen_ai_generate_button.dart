part of 'edit_quiz_template_screen.dart';

class _AIGenerateButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AIGenerateButton({required this.onTap});

  @override
  State<_AIGenerateButton> createState() => _AIGenerateButtonState();
}

class _AIGenerateButtonState extends State<_AIGenerateButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return CustomPaint(
            painter: _RainbowBorderPainter(
              progress: _ctrl.value,
              borderRadius: 11,
              borderWidth: 1.5,
            ),
            child: Container(
              margin: const EdgeInsets.all(1.5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return SweepGradient(
                        colors: const [
                          Color(0xFF8B5CF6),
                          Color(0xFFEC4899),
                          Color(0xFFF59E0B),
                          Color(0xFF10B981),
                          Color(0xFF3B82F6),
                          Color(0xFF8B5CF6),
                        ],
                        transform:
                            GradientRotation(_ctrl.value * math.pi * 2),
                      ).createShader(bounds);
                    },
                    child: const Icon(Icons.auto_awesome,
                        size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AI',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mono900,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

