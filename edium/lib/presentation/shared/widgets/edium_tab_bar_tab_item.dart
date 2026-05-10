part of 'edium_tab_bar.dart';

class _TabItem extends StatelessWidget {
  final EdiumTabItem item;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;

  const _TabItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isActive ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                size: 22,
                color: isActive ? AppColors.mono900 : AppColors.mono350,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.mono900 : AppColors.mono350,
                letterSpacing: -0.1,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

