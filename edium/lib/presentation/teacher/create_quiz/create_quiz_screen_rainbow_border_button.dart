part of 'create_quiz_screen.dart';

class _RainbowBorderButton extends StatefulWidget {
  final bool enabled;
  final bool isBusy;
  final VoidCallback? onTap;
  final Widget child;

  const _RainbowBorderButton({
    required this.enabled,
    this.isBusy = false,
    required this.onTap,
    required this.child,
  });

  @override
  State<_RainbowBorderButton> createState() => _RainbowBorderButtonState();
}

class _RainbowBorderButtonState extends State<_RainbowBorderButton>
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
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: (!widget.enabled && !widget.isBusy) ? 0.5 : 1.0,
            child: CustomPaint(
              painter: _RainbowBorderPainter(
                progress: _ctrl.value,
                borderRadius: 14,
                borderWidth: 2.5,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.mono900,
                  borderRadius: BorderRadius.circular(11.5),
                ),
                margin: const EdgeInsets.all(2.5),
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

