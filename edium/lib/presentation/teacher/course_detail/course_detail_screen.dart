import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_bloc.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_event.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
                      onPressed: () =>
                          _showCreateModuleSheet(context, course.id),
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
              child: course.modules.isEmpty
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
                              onPressed: () =>
                                  _showCreateModuleSheet(context, course.id),
                              child: const Text(
                                'Создать первый модуль',
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
                      itemCount: course.modules.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _ModuleSection(module: course.modules[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateModuleSheet(BuildContext context, String courseId) {
    final bloc = context.read<CourseDetailBloc>();
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

// ─── Секция модуля ────────────────────────────────────────────────────────────
//
// Дизайн:
//  - Одна карточка с border (mono150) и border-radius. Форма никогда не меняется.
//  - Хедер внутри карточки анимирует цвет: белый (свёрнуто) → чёрный (раскрыто).
//  - Контент скользит вниз через SizeTransition внутри той же карточки.
//  - Боковые бордеры карточки «вырастают» автоматически — одна геометрия.

class _ModuleSection extends StatefulWidget {
  final ModuleDetail module;

  const _ModuleSection({required this.module});

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
    // Внешняя карточка — форма фиксирована, border анимируется mono150 → mono900
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
      // ClipRRect прячет цветной хедер внутри скруглений карточки
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimens.radiusLg - AppDimens.borderWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Хедер: цвет анимируется белый → чёрный ──────────────────
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

            // ── Контент: скользит вниз внутри той же карточки ───────────
            SizeTransition(
              sizeFactor: _expandAnim,
              axisAlignment: -1.0,
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(height: 1, color: AppColors.mono150),
                    widget.module.items.isEmpty
                        ? const Padding(
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
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: widget.module.items
                                  .map((item) => _QuizItemTile(item: item))
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

  const _QuizItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isPassed = item.isPassed;
    final scoreText = isPassed
        ? '${item.score!.toStringAsFixed(item.score! % 1 == 0 ? 0 : 1)}%'
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
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
            Expanded(
              child: Text(
                'Квиз ${item.orderIndex + 1}',
                style: AppTextStyles.fieldText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (isPassed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mono100,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 13,
                      color: AppColors.mono600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      scoreText!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mono600,
                      ),
                    ),
                  ],
                ),
              )
            else
              const Text(
                'Не пройден',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mono300,
                ),
              ),
          ],
        ),
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
