import 'dart:math' as math;

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_bloc.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_event.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_state.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/template_search_cubit.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/create_quiz_screen.dart';
import 'package:edium/domain/usecases/quiz/create_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/domain/usecases/quiz/get_quizzes_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Возвращает action-label для студента по состоянию элемента курса.
/// Вызывать только когда [item.isPassed] == false.
String studentTestActionLabel(CourseItem item) {
  return switch (item.state) {
    'in_progress' => 'Продолжить →',
    'waiting' => 'Ожидает',
    'running' => 'Идёт',
    'completed' => 'Завершён',
    _ => 'Начать →',
  };
}

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseDetailBloc(
        getCourseDetail: getIt(),
        createModule: getIt(),
        courseId: courseId,
      )..add(LoadCourseDetailEvent(courseId)),
      child: const _CourseDetailView(),
    );
  }
}

// ─── Корневой вид ─────────────────────────────────────────────────────────────

class _CourseDetailView extends StatelessWidget {
  const _CourseDetailView();

  CourseDetail? _extractCourse(CourseDetailState state) {
    if (state is CourseDetailLoaded) return state.course;
    if (state is CourseModuleCreated) return state.course;
    if (state is CourseDetailActionError) return state.course;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourseDetailBloc, CourseDetailState>(
      listener: (context, state) {
        if (state is CourseModuleCreated) {
          EdiumNotification.show(context, 'Модуль создан');
        } else if (state is CourseDetailActionError) {
          EdiumNotification.show(
            context,
            state.message,
            type: EdiumNotificationType.error,
          );
        }
      },
      builder: (context, state) {
        if (state is CourseDetailLoading || state is CourseDetailInitial) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _AppBar(onBack: () => context.pop()),
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

        if (state is CourseDetailError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _AppBar(onBack: () => context.pop()),
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
                            onPressed: () {
                              final bloc = context.read<CourseDetailBloc>();
                              bloc.add(LoadCourseDetailEvent(bloc.courseId));
                            },
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

        final course = _extractCourse(state);
        if (course == null) return const SizedBox.shrink();

        return _CourseDetailBody(course: course);
      },
    );
  }
}

// ─── Основной контент ────────────────────────────────────────────────────────

class _CourseDetailBody extends StatelessWidget {
  final CourseDetail course;

  const _CourseDetailBody({required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
            const SizedBox(height: 20),
            Expanded(
              child: (course.modules.isEmpty && course.drafts.isEmpty)
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Модулей пока нет',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mono400,
                            ),
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
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.screenPaddingH,
                        8,
                        AppDimens.screenPaddingH,
                        24,
                      ),
                      itemCount: course.modules.length +
                          (course.drafts.isNotEmpty ? course.drafts.length + 1 : 0),
                      itemBuilder: (context, i) {
                        if (i < course.modules.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _ModuleSection(
                              module: course.modules[i],
                              isTeacher: course.isTeacher,
                            ),
                          );
                        }
                        final draftIndex = i - course.modules.length;
                        if (draftIndex == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 4),
                            child: _DraftsSectionHeader(),
                          );
                        }
                        final draft = course.drafts[draftIndex - 1];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _DraftTile(draft: draft),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── «+» → выбор действия ──────────────────────────────────────────────

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

  // ─── Создание модуля ────────────────────────────────────────────────────

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

  // ─── Создание квиза: новый / шаблон (с выбором модуля внутри) ───────────

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

  // ─── Поиск шаблонов (bottom sheet) ──────────────────────────────────────

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
                onSelected: (quiz) {
                  Navigator.of(sheetCtx).pop();
                  // TODO: передать данные шаблона в экран создания (pre-fill)
                  _openCreateQuizScreen(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  // ─── Навигация: создание квиза с нуля ──────────────────────────────────

  void _openCreateQuizScreen(BuildContext context) async {
    final bloc = context.read<CourseDetailBloc>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => CreateQuizBloc(
            getIt<CreateQuizUsecase>(),
            getIt<CreateSessionUsecase>(),
            inCourseContext: true,
          ),
          child: CreateQuizScreen(
            modules: course.modules,
            courseId: course.id,
          ),
        ),
      ),
    );
    if (result == true && context.mounted) {
      EdiumNotification.show(context, 'Квиз добавлен в модуль');
      bloc.add(LoadCourseDetailEvent(course.id));
    }
  }

  // ─── Локализация ────────────────────────────────────────────────────────

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

// ─── Строка в action sheet ────────────────────────────────────────────────────

class _ActionSheetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionSheetItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
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
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Icon(icon, size: 20, color: AppColors.mono600),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mono900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mono400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.mono300,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Контент поиска шаблонов (внутри bottom sheet) ────────────────────────────

class _TemplatePickerContent extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(Quiz quiz) onSelected;

  const _TemplatePickerContent({
    required this.scrollController,
    required this.onSelected,
  });

  @override
  State<_TemplatePickerContent> createState() => _TemplatePickerContentState();
}

class _TemplatePickerContentState extends State<_TemplatePickerContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 14),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Выберите шаблон',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.mono900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ── Поиск ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH,
          ),
          child: Container(
            height: AppDimens.inputH,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: TextField(
              controller: _searchController,
              cursorColor: AppColors.mono900,
              style: AppTextStyles.fieldText,
              onChanged: (v) =>
                  context.read<TemplateSearchCubit>().search(v),
              decoration: InputDecoration(
                hintText: 'Поиск шаблонов…',
                hintStyle: AppTextStyles.fieldHint,
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.mono400,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (_, value, __) => value.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            context.read<TemplateSearchCubit>().search('');
                          },
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.mono400,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ── Результаты ─────────────────────────────────────────────────
        Expanded(
          child: BlocBuilder<TemplateSearchCubit, TemplateSearchState>(
            builder: (context, state) {
              if (state is TemplateSearchLoading ||
                  state is TemplateSearchInitial) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.mono900,
                    strokeWidth: 2,
                  ),
                );
              }

              if (state is TemplateSearchError) {
                return Center(
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mono400,
                    ),
                  ),
                );
              }

              final quizzes =
                  (state as TemplateSearchLoaded).quizzes;
              final query = _searchController.text;

              if (quizzes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 40,
                        color: AppColors.mono200,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        query.isNotEmpty
                            ? 'Ничего не найдено по «$query»'
                            : 'Шаблонов пока нет',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.mono400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPaddingH,
                  4,
                  AppDimens.screenPaddingH,
                  24,
                ),
                itemCount: quizzes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _TemplateCard(
                  quiz: quizzes[i],
                  onTap: () => widget.onSelected(quizzes[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Карточка шаблона ─────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onTap;

  const _TemplateCard({required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
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
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                size: 18,
                color: AppColors.mono600,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mono900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (quiz.description != null &&
                      quiz.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      quiz.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mono400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mono100,
                      borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                    ),
                    child: Text(
                      '${quiz.questionsCount} вопр.',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mono600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.mono300,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Секция модуля ────────────────────────────────────────────────────────────

class _ModuleSection extends StatefulWidget {
  final ModuleDetail module;
  final bool isTeacher;

  const _ModuleSection({required this.module, required this.isTeacher});

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

  void _toggle() {
    if (_expanded) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
    setState(() => _expanded = !_expanded);
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
                    if (widget.module.items.isEmpty)
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
                          children: widget.module.items
                              .map((item) => _QuizItemTile(
                                    item: item,
                                    isTeacher: widget.isTeacher,
                                    onTap: item.isTestQuiz
                                        ? () {
                                            if (widget.isTeacher) {
                                              context.push(
                                                '/test/${item.refId}/results',
                                                extra: {
                                                  'courseItem': item,
                                                  'isTeacher': true,
                                                },
                                              );
                                            } else {
                                              context.push(
                                                '/test/${item.refId}',
                                                extra: {
                                                  'courseItem': item,
                                                  'isTeacher': false,
                                                },
                                              );
                                            }
                                          }
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

// ─── Карточка квиза ───────────────────────────────────────────────────────────

class _QuizItemTile extends StatelessWidget {
  final CourseItem item;
  final bool isTeacher;
  final VoidCallback? onTap;

  const _QuizItemTile({
    required this.item,
    required this.isTeacher,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: AppColors.mono150,
              width: AppDimens.borderWidth,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mono100,
                  borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                ),
                child: const Text(
                  'ТЕСТ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono400,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (isTeacher && item.needEvaluation) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mono900,
                    borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                  ),
                  child: const Text(
                    'ИИ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title ?? 'Квиз ${item.orderIndex + 1}',
                  style: AppTextStyles.fieldText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _TrailingBadge(item: item, isTeacher: isTeacher),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrailingBadge extends StatelessWidget {
  final CourseItem item;
  final bool isTeacher;
  const _TrailingBadge({required this.item, required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    if (item.isPassed) {
      final scoreText =
          '${item.score!.toStringAsFixed(item.score! % 1 == 0 ? 0 : 1)}%';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.mono100,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 13, color: AppColors.mono600),
            const SizedBox(width: 4),
            Text(
              scoreText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.mono600,
              ),
            ),
          ],
        ),
      );
    }

    if (!isTeacher) {
      final label = studentTestActionLabel(item);
      final isActionable = item.state == 'in_progress' ||
          item.state == null ||
          item.state == 'not_started';
      return Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isActionable ? FontWeight.w600 : FontWeight.w400,
          color: isActionable ? AppColors.mono900 : AppColors.mono300,
        ),
      );
    }

    final label = switch (item.state) {
      'in_progress' => 'В процессе',
      'not_started' => 'Не начат',
      'waiting'     => 'Ожидает',
      'running'     => 'Идёт',
      'completed'   => 'Завершён',
      _ => 'Не пройден',
    };
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.mono300,
      ),
    );
  }
}

// ─── Черновики ────────────────────────────────────────────────────────────────

class _DraftsSectionHeader extends StatelessWidget {
  const _DraftsSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _DashedDivider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Черновики',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.mono400,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(child: _DashedDivider()),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mono200
      ..strokeWidth = 1;
    const dashW = 5.0;
    const gapW = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(math.min(x + dashW, size.width), 0),
        paint,
      );
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => false;
}

class _DraftTile extends StatelessWidget {
  final CourseDraft draft;

  const _DraftTile({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: AppColors.mono150,
          width: AppDimens.borderWidth,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(AppDimens.radiusXs),
            ),
            child: const Text(
              'КВИЗ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.mono400,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Шаблон квиза',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.mono600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Нет в модуле',
            style: TextStyle(fontSize: 12, color: AppColors.mono300),
          ),
        ],
      ),
    );
  }
}

// ─── Шапка ────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final VoidCallback onBack;
  final Widget? trailing;

  const _AppBar({required this.onBack, this.trailing});

  @override
  Widget build(BuildContext context) {
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
            onPressed: onBack,
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
