import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/presentation/class_detail/bloc/class_detail_bloc.dart';
import 'package:edium/presentation/class_detail/bloc/class_detail_event.dart';
import 'package:edium/presentation/class_detail/bloc/class_detail_state.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ClassDetailScreen extends StatelessWidget {
  final String classId;

  const ClassDetailScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClassDetailBloc(
        getClassDetail: getIt(),
        updateClass: getIt(),
        deleteClass: getIt(),
        deleteCourse: getIt(),
        removeMember: getIt(),
        getInviteLink: getIt(),
        classId: classId,
      )..add(LoadClassDetailEvent(classId)),
      child: const _ClassDetailView(),
    );
  }
}

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

// ─── Вкладка "Курсы" ─────────────────────────────────────────────────────

class _CoursesTab extends StatelessWidget {
  final List<CourseSummary> courses;
  final bool isOwner;
  final RefreshCallback onRefresh;

  const _CoursesTab({
    required this.courses,
    required this.isOwner,
    required this.onRefresh,
  });

  Future<bool?> _confirmDeleteCourse(
    BuildContext context,
    String title,
  ) {
    return showDialog<bool>(
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
                  'Удалить курс?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Курс «$title» будет удалён. Это действие необратимо.',
                  style: const TextStyle(
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
                    onPressed: () => Navigator.of(dialogContext).pop(true),
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
                    onPressed: () => Navigator.of(dialogContext).pop(false),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: courses.isEmpty
              ? EdiumRefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 280,
                        child: Center(
                          child: Text(
                            'Курсов пока нет',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.mono400),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : EdiumRefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.screenPaddingH,
                      16,
                      AppDimens.screenPaddingH,
                      16,
                    ),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final course = courses[i];
                      final card = _CourseCard(course: course);
                      final canDelete = isOwner && course.isTeacher;

                      if (!canDelete) return card;

                      return _buildDismissible(
                        key: ValueKey(course.id),
                        confirmDismiss: (_) =>
                            _confirmDeleteCourse(context, course.title),
                        onDismissed: () {
                          context
                              .read<ClassDetailBloc>()
                              .add(DeleteCourseEvent(course.id));
                        },
                        child: card,
                      );
                    },
                  ),
                ),
        ),
        if (isOwner)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPaddingH,
              0,
              AppDimens.screenPaddingH,
              24,
            ),
            child: SizedBox(
              width: double.infinity,
              height: AppDimens.buttonH,
              child: ElevatedButton(
                onPressed: () async {
                  final bloc = context.read<ClassDetailBloc>();
                  final courseId = await context.push<String>(
                    '/course/create?classId=${bloc.classId}',
                  );
                  if (courseId != null && context.mounted) {
                    bloc.add(LoadClassDetailEvent(bloc.classId));
                    context.push(
                      '/course/$courseId',
                      extra: {'classId': bloc.classId},
                    );
                  }
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
                child: const Text('Создать курс'),
              ),
            ),
          ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseSummary course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final classId = context.read<ClassDetailBloc>().classId;
        context.push('/course/${course.id}', extra: {'classId': classId});
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: AppColors.mono150,
            width: AppDimens.borderWidth,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: AppTextStyles.fieldText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (course.isTeacher) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mono900,
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusXs),
                          ),
                          child: const Text(
                            'МОЙ',
                            style: AppTextStyles.badgeText,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.teacherName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mono400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Chip(
                        label: _modulesLabel(course.moduleCount),
                      ),
                      const SizedBox(width: 6),
                      _Chip(
                        label: _elementsLabel(course.elementCount),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.mono300,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.mono600,
        ),
      ),
    );
  }
}

// ─── Вкладки "Ученики" и "Учителя" ───────────────────────────────────────

class _MembersTab extends StatefulWidget {
  final List<MemberShort> members;
  final bool isOwner;
  final String role;
  final RefreshCallback onRefresh;

  const _MembersTab({
    required this.members,
    required this.isOwner,
    required this.role,
    required this.onRefresh,
  });

  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  late List<MemberShort> _members;

  @override
  void initState() {
    super.initState();
    _members = List.of(widget.members);
  }

  @override
  void didUpdateWidget(_MembersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.members != widget.members) {
      _members = List.of(widget.members);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = widget.isOwner;
    final canInvite = widget.isOwner;

    return Column(
      children: [
        Expanded(
          child: _members.isEmpty
              ? EdiumRefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 280,
                        child: Center(
                          child: Text(
                            widget.role == 'student'
                                ? 'Учеников пока нет'
                                : 'Учителей пока нет',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.mono400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : EdiumRefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.screenPaddingH,
                      16,
                      AppDimens.screenPaddingH,
                      16,
                    ),
                    itemCount: _members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final member = _members[i];
                      final initial = member.name.isNotEmpty
                          ? member.name[0].toUpperCase()
                          : (member.surname.isNotEmpty
                              ? member.surname[0].toUpperCase()
                              : '?');

                      final tile = Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusLg),
                          border: Border.all(
                            color: AppColors.mono150,
                            width: AppDimens.borderWidth,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.mono100,
                                borderRadius:
                                    BorderRadius.circular(AppDimens.radiusMd),
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mono600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                member.fullName,
                                style: AppTextStyles.fieldText.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );

                      if (!canDelete) return tile;

                      return _buildDismissible(
                        key: ValueKey(member.id),
                        confirmDismiss: (_) => _confirmRemoveMember(
                          context,
                          member.fullName,
                        ),
                        onDismissed: () {
                          setState(() => _members.removeAt(i));
                          context
                              .read<ClassDetailBloc>()
                              .add(RemoveMemberEvent(member.id));
                        },
                        child: tile,
                      );
                    },
                  ),
                ),
        ),
        if (canInvite)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPaddingH,
              0,
              AppDimens.screenPaddingH,
              24,
            ),
            child: SizedBox(
              width: double.infinity,
              height: AppDimens.buttonH,
              child: ElevatedButton(
                onPressed: () => context
                    .read<ClassDetailBloc>()
                    .add(GetInviteLinkEvent(widget.role)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mono900,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                  textStyle: AppTextStyles.primaryButton,
                ),
                child: const Text('Пригласить'),
              ),
            ),
          ),
      ],
    );
  }

  Future<bool?> _confirmRemoveMember(
    BuildContext context,
    String memberName,
  ) {
    return showDialog<bool>(
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
                Text(
                  widget.role == 'teacher'
                      ? 'Удалить учителя?'
                      : 'Удалить ученика?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Вы уверены, что хотите удалить $memberName из класса?',
                  style: const TextStyle(
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
                    onPressed: () => Navigator.of(dialogContext).pop(true),
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
                    onPressed: () => Navigator.of(dialogContext).pop(false),
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
}

/// Обёртка для Dismissible как на экране создания курса: без зазоров, только иконка.
Widget _buildDismissible({
  required Key key,
  required Widget child,
  required VoidCallback onDismissed,
  Future<bool?> Function(DismissDirection direction)? confirmDismiss,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
    child: Container(
      color: AppColors.error,
      child: Dismissible(
        key: key,
        direction: DismissDirection.endToStart,
        confirmDismiss: confirmDismiss,
        onDismissed: (_) => onDismissed(),
        background: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 18,
          ),
        ),
        child: child,
      ),
    ),
  );
}
