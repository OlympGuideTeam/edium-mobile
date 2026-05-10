part of 'take_quiz_screen.dart';

class _ConnectionQuestion extends StatefulWidget {
  final QuizQuestionForStudent question;
  final Map<String, String>? currentPairs;
  final ValueChanged<Map<String, String>> onPairsChanged;

  const _ConnectionQuestion({
    required this.question,
    required this.currentPairs,
    required this.onPairsChanged,
  });

  @override
  State<_ConnectionQuestion> createState() => _ConnectionQuestionState();
}

class _ConnectionQuestionState extends State<_ConnectionQuestion> {
  String? _selectedLeft;
  late Map<String, String> _pairs;


  late List<GlobalKey> _leftKeys;
  late List<GlobalKey> _rightKeys;

  final _stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pairs = Map.from(widget.currentPairs ?? {});
    _initKeys();
  }

  void _initKeys() {
    final left = _leftItems;
    final right = _rightItems;
    _leftKeys = List.generate(left.length, (_) => GlobalKey());
    _rightKeys = List.generate(right.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(_ConnectionQuestion old) {
    super.didUpdateWidget(old);
    if (old.question.id != widget.question.id) {
      _selectedLeft = null;
      _pairs = Map.from(widget.currentPairs ?? {});
      _initKeys();
    }
  }

  List<String> get _leftItems =>
      (widget.question.metadata?['left'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  List<String> get _rightItems =>
      (widget.question.metadata?['right'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  void _onTapLeft(String item) {
    setState(() {
      _selectedLeft = _selectedLeft == item ? null : item;
    });
  }

  void _onTapRight(String item) {
    if (_selectedLeft == null) return;
    setState(() {
      _pairs.removeWhere((_, v) => v == item);
      _pairs[_selectedLeft!] = item;
      _selectedLeft = null;
    });
    widget.onPairsChanged(Map.from(_pairs));
  }

  void _removePair(String left) {
    setState(() => _pairs.remove(left));
    widget.onPairsChanged(Map.from(_pairs));
  }


  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stackBox == null) return null;
    final topLeft = stackBox.globalToLocal(box.localToGlobal(Offset.zero));
    return topLeft & box.size;
  }


  List<({Rect fromRect, Rect toRect, String leftItem})> _arrowData() {
    final leftItems = _leftItems;
    final rightItems = _rightItems;
    final result = <({Rect fromRect, Rect toRect, String leftItem})>[];
    for (final entry in _pairs.entries) {
      final li = leftItems.indexOf(entry.key);
      final ri = rightItems.indexOf(entry.value);
      if (li == -1 || ri == -1) continue;
      final fromRect = _rectOf(_leftKeys[li]);
      final toRect = _rectOf(_rightKeys[ri]);
      if (fromRect != null && toRect != null) {
        result.add((fromRect: fromRect, toRect: toRect, leftItem: entry.key));
      }
    }
    return result;
  }


  void _onTapStack(TapUpDetails details) {
    final arrows = _arrowData();
    for (final arrow in arrows) {
      final from = Offset(arrow.fromRect.right, arrow.fromRect.center.dy);
      final to = Offset(arrow.toRect.left, arrow.toRect.center.dy);
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      if ((details.localPosition - mid).distance < 20) {
        _removePair(arrow.leftItem);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leftItems = _leftItems;
    final rightItems = _rightItems;
    final rowCount = leftItems.length > rightItems.length
        ? leftItems.length
        : rightItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Нажмите на элемент слева, затем на соответствующий справа:',
          style: TextStyle(fontSize: 13, color: AppColors.mono400),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTapUp: _onTapStack,
          child: Stack(
            key: _stackKey,
            children: [

              Column(
                children: List.generate(rowCount, (i) {
                  final left = i < leftItems.length ? leftItems[i] : null;
                  final right = i < rightItems.length ? rightItems[i] : null;

                  final isLeftSelected =
                      left != null && _selectedLeft == left;
                  final isLeftPaired =
                      left != null && _pairs.containsKey(left);
                  final isRightPaired =
                      right != null && _pairs.values.contains(right);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: 84,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          Expanded(
                            child: left != null
                                ? GestureDetector(
                                    onTap: () => _onTapLeft(left),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        AnimatedContainer(
                                          key: _leftKeys[i],
                                          duration: const Duration(
                                              milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isLeftSelected
                                                ? AppColors.mono900
                                                : isLeftPaired
                                                    ? AppColors.mono50
                                                    : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isLeftSelected
                                                  ? AppColors.mono900
                                                  : isLeftPaired
                                                      ? AppColors.mono350
                                                      : AppColors.mono150,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              left,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isLeftSelected
                                                    ? Colors.white
                                                    : AppColors.mono900,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),

                                        Positioned(
                                          right: -5,
                                          top: 0,
                                          bottom: 0,
                                          child: Center(
                                            child: _EdgeDot(
                                              active: isLeftPaired ||
                                                  isLeftSelected,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),


                          const SizedBox(width: 32),


                          Expanded(
                            child: right != null
                                ? GestureDetector(
                                    onTap: () => _onTapRight(right),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        AnimatedContainer(
                                          key: _rightKeys[i],
                                          duration: const Duration(
                                              milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isRightPaired
                                                ? AppColors.mono50
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isRightPaired
                                                  ? AppColors.mono350
                                                  : AppColors.mono150,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              right,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.mono900,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),

                                        Positioned(
                                          left: -5,
                                          top: 0,
                                          bottom: 0,
                                          child: Center(
                                            child: _EdgeDot(
                                              active: isRightPaired,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),


              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ConnectionArrowPainter(
                      arrows: _arrowData(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

