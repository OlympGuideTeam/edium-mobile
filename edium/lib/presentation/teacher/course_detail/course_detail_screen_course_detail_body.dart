part of 'course_detail_screen.dart';

class _CourseDetailBody extends StatelessWidget {
  final CourseDetail course;
  final String? classId;

  const _CourseDetailBody({required this.course, this.classId});

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AppBar(
            onBack: () => context.pop(),
            trailing: course.isTeacher
                ? IconButton(
                    icon: const Icon(
                      Icons.add,
                      size: 22,
                      color: AppColors.mono900,
                    ),
                    onPressed: () => _showAddActionSheet(context),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.screenPaddingH,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: AppTextStyles.screenTitle),
                const SizedBox(height: 4),
                Text(
                  '${course.teacherName}  ·  '
                  '${_modulesLabel(course.moduleCount)}  ·  '
                  '${_elementsLabel(course.elementCount)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mono400,
                  ),
                ),
              ],
            ),
          ),
          if (course.isTeacher) ...[
            const SizedBox(height: 8),
            TabBar(
              labelColor: AppColors.mono900,
              unselectedLabelColor: AppColors.mono400,
              indicatorColor: AppColors.mono900,
              indicatorWeight: 2,
              splashFactory: NoSplash.splashFactory,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [Tab(text: 'Модули'), Tab(text: 'Ведомость')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _modulesContent(context),
                  _CourseSheetTab(courseId: course.id, course: course),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Expanded(child: _modulesContent(context)),
          ],
        ],
      ),
    );

    final scaffold = Scaffold(backgroundColor: Colors.white, body: body);
    if (course.isTeacher) {
      return DefaultTabController(length: 2, child: scaffold);
    }
    return scaffold;
  }

  Widget _modulesContent(BuildContext context) {
    if (course.modules.isEmpty &&
        (!course.isTeacher || course.drafts.isEmpty)) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Модулей пока нет',
              style: TextStyle(fontSize: 14, color: AppColors.mono400),
            ),
            if (course.isTeacher) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _showAddActionSheet(context),
                child: const Text(
                  'Добавить первый элемент',
                  style: TextStyle(color: AppColors.mono900),
                ),
              ),
            ],
          ],
        ),
      );
    }
    final bloc = context.read<CourseDetailBloc>();
    return _CourseContentList(
      course: course,
      classId: classId,
      onDraftTap: (draft) => _openCreateQuizFromDraft(context, draft),
      onDraftDelete: (draft) => bloc.add(DeleteDraftEvent(draft.id)),
      onModulesReorder: (ids) => bloc.add(ReorderModulesEvent(ids)),
      onRefresh: () async {
        bloc.add(SilentReloadCourseDetailEvent(course.id));
        await bloc.stream.firstWhere(
            (s) => s is CourseDetailLoaded || s is CourseDetailError);
      },
    );
  }


  void _showAddActionSheet(BuildContext context) {
    final bloc = context.read<CourseDetailBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPaddingH,
            24,
            AppDimens.screenPaddingH,
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Что добавить?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ActionSheetItem(
                icon: Icons.folder_outlined,
                title: 'Модуль',
                subtitle: 'Группа квизов и материалов',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _showCreateModuleSheet(context, bloc);
                },
              ),
              const SizedBox(height: 10),
              _ActionSheetItem(
                icon: Icons.quiz_outlined,
                title: 'Квиз',
                subtitle: 'Новый квиз или из шаблона',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _showCreateQuizFlow(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }


  void _showCreateModuleSheet(BuildContext context, CourseDetailBloc bloc) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.screenPaddingH,
            24,
            AppDimens.screenPaddingH,
            MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 20),
              const Text(
                'Новый модуль',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: AppDimens.inputH,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(
                    color: AppColors.mono250,
                    width: AppDimens.borderWidth,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  cursorColor: AppColors.mono900,
                  style: AppTextStyles.fieldText,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Название модуля',
                    hintStyle: AppTextStyles.fieldHint,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: AppDimens.buttonH,
                child: ElevatedButton(
                  onPressed: () {
                    final title = controller.text.trim();
                    if (title.isEmpty) return;
                    bloc.add(CreateModuleEvent(title));
                    Navigator.of(sheetCtx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mono900,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                    textStyle: AppTextStyles.primaryButton,
                  ),
                  child: const Text('Создать'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void _showCreateQuizFlow(BuildContext context) {
    if (course.modules.isEmpty) {
      EdiumNotification.show(
        context,
        'Сначала создайте модуль',
        type: EdiumNotificationType.error,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPaddingH,
            24,
            AppDimens.screenPaddingH,
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Создание квиза',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ActionSheetItem(
                icon: Icons.add_circle_outline,
                title: 'Создать новый',
                subtitle: 'Пустой квиз с нуля',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _openCreateQuizScreen(context);
                },
              ),
              const SizedBox(height: 10),
              _ActionSheetItem(
                icon: Icons.auto_awesome_outlined,
                title: 'Использовать шаблон',
                subtitle: 'Выберите готовый шаблон квиза',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _showTemplatePickerSheet(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }


  void _showTemplatePickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return BlocProvider(
          create: (_) => TemplateSearchCubit(getIt<GetQuizzesUsecase>()),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            builder: (_, scrollCtrl) {
              return _TemplatePickerContent(
                scrollController: scrollCtrl,
                onSelected: (quiz) async {
                  Navigator.of(sheetCtx).pop();
                  Quiz? full;
                  try {
                    full = await getIt<IQuizRepository>().getQuizById(quiz.id);
                  } catch (_) {}
                  if (!context.mounted) return;
                  if (full == null) {
                    EdiumNotification.show(
                      context,
                      'Не удалось загрузить шаблон',
                      type: EdiumNotificationType.error,
                    );
                    return;
                  }
                  await _openCreateQuizScreen(
                    context,
                    initialState: createQuizStateFromQuiz(
                      full,
                      inCourseContext: true,
                      treatAsExistingCourseTemplate: false,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }


  Future<void> _openCreateQuizFromDraft(
    BuildContext context,
    CourseDraft draft,
  ) async {
    Quiz? loaded;
    try {
      loaded = await getIt<IQuizRepository>().getQuizById(draft.quizTemplateId);
    } catch (_) {}
    if (!context.mounted) return;
    if (loaded == null) {
      EdiumNotification.show(
        context,
        'Не удалось загрузить черновик',
        type: EdiumNotificationType.error,
      );
      return;
    }
    final initial = createQuizStateFromQuiz(
      loaded,
      courseDraftPayload: draft.payload,
      inCourseContext: true,
      treatAsExistingCourseTemplate: true,
    );
    await _openCreateQuizScreen(context, initialState: initial);
  }

  Future<void> _openCreateQuizScreen(
    BuildContext context, {
    CreateQuizState? initialState,
  }) async {
    final bloc = context.read<CourseDetailBloc>();
    final result = await Navigator.push<CreateQuizState>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => CreateQuizBloc(
            getIt<CreateQuizUsecase>(),
            getIt<CreateSessionUsecase>(),
            getIt<IQuizRepository>(),
            initialState: initialState,
            inCourseContext: initialState == null,
          ),
          child: CreateQuizScreen(
            modules: course.modules,
            courseId: course.id,
          ),
        ),
      ),
    );
    if (result != null && context.mounted) {

      if (result.quizType == QuizCreationMode.live &&
          result.liveSessionId != null) {
        context.push(
          '/live/${result.liveSessionId}/teacher',
          extra: {
            'quizTitle': result.title,
            'questionCount': result.questions.length,
            if (result.submittedModuleId != null)
              'moduleId': result.submittedModuleId,
          },
        );
      }


      bloc.add(OptimisticQuizAddedEvent(
        title: result.title,
        mode: _quizModeString(result.quizType),
        moduleId: result.submittedModuleId,
        existingTemplateId: result.existingQuizTemplateId,
        totalTimeLimitSec: result.totalTimeLimitSec,
        questionTimeLimitSec: result.questionTimeLimitSec,
        shuffleQuestions: result.shuffleQuestions,
        startedAt: result.startedAt,
        finishedAt: result.finishedAt,
      ));


      if (result.submittedModuleId != null) {
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            bloc.add(SilentReloadCourseDetailEvent(course.id));
          }
        });
      }
    }
  }

  static String _quizModeString(QuizCreationMode mode) => switch (mode) {
        QuizCreationMode.live => 'live',
        QuizCreationMode.test => 'test',
        QuizCreationMode.template => 'test',
      };


  String _modulesLabel(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return '$count модулей';
    switch (count % 10) {
      case 1:
        return '$count модуль';
      case 2:
      case 3:
      case 4:
        return '$count модуля';
      default:
        return '$count модулей';
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

