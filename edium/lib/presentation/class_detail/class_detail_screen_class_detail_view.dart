part of 'class_detail_screen.dart';

class _ClassDetailView extends StatefulWidget {
  const _ClassDetailView();

  @override
  State<_ClassDetailView> createState() => _ClassDetailViewState();
}

class _ClassDetailViewState extends State<_ClassDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ClassDetail? _extractDetail(ClassDetailState state) {
    if (state is ClassDetailLoaded) return state.classDetail;
    if (state is ClassTitleUpdated) return state.classDetail;
    if (state is MemberRemoved) return state.classDetail;
    if (state is CourseDeleted) return state.classDetail;
    if (state is InviteLinkCopied) return state.classDetail;
    if (state is ClassDetailActionError) return state.classDetail;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClassDetailBloc, ClassDetailState>(
      listener: (context, state) {
        if (state is ClassNotFound) {
          context.pop();
          EdiumNotification.show(
            context,
            'Класс не найден',
            type: EdiumNotificationType.error,
          );
        } else if (state is ClassTitleUpdated) {
          EdiumNotification.show(context, 'Название обновлено');
        } else if (state is ClassDeleted) {
          context.pop();
        } else if (state is MemberRemoved) {
          EdiumNotification.show(context, 'Участник удалён');
        } else if (state is CourseDeleted) {
          EdiumNotification.show(context, 'Курс удалён');
        } else if (state is InviteLinkCopied) {
          Clipboard.setData(ClipboardData(text: state.link));
          EdiumNotification.show(context, 'Ссылка скопирована');
        } else if (state is ClassDetailActionError) {
          EdiumNotification.show(
            context,
            state.message,
            type: EdiumNotificationType.error,
          );
        }
      },
      builder: (context, state) {
        final detail = _extractDetail(state);

        if (state is ClassDetailLoading || state is ClassDetailInitial) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, null),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mono900,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ClassDetailError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, null),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Ошибка загрузки',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mono400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context
                                .read<ClassDetailBloc>()
                                .add(LoadClassDetailEvent(
                                    context.read<ClassDetailBloc>().classId)),
                            child: const Text(
                              'Повторить',
                              style: TextStyle(color: AppColors.mono900),
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

        if (detail == null) return const SizedBox.shrink();

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context, detail),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(detail.title, style: AppTextStyles.screenTitle),
                      const SizedBox(height: 4),
                      Text(
                        '${detail.ownerName}  ·  ${_studentLabel(detail.studentCount)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.mono400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.mono900,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelColor: AppColors.mono350,
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  indicatorColor: AppColors.mono900,
                  indicatorWeight: 2.0,
                  dividerColor: AppColors.mono100,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH,
                  ),
                  tabs: const [
                    Tab(text: 'Курсы'),
                    Tab(text: 'Ученики'),
                    Tab(text: 'Учителя'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _CoursesTab(
                        courses: detail.courses,
                        isOwner: detail.isOwner,
                        onRefresh: () async {
                          final bloc = context.read<ClassDetailBloc>();
                          bloc.add(LoadClassDetailEvent(bloc.classId));
                          await bloc.stream.firstWhere((s) =>
                              s is ClassDetailLoaded ||
                              s is ClassDetailError ||
                              s is ClassNotFound);
                        },
                      ),
                      _MembersTab(
                        members: detail.students,
                        isOwner: detail.isOwner,
                        role: 'student',
                        onRefresh: () async {
                          final bloc = context.read<ClassDetailBloc>();
                          bloc.add(LoadClassDetailEvent(bloc.classId));
                          await bloc.stream.firstWhere((s) =>
                              s is ClassDetailLoaded ||
                              s is ClassDetailError ||
                              s is ClassNotFound);
                        },
                      ),
                      _MembersTab(
                        members: detail.teachers,
                        isOwner: detail.isOwner,
                        role: 'teacher',
                        onRefresh: () async {
                          final bloc = context.read<ClassDetailBloc>();
                          bloc.add(LoadClassDetailEvent(bloc.classId));
                          await bloc.stream.firstWhere((s) =>
                              s is ClassDetailLoaded ||
                              s is ClassDetailError ||
                              s is ClassNotFound);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, ClassDetail? detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.mono900,
            ),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
          if (detail != null && detail.isOwner)
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                size: 22,
                color: AppColors.mono900,
              ),
              onPressed: () => _showEditSheet(context, detail),
            ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, ClassDetail detail) {
    final bloc = context.read<ClassDetailBloc>();
    final controller = TextEditingController(text: detail.title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.screenPaddingH,
            24,
            AppDimens.screenPaddingH,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
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
                'Редактировать',
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
                  decoration: const InputDecoration(
                    hintText: 'Название класса',
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
                    if (title.isEmpty || title == detail.title) {
                      Navigator.of(sheetContext).pop();
                      return;
                    }
                    bloc.add(UpdateClassTitleEvent(title));
                    Navigator.of(sheetContext).pop();
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
                  child: const Text('Сохранить'),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _showDeleteClassDialog(context, bloc);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  child: const Text(
                    'Удалить класс',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteClassDialog(BuildContext context, ClassDetailBloc bloc) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Удалить класс?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Это действие необратимо. Все данные класса будут удалены.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mono600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonHSm,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      bloc.add(const DeleteClassEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mono900,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Удалить',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonHSm,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.mono150),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      ),
                    ),
                    child: const Text(
                      'Отмена',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mono700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _studentLabel(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return '$count учеников';
    switch (count % 10) {
      case 1:
        return '$count ученик';
      case 2:
      case 3:
      case 4:
        return '$count ученика';
      default:
        return '$count учеников';
    }
  }
}

