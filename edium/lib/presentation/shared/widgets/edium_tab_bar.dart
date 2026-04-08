import 'package:edium/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class EdiumTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const EdiumTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class EdiumTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<EdiumTabItem> items;

  const EdiumTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 0.5, color: AppColors.mono150),
          Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8 + bottomPadding),
            child: Row(
              children: [
                for (int i = 0; i < items.length; i++)
                  Expanded(
                    child: _TabItem(
                      item: items[i],
                      isActive: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final EdiumTabItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
