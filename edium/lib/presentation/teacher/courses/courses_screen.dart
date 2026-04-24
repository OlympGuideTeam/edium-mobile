import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/domain/entities/class_summary.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/usecases/class/get_class_detail_usecase.dart';
import 'package:edium/domain/usecases/class/get_my_classes_usecase.dart';
import 'package:edium/domain/usecases/course/get_course_detail_usecase.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/create_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<ClassSummary> _classes = [];
  bool _isLoading = true;
  String? _error;

  final Set<String> _expandedClasses = {};
  final Map<String, ClassDetail> _classDetails = {};
  final Set<String> _loadingClasses = {};

  final Set<String> _expandedCourses = {};
  final Map<String, CourseDetail> _courseDetails = {};
  final Set<String> _loadingCourses = {};

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final classes = await getIt<GetMyClassesUsecase>()(role: 'teacher');
      if (mounted) {
        setState(() {
          _classes = classes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleClass(String classId) async {
    if (_expandedClasses.contains(classId)) {
      setState(() => _expandedClasses.remove(classId));
      return;
    }
    setState(() => _expandedClasses.add(classId));
    if (_classDetails.containsKey(classId) || _loadingClasses.contains(classId)) return;
    setState(() => _loadingClasses.add(classId));
    try {
      final detail = await getIt<GetClassDetailUsecase>()(classId: classId);
      if (mounted) {
        setState(() {
          _classDetails[classId] = detail;
          _loadingClasses.remove(classId);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingClasses.remove(classId));
    }
  }

  Future<void> _toggleCourse(String courseId) async {
    if (_expandedCourses.contains(courseId)) {
      setState(() => _expandedCourses.remove(courseId));
      return;
    }
    setState(() => _expandedCourses.add(courseId));
    if (_courseDetails.containsKey(courseId) || _loadingCourses.contains(courseId)) return;
    setState(() => _loadingCourses.add(courseId));
    try {
      final detail = await getIt<GetCourseDetailUsecase>()(courseId: courseId);
      if (mounted) {
        setState(() {
          _courseDetails[courseId] = detail;
          _loadingCourses.remove(courseId);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCourses.remove(courseId));
    }
  }

  void _openAddQuiz(String moduleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => CreateQuizBloc(
            getIt(),
            getIt<CreateSessionUsecase>(),
            getIt<IQuizRepository>(),
            inCourseContext: true,
          ),
          child: CreateQuizScreen(preselectedModuleId: moduleId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPaddingH, 32, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.mono900,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusXs),
                    ),
                    child: const Text('УЧИТЕЛЬ',
                        style: AppTextStyles.badgeText),
                  ),
                  const SizedBox(height: 12),
                  const Text('Курсы', style: AppTextStyles.screenTitle),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.mono700,
          strokeWidth: 2,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.mono400, size: 48),
            const SizedBox(height: 12),
            Text('Ошибка загрузки', style: AppTextStyles.screenSubtitle),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() { _isLoading = true; _error = null; });
                _loadClasses();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.mono900,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: const Text('Повторить',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    }

    if (_classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school_outlined, size: 48, color: AppColors.mono200),
            const SizedBox(height: 12),
            Text('Классов пока нет',
                style: AppTextStyles.fieldText
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Создайте класс на вкладке «Классы»',
                style: AppTextStyles.screenSubtitle),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.mono900,
      onRefresh: () async {
        setState(() {
          _isLoading = true;
          _error = null;
          _classDetails.clear();
          _courseDetails.clear();
          _expandedClasses.clear();
          _expandedCourses.clear();
        });
        await _loadClasses();
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPaddingH, 0, AppDimens.screenPaddingH, 32),
        itemCount: _classes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _ClassSection(
          cls: _classes[i],
          isExpanded: _expandedClasses.contains(_classes[i].id),
          isLoading: _loadingClasses.contains(_classes[i].id),
          detail: _classDetails[_classes[i].id],
          onToggle: () => _toggleClass(_classes[i].id),
          expandedCourses: _expandedCourses,
          loadingCourses: _loadingCourses,
          courseDetails: _courseDetails,
          onToggleCourse: _toggleCourse,
          onAddQuiz: _openAddQuiz,
        ),
      ),
    );
  }
}

// ─── Class section ────────────────────────────────────────────────────────────

class _ClassSection extends StatelessWidget {
  final ClassSummary cls;
  final bool isExpanded;
  final bool isLoading;
  final ClassDetail? detail;
  final VoidCallback onToggle;
  final Set<String> expandedCourses;
  final Set<String> loadingCourses;
  final Map<String, CourseDetail> courseDetails;
  final Future<void> Function(String courseId) onToggleCourse;
  final void Function(String moduleId) onAddQuiz;

  const _ClassSection({
    required this.cls,
    required this.isExpanded,
    required this.isLoading,
    required this.detail,
    required this.onToggle,
    required this.expandedCourses,
    required this.loadingCourses,
    required this.courseDetails,
    required this.onToggleCourse,
    required this.onAddQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: isExpanded ? AppColors.mono900 : AppColors.mono150,
          width: AppDimens.borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            AppDimens.radiusLg - AppDimens.borderWidth),
        child: Column(
          children: [
            // Class header
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: isExpanded ? AppColors.mono900 : Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cls.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isExpanded
                                  ? Colors.white
                                  : AppColors.mono900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${cls.studentCount} ${_studentsLabel(cls.studentCount)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isExpanded
                                  ? Colors.white60
                                  : AppColors.mono400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isExpanded ? Colors.white : AppColors.mono700,
                        ),
                      )
                    else
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 22,
                          color: isExpanded ? Colors.white : AppColors.mono700,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Courses list
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpanded && detail != null
                  ? Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(height: 1, color: AppColors.mono100),
                          if (detail!.courses.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              child: Text(
                                'Курсов пока нет',
                                style: TextStyle(
                                    fontSize: 13, color: AppColors.mono300),
                              ),
                            )
                          else
                            ...detail!.courses.map((course) => _CourseSection(
                                  course: course,
                                  isExpanded:
                                      expandedCourses.contains(course.id),
                                  isLoading:
                                      loadingCourses.contains(course.id),
                                  detail: courseDetails[course.id],
                                  onToggle: () => onToggleCourse(course.id),
                                  onAddQuiz: onAddQuiz,
                                )),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  String _studentsLabel(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return 'учеников';
    switch (count % 10) {
      case 1:
        return 'ученик';
      case 2:
      case 3:
      case 4:
        return 'ученика';
      default:
        return 'учеников';
    }
  }
}

// ─── Course section ───────────────────────────────────────────────────────────

class _CourseSection extends StatelessWidget {
  final CourseSummary course;
  final bool isExpanded;
  final bool isLoading;
  final CourseDetail? detail;
  final VoidCallback onToggle;
  final void Function(String moduleId) onAddQuiz;

  const _CourseSection({
    required this.course,
    required this.isExpanded,
    required this.isLoading,
    required this.detail,
    required this.onToggle,
    required this.onAddQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.mono50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.mono100),
                  ),
                  child: const Icon(Icons.school_outlined,
                      size: 16, color: AppColors.mono400),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mono900,
                        ),
                      ),
                      Text(
                        '${_modulesLabel(course.moduleCount)}  ·  ${_quizzesLabel(course.elementCount)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.mono400),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.mono700),
                  )
                else
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        size: 20, color: AppColors.mono400),
                  ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOut,
          child: isExpanded && detail != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: detail!.modules
                      .map((module) => _ModuleSection(
                            module: module,
                            onAddQuiz: () => onAddQuiz(module.id),
                          ))
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
        const Divider(height: 1, color: AppColors.mono100),
      ],
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

  String _quizzesLabel(int count) {
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

// ─── Module section ───────────────────────────────────────────────────────────

class _ModuleSection extends StatelessWidget {
  final ModuleDetail module;
  final VoidCallback onAddQuiz;

  const _ModuleSection({required this.module, required this.onAddQuiz});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.mono25,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.mono100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mono900,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onAddQuiz,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.mono900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (module.items.isNotEmpty)
              ...module.items.map((item) => _ItemTile(item: item)),
            if (module.items.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Text(
                  'Квизов нет',
                  style: TextStyle(fontSize: 12, color: AppColors.mono300),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Item tile ────────────────────────────────────────────────────────────────

class _ItemTile extends StatelessWidget {
  final CourseItem item;

  const _ItemTile({required this.item});

  bool get _isTemplate => item.type == 'quiz_template';

  @override
  Widget build(BuildContext context) {
    final isPassed = item.isPassed;
    final scoreText = isPassed
        ? '${item.score!.toStringAsFixed(item.score! % 1 == 0 ? 0 : 1)}%'
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Row(
        children: [
          _TypeBadge(isTemplate: _isTemplate),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Квиз ${item.orderIndex + 1}',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.mono900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (isPassed)
            _ScoreBadge(score: scoreText!)
          else
            const Text(
              'Не пройден',
              style: TextStyle(fontSize: 11, color: AppColors.mono300),
            ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final bool isTemplate;
  const _TypeBadge({required this.isTemplate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isTemplate ? AppColors.mono100 : AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        isTemplate ? 'ШАБЛОН' : 'КВИЗ',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: isTemplate ? AppColors.mono400 : Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.mono100,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 11, color: AppColors.mono600),
          const SizedBox(width: 3),
          Text(
            score,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.mono600,
            ),
          ),
        ],
      ),
    );
  }
}
