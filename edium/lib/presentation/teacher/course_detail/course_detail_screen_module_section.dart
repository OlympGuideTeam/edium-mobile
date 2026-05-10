part of 'course_detail_screen.dart';

class _ModuleSection extends StatefulWidget {
  final ModuleDetail module;
  final bool isTeacher;
  final String? classId;
  final String courseId;

  final int moduleListReloadToken;

  final Future<void> Function()? onReload;

  const _ModuleSection({
    required this.module,
    required this.isTeacher,
    required this.courseId,
    this.classId,
    this.moduleListReloadToken = 0,
    this.onReload,
  });

  @override
  State<_ModuleSection> createState() => _ModuleSectionState();
}

class _ModuleSectionState extends State<_ModuleSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final CurvedAnimation _curved;
  late final Animation<double> _expandAnim;
  late final Animation<double> _rotateAnim;
  late final Animation<Color?> _bgAnim;
  late final Animation<Color?> _titleColorAnim;
  late final Animation<Color?> _subtitleColorAnim;
  late final Animation<Color?> _borderColorAnim;
  bool _expanded = false;

  List<CourseItem>? _loadedItems;
  bool _itemsLoading = false;
  Map<String, SessionStatusItem> _statuses = const {};

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 230),
      vsync: this,
    );
    _curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _expandAnim = _curved;
    _rotateAnim = Tween<double>(begin: 0.0, end: 0.5).animate(_curved);
    _bgAnim = ColorTween(
      begin: Colors.white,
      end: AppColors.mono900,
    ).animate(_curved);
    _titleColorAnim = ColorTween(
      begin: AppColors.mono900,
      end: Colors.white,
    ).animate(_curved);
    _subtitleColorAnim = ColorTween(
      begin: AppColors.mono400,
      end: const Color(0x80FFFFFF),
    ).animate(_curved);
    _borderColorAnim = ColorTween(
      begin: AppColors.mono150,
      end: AppColors.mono900,
    ).animate(_curved);
  }

  @override
  void dispose() {
    _curved.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ModuleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.moduleListReloadToken != oldWidget.moduleListReloadToken &&
        _expanded) {
      _loadModuleItems();
    }
  }

  Future<void> _loadModuleItems() async {
    setState(() => _itemsLoading = true);
    try {
      final detail = await getIt<GetModuleDetailUsecase>()(
        moduleId: widget.module.id,
      );
      if (!mounted) return;
      setState(() {
        _loadedItems = detail.items;
        _itemsLoading = false;
      });

      final ids = detail.items
          .where((i) => i.refId.isNotEmpty)
          .map((i) => i.refId)
          .toList();
      if (ids.isEmpty) {
        if (mounted) setState(() => _statuses = const {});
        return;
      }
      try {
        final statuses = await getIt<GetSessionStatusesUsecase>()(ids)
            .timeout(const Duration(seconds: 1));
        if (mounted) setState(() => _statuses = statuses);
      } catch (_) {

        if (mounted) setState(() => _statuses = const {});
      }
    } catch (_) {
      if (mounted) setState(() => _itemsLoading = false);
    }
  }

  Future<void> _toggle() async {
    if (_expanded) {
      _ctrl.reverse();
      setState(() => _expanded = false);
      return;
    }
    _ctrl.forward();
    setState(() => _expanded = true);

    if (_loadedItems != null || _itemsLoading) return;
    await _loadModuleItems();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderColorAnim,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: _borderColorAnim.value!,
            width: AppDimens.borderWidth,
          ),
        ),
        child: child,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimens.radiusLg - AppDimens.borderWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggle,
                  child: Container(
                    color: _bgAnim.value,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.module.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _titleColorAnim.value,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _elementsLabel(widget.module.elementCount),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _subtitleColorAnim.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RotationTransition(
                          turns: _rotateAnim,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 22,
                            color: _titleColorAnim.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizeTransition(
              sizeFactor: _expandAnim,
              axisAlignment: -1.0,
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(height: 1, color: AppColors.mono150),
                    if (_itemsLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.mono700,
                            ),
                          ),
                        ),
                      )
                    else if (_loadedItems == null || _loadedItems!.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Text(
                          'Квизов пока нет',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mono300,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: (_loadedItems ?? [])
                              .reversed
                              .map((item) => _QuizItemTile(
                                    item: item,
                                    isTeacher: widget.isTeacher,
                                    sessionStatus: _statuses[item.refId],
                                    onTap: item.isTestQuiz
                                        ? () async {
                                            if (widget.isTeacher) {
                                              final now = DateTime.now();
                                              final p = item.payload;
                                              final isActive = p != null &&
                                                  !(p.finishedAt != null &&
                                                      now.isAfter(
                                                          p.finishedAt!)) &&
                                                  (p.startedAt == null ||
                                                      !now.isBefore(
                                                          p.startedAt!));
                                              if (isActive &&
                                                  widget.classId != null) {
                                                context.push(
                                                  '/test/${item.refId}/monitor',
                                                  extra: {
                                                    'courseItem': item,
                                                    'classId': widget.classId,
                                                  },
                                                );
                                              } else {
                                                context.push(
                                                  '/test/${item.refId}/results',
                                                  extra: {
                                                    'courseItem': item,
                                                    'isTeacher': true,
                                                    'moduleId': widget.module.id,
                                                  },
                                                );
                                              }
                                            } else {
                                              if (item.isPassed) {
                                                context.push(
                                                  '/test/${item.refId}/results',
                                                  extra: {
                                                    'courseItem': item,
                                                    'isTeacher': false,
                                                  },
                                                );
                                              } else {
                                                final completed =
                                                    await context.push<bool>(
                                                  '/test/${item.refId}',
                                                  extra: {
                                                    'courseItem': item,
                                                    'isTeacher': false,
                                                    'courseId': widget.courseId,
                                                  },
                                                );
                                                if (completed == true &&
                                                    context.mounted) {
                                                  await widget.onReload?.call();
                                                }
                                              }
                                            }
                                          }
                                        : item.quizType == 'live'
                                            ? () => _onLiveItemTap(
                                                  context,
                                                  item,
                                                  widget.module.id,
                                                  _statuses[item.refId],
                                                )
                                            : null,
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLiveItemTap(
    BuildContext context,
    CourseItem item,
    String moduleId,
    SessionStatusItem? sessionStatus,
  ) {
    if (widget.isTeacher) {
      context.push(
        '/live/${item.refId}/teacher',
        extra: {
          'quizTitle': item.title ?? '',
          'questionCount': 0,
          'moduleId': moduleId,
        },
      );
    } else {
      final isFinished = sessionStatus?.status == 'finished' ||
          item.isPassed ||
          item.state == 'completed';
      if (isFinished) {
        if (item.attemptId != null) {
          context.push('/test/${item.refId}/attempts/${item.attemptId}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Результаты пока недоступны'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      _joinLiveAsStudent(context, item, moduleId);
    }
  }

  Future<void> _joinLiveAsStudent(
    BuildContext ctx,
    CourseItem item,
    String moduleId,
  ) async {
    final repo = getIt<ILiveRepository>();
    final nav = Navigator.of(ctx, rootNavigator: true);
    final router = GoRouter.of(ctx);
    final messenger = ScaffoldMessenger.of(ctx);
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final join = await repo.joinLiveSession(sessionId: item.refId);
      if (!mounted) return;
      nav.pop();
      router.push(
        '/live/${item.refId}/student',
        extra: {
          'attemptId': join.attemptId,
          'wsToken': join.wsToken,
          'quizTitle': item.title ?? '',
          'questionCount': 0,
          'moduleId': join.moduleId ?? moduleId,
        },
      );
    } catch (e) {
      if (!mounted) return;
      nav.pop();
      if (!ctx.mounted) return;
      if (tryNavigateLiveStudentAfterJoinSessionCompleted(
            e,
            context: ctx,
            sessionId: item.refId,
            quizTitle: item.title ?? '',
            questionCount: 0,
            moduleId: moduleId,
          )) {
        return;
      }

      final isConflict = e is ApiException &&
          (e.statusCode == 409 || e.code == 'SESSION_COMPLETED');
      if (isConflict && item.attemptId != null) {
        router.push(
          '/live/${item.refId}/student',
          extra: {
            'attemptId': item.attemptId!,
            'wsToken': '',
            'quizTitle': item.title ?? '',
            'questionCount': 0,
            'moduleId': moduleId,
          },
        );
        return;
      }
      final msg = e is ApiException ? e.message : 'Ошибка входа: $e';
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  String _elementsLabel(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return '$count элементов';
    switch (count % 10) {
      case 1:
        return '$count элемент';
      case 2:
      case 3:
      case 4:
        return '$count элемента';
      default:
        return '$count элементов';
    }
  }
}

