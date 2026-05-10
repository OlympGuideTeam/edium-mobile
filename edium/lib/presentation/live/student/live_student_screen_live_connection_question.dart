part of 'live_student_screen.dart';

class _LiveConnectionQuestion extends StatefulWidget {
  final LiveQuestion question;
  final ValueChanged<Map<String, String>> onConfirm;

  const _LiveConnectionQuestion(
      {required this.question, required this.onConfirm});

  @override
  State<_LiveConnectionQuestion> createState() =>
      _LiveConnectionQuestionState();
}

class _LiveConnectionQuestionState extends State<_LiveConnectionQuestion> {
  String? _selectedLeft;
  final Map<String, String> _pairs = {};

  late List<GlobalKey> _leftKeys;
  late List<GlobalKey> _rightKeys;
  final _stackKey = GlobalKey();

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

  @override
  void initState() {
    super.initState();
    _initKeys();
  }

  void _initKeys() {
    _leftKeys = List.generate(_leftItems.length, (_) => GlobalKey());
    _rightKeys = List.generate(_rightItems.length, (_) => GlobalKey());
  }

  void _onTapLeft(String item) =>
      setState(() => _selectedLeft = _selectedLeft == item ? null : item);

  void _onTapRight(String item) {
    if (_selectedLeft == null) return;
    setState(() {
      _pairs.removeWhere((_, v) => v == item);
      _pairs[_selectedLeft!] = item;
      _selectedLeft = null;
    });
  }

  void _removePair(String left) =>
      setState(() => _pairs.remove(left));

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stackBox == null) return null;
    final tl = stackBox.globalToLocal(box.localToGlobal(Offset.zero));
    return tl & box.size;
  }

  List<({Rect fromRect, Rect toRect, String leftItem})> _arrowData() {
    final left = _leftItems;
    final right = _rightItems;
    final result = <({Rect fromRect, Rect toRect, String leftItem})>[];
    for (final entry in _pairs.entries) {
      final li = left.indexOf(entry.key);
      final ri = right.indexOf(entry.value);
      if (li == -1 || ri == -1) continue;
      final from = _rectOf(_leftKeys[li]);
      final to = _rectOf(_rightKeys[ri]);
      if (from != null && to != null) {
        result.add((fromRect: from, toRect: to, leftItem: entry.key));
      }
    }
    return result;
  }

  void _onTapStack(TapUpDetails details) {
    for (final arrow in _arrowData()) {
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
    final left = _leftItems;
    final right = _rightItems;
    final rowCount = left.length > right.length ? left.length : right.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Нажмите на элемент слева, затем на соответствующий справа:',
          style: TextStyle(fontSize: 13, color: AppColors.liveDarkMuted),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTapUp: _onTapStack,
          child: Stack(
            key: _stackKey,
            children: [
              Column(
                children: List.generate(rowCount, (i) {
                  final l = i < left.length ? left[i] : null;
                  final r = i < right.length ? right[i] : null;
                  final isLeftSel = l != null && _selectedLeft == l;
                  final isLeftPaired = l != null && _pairs.containsKey(l);
                  final isRightPaired = r != null && _pairs.values.contains(r);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: 72,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: l != null
                                ? GestureDetector(
                                    onTap: () => _onTapLeft(l),
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
                                            color: isLeftSel
                                                ? AppColors.liveAccent
                                                    .withValues(alpha: 0.2)
                                                : isLeftPaired
                                                    ? AppColors.liveDarkSurface
                                                    : AppColors.liveDarkCard,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isLeftSel
                                                  ? AppColors.liveAccent
                                                  : isLeftPaired
                                                      ? AppColors.liveDarkMuted
                                                      : AppColors.liveDarkBorder,
                                              width: isLeftSel ? 2 : 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              l,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isLeftSel
                                                    ? AppColors.liveAccent
                                                    : Colors.white,
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
                                            child: _LiveEdgeDot(
                                              active: isLeftPaired || isLeftSel,
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
                            child: r != null
                                ? GestureDetector(
                                    onTap: () => _onTapRight(r),
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
                                                ? AppColors.liveDarkSurface
                                                : AppColors.liveDarkCard,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isRightPaired
                                                  ? AppColors.liveDarkMuted
                                                  : AppColors.liveDarkBorder,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              r,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
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
                                            child: _LiveEdgeDot(
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
                    painter: _LiveArrowPainter(arrows: _arrowData()),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        _ConfirmButton(
          enabled: _pairs.length == left.length,
          onTap: () => widget.onConfirm(Map.from(_pairs)),
        ),
      ],
    );
  }
}

