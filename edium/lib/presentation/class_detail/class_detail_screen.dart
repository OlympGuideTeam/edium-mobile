import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/presentation/class_detail/bloc/class_detail_bloc.dart';
import 'package:edium/presentation/class_detail/bloc/class_detail_event.dart';
import 'package:edium/presentation/class_detail/bloc/class_detail_state.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
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
        if (state is ClassTitleUpdated) {
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
                      ),
                      _MembersTab(
                        members: detail.students,
                        isOwner: detail.isOwner,
                        role: 'student',
                      ),
                      _MembersTab(
                        members: detail.teachers,
                        isOwner: detail.isOwner,
                        role: 'teacher',
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
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          title: Text(
            'Удалить класс?',
            style: AppTextStyles.heading3.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.mono900,
            ),
          ),
          content: Text(
            'Это действие необратимо. Все данные класса будут удалены.',
            style: AppTextStyles.screenSubtitle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Отмена',
                style: AppTextStyles.secondaryButton.copyWith(
                  color: AppColors.mono400,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                bloc.add(const DeleteClassEvent());
              },
              child: Text(
                'Удалить',
                style: AppTextStyles.secondaryButton.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
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

  const _CoursesTab({required this.courses, required this.isOwner});

  Future<bool?> _confirmDeleteCourse(
    BuildContext context,
    String title,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          title: Text(
            'Удалить курс?',
            style: AppTextStyles.heading3.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.mono900,
            ),
          ),
          content: Text(
            'Курс «$title» будет удалён. Это действие необратимо.',
            style: AppTextStyles.screenSubtitle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Отмена',
                style: AppTextStyles.secondaryButton.copyWith(
                  color: AppColors.mono400,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Удалить',
                style: AppTextStyles.secondaryButton.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
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
              ? const Center(
                  child: Text(
                    'Курсов пока нет',
                    style: TextStyle(fontSize: 14, color: AppColors.mono400),
                  ),
                )
              : ListView.separated(
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
                    context.push('/course/$courseId');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mono900,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusLg),
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
    final card = SizedBox(
      width: double.infinity,
      child: GestureDetector(
      onTap: () => context.push('/course/${course.id}'),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: course.isTeacher ? AppColors.mono150 : AppColors.mono200,
          width: AppDimens.borderWidth,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: AppTextStyles.fieldText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.teacherName}  ·  ${_modulesLabel(course.moduleCount)}  ·  ${_quizzesLabel(course.quizCount)}',
                  style: AppTextStyles.helperText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.mono400,
          ),
        ],
      ),
    ),
    ),
    );

    if (!course.isTeacher) {
      return Opacity(opacity: 0.45, child: card);
    }
    return card;
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

  String _quizzesLabel(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return '$count квизов';
    switch (count % 10) {
      case 1:
        return '$count квиз';
      case 2:
      case 3:
      case 4:
        return '$count квиза';
      default:
        return '$count квизов';
    }
  }
}

// ─── Вкладки "Ученики" и "Учителя" ───────────────────────────────────────

class _MembersTab extends StatelessWidget {
  final List<MemberShort> members;
  final bool isOwner;
  final String role;

  const _MembersTab({
    required this.members,
    required this.isOwner,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final canDelete = isOwner && role == 'student';
    final canInvite = isOwner;

    return Column(
      children: [
        Expanded(
          child: members.isEmpty
              ? Center(
                  child: Text(
                    role == 'student' ? 'Учеников пока нет' : 'Учителей пока нет',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mono400,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.screenPaddingH,
                    16,
                    AppDimens.screenPaddingH,
                    16,
                  ),
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final member = members[i];
                    final initial = member.name.isNotEmpty
                        ? member.name[0].toUpperCase()
                        : '?';

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
                              member.name,
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
                        member.name,
                      ),
                      onDismissed: () {
                        context
                            .read<ClassDetailBloc>()
                            .add(RemoveMemberEvent(member.id));
                      },
                      child: tile,
                    );
                  },
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
                    .add(GetInviteLinkEvent(role)),
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
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          title: Text(
            'Удалить ученика?',
            style: AppTextStyles.heading3.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.mono900,
            ),
          ),
          content: Text(
            'Вы уверены, что хотите удалить $memberName из класса?',
            style: AppTextStyles.screenSubtitle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Отмена',
                style: AppTextStyles.secondaryButton.copyWith(
                  color: AppColors.mono400,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Удалить',
                style: AppTextStyles.secondaryButton.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
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
