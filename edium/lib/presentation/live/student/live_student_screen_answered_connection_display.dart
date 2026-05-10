part of 'live_student_screen.dart';

class _AnsweredConnectionDisplay extends StatefulWidget {
  final LiveQuestion question;
  final Map<String, String> myPairs;

  const _AnsweredConnectionDisplay({
    required this.question,
    required this.myPairs,
  });

  @override
  State<_AnsweredConnectionDisplay> createState() =>
      _AnsweredConnectionDisplayState();
}

class _AnsweredConnectionDisplayState
    extends State<_AnsweredConnectionDisplay> {
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
    _leftKeys = List.generate(_leftItems.length, (_) => GlobalKey());
    _rightKeys = List.generate(_rightItems.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stackBox == null) return null;
    final tl = stackBox.globalToLocal(box.localToGlobal(Offset.zero));
    return tl & box.size;
  }

  List<({Rect fromRect, Rect toRect})> _arrowData() {
    final left = _leftItems;
    final right = _rightItems;
    final result = <({Rect fromRect, Rect toRect})>[];
    for (final entry in widget.myPairs.entries) {
      final li = left.indexOf(entry.key);
      final ri = right.indexOf(entry.value);
      if (li == -1 || ri == -1) continue;
      final from = _rectOf(_leftKeys[li]);
      final to = _rectOf(_rightKeys[ri]);
      if (from != null && to != null) {
        result.add((fromRect: from, toRect: to));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final left = _leftItems;
    final right = _rightItems;
    final rowCount = left.length > right.length ? left.length : right.length;

    return Stack(
      key: _stackKey,
      children: [
        Column(
          children: List.generate(rowCount, (i) {
            final l = i < left.length ? left[i] : null;
            final r = i < right.length ? right[i] : null;
            final isLeftPaired = l != null && widget.myPairs.containsKey(l);
            final isRightPaired =
                r != null && widget.myPairs.values.contains(r);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                height: 72,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: l != null
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  key: _leftKeys[i],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isLeftPaired
                                        ? AppColors.liveDarkSurface
                                        : AppColors.liveDarkCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isLeftPaired
                                          ? AppColors.liveDarkMuted
                                          : AppColors.liveDarkBorder,
                                      width: isLeftPaired ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      l,
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
                                  right: -5,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child:
                                        _LiveEdgeDot(active: isLeftPaired),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: r != null
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  key: _rightKeys[i],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isRightPaired
                                        ? AppColors.liveDarkSurface
                                        : AppColors.liveDarkCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isRightPaired
                                          ? AppColors.liveDarkMuted
                                          : AppColors.liveDarkBorder,
                                      width: isRightPaired ? 1.5 : 1,
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
                                    child:
                                        _LiveEdgeDot(active: isRightPaired),
                                  ),
                                ),
                              ],
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
              painter: _NeutralArrowPainter(arrows: _arrowData()),
            ),
          ),
        ),
      ],
    );
  }
}

