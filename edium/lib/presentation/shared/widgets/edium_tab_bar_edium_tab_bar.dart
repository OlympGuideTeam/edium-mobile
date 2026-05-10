part of 'edium_tab_bar.dart';

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
                      onDoubleTap: items[i].onDoubleTap,
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

