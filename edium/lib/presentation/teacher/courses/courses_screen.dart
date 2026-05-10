import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/domain/entities/class_summary.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/usecases/class/get_class_detail_usecase.dart';
import 'package:edium/domain/usecases/class/get_my_classes_usecase.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:edium/domain/usecases/course/get_course_detail_usecase.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/create_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'courses_screen_class_section.dart';
part 'courses_screen_course_section.dart';
part 'courses_screen_module_section.dart';
part 'courses_screen_item_tile.dart';
part 'courses_screen_type_badge.dart';
part 'courses_screen_score_badge.dart';


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
    if (_classDetails.containsKey(classId) || _loadingClasses.contains(classId))
      return;
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
    if (_courseDetails.containsKey(courseId) ||
        _loadingCourses.contains(courseId)) return;
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

            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPaddingH, 32, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.mono900,
                      borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                    ),
                    child:
                        const Text('УЧИТЕЛЬ', style: AppTextStyles.badgeText),
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
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadClasses();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

    Future<void> onRefresh() async {
      setState(() {
        _isLoading = true;
        _error = null;
        _classDetails.clear();
        _courseDetails.clear();
        _expandedClasses.clear();
        _expandedCourses.clear();
      });
      await _loadClasses();
    }

    if (_classes.isEmpty) {
      return EdiumRefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 320,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school_outlined,
                        size: 48, color: AppColors.mono200),
                    const SizedBox(height: 12),
                    Text('Классов пока нет',
                        style: AppTextStyles.fieldText
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('Создайте класс на вкладке «Классы»',
                        style: AppTextStyles.screenSubtitle),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return EdiumRefreshIndicator(
      onRefresh: onRefresh,
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

