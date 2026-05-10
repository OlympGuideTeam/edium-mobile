part of 'create_quiz_screen.dart';

class _TimeScrollWheel extends StatefulWidget {
  final int value;
  final int maxValue;
  final int step;
  final ValueChanged<int> onChanged;

  const _TimeScrollWheel({
    required this.value,
    required this.maxValue,
    this.step = 1,
    required this.onChanged,
  });

  @override
  State<_TimeScrollWheel> createState() => _TimeScrollWheelState();
}

class _TimeScrollWheelState extends State<_TimeScrollWheel> {
  late final FixedExtentScrollController _scrollCtrl;

  List<int> get _values {
    final list = <int>[];
    for (var i = 0; i <= widget.maxValue; i += widget.step) {
      list.add(i);
    }
    return list;
  }

  int _indexOfValue(int val) {
    final vals = _values;
    for (var i = 0; i < vals.length; i++) {
      if (vals[i] >= val) return i;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _scrollCtrl =
        FixedExtentScrollController(initialItem: _indexOfValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant _TimeScrollWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final idx = _indexOfValue(widget.value);
      if (_scrollCtrl.selectedItem != idx) {
        _scrollCtrl.animateToItem(
          idx,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vals = _values;
    const itemH = 36.0;
    const visibleItems = 3;
    const wheelH = itemH * visibleItems;

    return SizedBox(
      width: 52,
      height: wheelH,
      child: Stack(
        children: [

          Positioned(
            top: itemH,
            left: 0,
            right: 0,
            height: itemH,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.mono100,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _scrollCtrl,
            itemExtent: itemH,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 8,
            perspective: 0.001,
            onSelectedItemChanged: (i) => widget.onChanged(vals[i]),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: vals.length,
              builder: (context, index) {
                final isSelected = vals[index] == widget.value;
                return Center(
                  child: Text(
                    vals[index].toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.mono900
                          : AppColors.mono400,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

