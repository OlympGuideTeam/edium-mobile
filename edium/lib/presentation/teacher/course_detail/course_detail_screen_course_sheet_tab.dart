part of 'course_detail_screen.dart';

class _CourseSheetTab extends StatefulWidget {
  final String courseId;
  final CourseDetail course;

  const _CourseSheetTab({required this.courseId, required this.course});

  @override
  State<_CourseSheetTab> createState() => _CourseSheetTabState();
}

class _CourseSheetTabState extends State<_CourseSheetTab> {
  late Future<CourseSheet> _future;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _future = getIt<GetCourseSheetUsecase>()(courseId: widget.courseId);
  }

  Map<String, String> _titlesFromCourseModules() {
    final index = <String, String>{};
    for (final module in widget.course.modules) {
      for (final item in module.items) {
        if (item.title != null) index[item.id] = item.title!;
      }
    }
    return index;
  }


  Map<String, String> _columnTitles(CourseSheet sheet) {
    final fromCourse = _titlesFromCourseModules();
    final out = <String, String>{};
    for (final c in sheet.columns) {
      final api = c.title?.trim();
      out[c.id] = (api != null && api.isNotEmpty)
          ? api
          : (fromCourse[c.id] ?? c.id);
    }
    return out;
  }

  Future<void> _export(
      CourseSheet sheet, Map<String, String> titleIndex) async {
    setState(() => _exporting = true);
    try {
      await _exportToXlsx(
        sheet: sheet,
        titleIndex: titleIndex,
        courseName: widget.course.title,
      );
    } catch (_) {
      if (mounted) {
        EdiumNotification.show(
          context,
          'Не удалось экспортировать',
          type: EdiumNotificationType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CourseSheet>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
                color: AppColors.mono900, strokeWidth: 2),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ошибка загрузки',
                  style: TextStyle(fontSize: 14, color: AppColors.mono400),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _future = getIt<GetCourseSheetUsecase>()(
                        courseId: widget.courseId);
                  }),
                  child: const Text('Повторить',
                      style: TextStyle(color: AppColors.mono900)),
                ),
              ],
            ),
          );
        }

        final sheet = snapshot.data!;
        if (sheet.rows.isEmpty) {
          return const Center(
            child: Text(
              'Нет данных о прохождениях',
              style: TextStyle(fontSize: 14, color: AppColors.mono400),
            ),
          );
        }

        final titleIndex = _columnTitles(sheet);
        return Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPaddingH, 6, AppDimens.screenPaddingH, 2),
              child: Row(
                children: [
                  Text(
                    '${sheet.rows.length} учеников · ${sheet.columns.length} квизов',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.mono400),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed:
                        _exporting ? null : () => _export(sheet, titleIndex),
                    icon: _exporting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.mono600,
                            ),
                          )
                        : const Icon(Icons.file_download_outlined, size: 18),
                    label: const Text('xlsx'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mono600,
                      textStyle: const TextStyle(fontSize: 13),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.mono100),
            Expanded(child: _SheetTable(sheet: sheet, titleIndex: titleIndex)),
          ],
        );
      },
    );
  }
}

Future<void> _exportToXlsx({
  required CourseSheet sheet,
  required Map<String, String> titleIndex,
  required String courseName,
}) async {
  final xls = xl.Excel.createExcel();
  xls.rename('Sheet1', 'Ведомость');
  final sh = xls['Ведомость'];


  final headers = <String>[
    'Ученик',
    ...sheet.columns.map((c) => titleIndex[c.id] ?? c.id),
    'Средний балл',
  ];
  for (var i = 0; i < headers.length; i++) {
    sh.cell(xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value =
        xl.TextCellValue(headers[i]);
  }


  for (var ri = 0; ri < sheet.rows.length; ri++) {
    final row = sheet.rows[ri];
    final scoreMap = {for (final s in row.scores) s.itemId: s.score};

    sh
        .cell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: ri + 1))
        .value = xl.TextCellValue(row.studentName);

    for (var ci = 0; ci < sheet.columns.length; ci++) {
      final score = scoreMap[sheet.columns[ci].id];
      final cell = sh.cell(
          xl.CellIndex.indexByColumnRow(columnIndex: ci + 1, rowIndex: ri + 1));
      cell.value =
          score != null ? xl.DoubleCellValue(score) : xl.TextCellValue('—');
    }

    final passed =
        row.scores.where((s) => s.score != null).map((s) => s.score!).toList();
    final avg =
        passed.isEmpty ? null : passed.reduce((a, b) => a + b) / passed.length;
    sh
        .cell(xl.CellIndex.indexByColumnRow(
            columnIndex: sheet.columns.length + 1, rowIndex: ri + 1))
        .value = avg != null ? xl.DoubleCellValue(avg) : xl.TextCellValue('—');
  }

  final bytes = xls.encode();
  if (bytes == null) return;

  final dir = await getTemporaryDirectory();
  final safe = courseName.replaceAll(RegExp(r'[^\wа-яёА-ЯЁ ]'), '').trim();
  final file = File('${dir.path}/${safe}_ведомость.xlsx');
  await file.writeAsBytes(bytes);
  await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: 'Ведомость — $courseName'));
}

