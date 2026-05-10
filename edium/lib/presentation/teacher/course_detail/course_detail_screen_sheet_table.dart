part of 'course_detail_screen.dart';

class _SheetTable extends StatefulWidget {
  final CourseSheet sheet;
  final Map<String, String> titleIndex;

  const _SheetTable({required this.sheet, required this.titleIndex});

  @override
  State<_SheetTable> createState() => _SheetTableState();
}

class _SheetTableState extends State<_SheetTable> {
  static const double _nameColWidth = 148.0;
  static const double _scoreColWidth = 72.0;
  static const double _avgColWidth = 60.0;
  static const double _headerH = 80.0;
  static const double _rowH = 48.0;


  static const double _goodScoreMin = 8;
  static const double _midScoreMin = 6;

  String _formatSheetScore(double score) =>
      score == score.roundToDouble()
          ? score.toStringAsFixed(0)
          : score.toStringAsFixed(1);


  final _hHead = ScrollController();
  final _hBody = ScrollController();
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _hHead.addListener(_onHead);
    _hBody.addListener(_onBody);
  }

  @override
  void dispose() {
    _hHead.dispose();
    _hBody.dispose();
    super.dispose();
  }

  void _onHead() {
    if (_syncing || !_hBody.hasClients) return;
    _syncing = true;
    _hBody.jumpTo(_hHead.offset);
    _syncing = false;
  }

  void _onBody() {
    if (_syncing || !_hHead.hasClients) return;
    _syncing = true;
    _hHead.jumpTo(_hBody.offset);
    _syncing = false;
  }

  double? _rowAvg(SheetRow row) {
    final vals =
        row.scores.where((s) => s.score != null).map((s) => s.score!).toList();
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  @override
  Widget build(BuildContext context) {
    final cols = widget.sheet.columns;
    final rows = widget.sheet.rows;

    return Column(
      children: [

        Container(
          color: Colors.white,
          child: Row(
            children: [
              _hdrCell('Ученик', width: _nameColWidth, isName: true),
              Expanded(
                child: SingleChildScrollView(
                  controller: _hHead,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    children: [
                      ...cols.map((col) => _hdrCell(
                            widget.titleIndex[col.id] ?? '—',
                            width: _scoreColWidth,
                          )),
                      _hdrCell('Ср.', width: _avgColWidth, isAvg: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.mono150),

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Column(
                  children: rows.asMap().entries.map((e) {
                    return _nameCell(e.value, rowIdx: e.key);
                  }).toList(),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _hBody,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: rows.asMap().entries.map((e) {
                        final idx = e.key;
                        final row = e.value;
                        final rowBg =
                            idx.isOdd ? AppColors.mono25 : Colors.white;
                        final scoreMap = {
                          for (final s in row.scores) s.itemId: s.score,
                        };
                        final avg = _rowAvg(row);

                        return Row(
                          children: [
                            ...cols.map((col) {
                              final score = scoreMap[col.id];
                              return _scoreCell(
                                score: score,
                                rowBg: rowBg,
                                onTap: () => _showDetails(
                                  context,
                                  studentName: row.studentName,
                                  quizTitle: widget.titleIndex[col.id] ?? '—',
                                  score: score,
                                ),
                              );
                            }),
                            _avgCell(avg, rowBg: rowBg),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _hdrCell(
    String text, {
    required double width,
    bool isName = false,
    bool isAvg = false,
  }) {
    return Container(
      width: width,
      height: _headerH,
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 10),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isName ? AppColors.mono150 : AppColors.mono100,
          ),
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isAvg ? AppColors.mono400 : AppColors.mono700,
          ),
        ),
      ),
    );
  }


  Widget _nameCell(SheetRow row, {required int rowIdx}) {
    final bg = rowIdx.isOdd ? AppColors.mono25 : Colors.white;
    return Container(
      width: _nameColWidth,
      height: _rowH,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        border: const Border(
          bottom: BorderSide(color: AppColors.mono100),
          right: BorderSide(color: AppColors.mono150),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          row.studentName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: AppColors.mono900),
        ),
      ),
    );
  }


  Widget _scoreCell({
    required double? score,
    required Color rowBg,
    required VoidCallback onTap,
  }) {
    final Color chipBg;
    final Color chipFg;
    final String label;

    if (score == null) {
      chipBg = AppColors.mono100;
      chipFg = AppColors.mono400;
      label = '—';
    } else if (score >= _goodScoreMin) {
      chipBg = const Color(0xFFDCFCE7);
      chipFg = const Color(0xFF15803D);
      label = _formatSheetScore(score);
    } else if (score >= _midScoreMin) {
      chipBg = const Color(0xFFFEF9C3);
      chipFg = const Color(0xFF854D0E);
      label = _formatSheetScore(score);
    } else {
      chipBg = const Color(0xFFFEE2E2);
      chipFg = const Color(0xFFB91C1C);
      label = _formatSheetScore(score);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _scoreColWidth,
        height: _rowH,
        color: rowBg,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: chipFg,
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _avgCell(double? avg, {required Color rowBg}) {
    return Container(
      width: _avgColWidth,
      height: _rowH,
      decoration: BoxDecoration(
        color: rowBg,
        border: const Border(
          left: BorderSide(color: AppColors.mono100),
        ),
      ),
      child: Center(
        child: avg != null
            ? Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono600,
                ),
              )
            : const Text('—',
                style: TextStyle(fontSize: 12, color: AppColors.mono200)),
      ),
    );
  }


  void _showDetails(
    BuildContext context, {
    required String studentName,
    required String quizTitle,
    required double? score,
  }) {
    final Color chipBg;
    final Color chipFg;
    final String label;

    if (score == null) {
      chipBg = AppColors.mono100;
      chipFg = AppColors.mono400;
      label = '—';
    } else if (score >= _goodScoreMin) {
      chipBg = const Color(0xFFDCFCE7);
      chipFg = const Color(0xFF15803D);
      label = _formatSheetScore(score);
    } else if (score >= _midScoreMin) {
      chipBg = const Color(0xFFFEF9C3);
      chipFg = const Color(0xFF854D0E);
      label = _formatSheetScore(score);
    } else {
      chipBg = const Color(0xFFFEE2E2);
      chipFg = const Color(0xFFB91C1C);
      label = _formatSheetScore(score);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mono150,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              quizTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.mono900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              studentName,
              style: const TextStyle(fontSize: 13, color: AppColors.mono400),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: chipFg,
                    ),
                  ),
                ),
                if (score != null) ...[
                  const SizedBox(width: 8),
                  const Text(
                    '/ 10',
                    style: TextStyle(fontSize: 14, color: AppColors.mono300),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

