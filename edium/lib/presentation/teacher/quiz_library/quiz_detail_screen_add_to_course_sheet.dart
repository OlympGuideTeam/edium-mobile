part of 'quiz_detail_screen.dart';

class _AddToCourseSheet extends StatefulWidget {
  final String quizId;

  const _AddToCourseSheet({required this.quizId});

  @override
  State<_AddToCourseSheet> createState() => _AddToCourseSheetState();
}

class _AddToCourseSheetState extends State<_AddToCourseSheet> {
  final _searchCtrl = TextEditingController();


  int _step = 0;
  CourseSummary? _selectedCourse;
  ModuleDetail? _selectedModule;
  SessionType _sessionType = SessionType.test;


  List<_CourseEntry> _courses = [];
  CourseDetail? _courseDetail;
  bool _loadingCourses = true;
  bool _loadingDetail = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      final classes = await getIt<GetMyClassesUsecase>()(role: 'teacher');
      final entries = <_CourseEntry>[];
      for (final cls in classes) {
        final detail = await getIt<GetClassDetailUsecase>()(classId: cls.id);
        for (final course in detail.courses) {
          entries.add(_CourseEntry(className: cls.title, course: course));
        }
      }
      if (mounted) setState(() { _courses = entries; _loadingCourses = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  Future<void> _selectCourse(CourseSummary course) async {
    setState(() { _selectedCourse = course; _loadingDetail = true; _step = 1; });
    try {
      final detail = await getIt<GetCourseDetailUsecase>()(courseId: course.id);
      if (mounted) setState(() { _courseDetail = detail; _loadingDetail = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedModule == null) return;
    setState(() => _submitting = true);
    try {
      await getIt<CreateSessionUsecase>()(
        quizTemplateId: widget.quizId,
        moduleId: _selectedModule!.id,
        sessionType: _sessionType,
      );
      if (mounted) {
        Navigator.pop(context);
        EdiumNotification.show(
          context,
          _sessionType == SessionType.test ? 'Тест добавлен в курс' : 'Лайв добавлен в курс',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        EdiumNotification.show(
          context,
          'Ошибка',
          type: EdiumNotificationType.error,
        );
      }
    }
  }

  List<_CourseEntry> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _courses;
    return _courses
        .where((e) =>
            e.course.title.toLowerCase().contains(q) ||
            e.className.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        return Column(
          children: [

            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mono150,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
              child: Row(
                children: [
                  if (_step == 1)
                    GestureDetector(
                      onTap: () => setState(() {
                        _step = 0;
                        _selectedCourse = null;
                        _courseDetail = null;
                        _selectedModule = null;
                      }),
                      child: const Icon(Icons.arrow_back,
                          size: 20, color: AppColors.mono700),
                    ),
                  if (_step == 1) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _step == 0
                          ? 'Добавить в курс'
                          : _selectedCourse?.title ?? 'Выбрать модуль',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mono900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (_step == 0) ...[

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.mono25,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(color: AppColors.mono100),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    cursorColor: AppColors.mono900,
                    style: const TextStyle(fontSize: 14, color: AppColors.mono700),
                    decoration: const InputDecoration(
                      hintText: 'Поиск курса...',
                      hintStyle: TextStyle(fontSize: 14, color: AppColors.mono250),
                      prefixIcon: Icon(Icons.search, size: 18, color: AppColors.mono250),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loadingCourses
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.mono700,
                          strokeWidth: 2,
                        ),
                      )
                    : _filtered.isEmpty
                        ? Center(
                            child: Text(
                              'Курсы не найдены',
                              style: AppTextStyles.screenSubtitle,
                            ),
                          )
                        : ListView.builder(
                            controller: scrollCtrl,
                            padding: const EdgeInsets.fromLTRB(
                                AppDimens.screenPaddingH,
                                4,
                                AppDimens.screenPaddingH,
                                24),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) {
                              final entry = _filtered[i];
                              return _CoursePickerTile(
                                entry: entry,
                                onTap: () => _selectCourse(entry.course),
                              );
                            },
                          ),
              ),
            ] else ...[

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ТИП',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mono400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _SessionTypePill(
                          label: 'Тест',
                          icon: Icons.timer_outlined,
                          isActive: _sessionType == SessionType.test,
                          onTap: () =>
                              setState(() => _sessionType = SessionType.test),
                        ),
                        const SizedBox(width: 8),
                        _SessionTypePill(
                          label: 'Лайв',
                          icon: Icons.bolt_outlined,
                          isActive: _sessionType == SessionType.live,
                          onTap: () =>
                              setState(() => _sessionType = SessionType.live),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'МОДУЛЬ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mono400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loadingDetail
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.mono700,
                          strokeWidth: 2,
                        ),
                      )
                    : _courseDetail == null || _courseDetail!.modules.isEmpty
                        ? Center(
                            child: Text(
                              'Модули не найдены',
                              style: AppTextStyles.screenSubtitle,
                            ),
                          )
                        : ListView.builder(
                            controller: scrollCtrl,
                            padding: const EdgeInsets.fromLTRB(
                                AppDimens.screenPaddingH,
                                4,
                                AppDimens.screenPaddingH,
                                100),
                            itemCount: _courseDetail!.modules.length,
                            itemBuilder: (_, i) {
                              final module = _courseDetail!.modules[i];
                              final isSelected = _selectedModule?.id == module.id;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedModule = module),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.mono900
                                        : AppColors.mono25,
                                    borderRadius:
                                        BorderRadius.circular(AppDimens.radiusMd),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.mono900
                                          : AppColors.mono100,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          module.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.mono900,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check_circle,
                                            size: 18, color: Colors.white),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.screenPaddingH,
                  0,
                  AppDimens.screenPaddingH,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                child: EdiumButton(
                  label: _sessionType == SessionType.test
                      ? 'Добавить тест'
                      : 'Добавить лайв',
                  onPressed: _selectedModule != null && !_submitting
                      ? _submit
                      : null,
                  isLoading: _submitting,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

