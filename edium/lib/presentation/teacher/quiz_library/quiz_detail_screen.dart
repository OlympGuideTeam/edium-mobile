import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/class/get_class_detail_usecase.dart';
import 'package:edium/domain/usecases/class/get_my_classes_usecase.dart';
import 'package:edium/domain/usecases/course/get_course_detail_usecase.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/teacher/create_quiz/quiz_results_screen.dart';
import 'package:edium/presentation/teacher/create_quiz/view_question_screen.dart';
import 'package:edium/presentation/teacher/edit_quiz_template/edit_quiz_template_screen.dart';
import 'package:flutter/material.dart';

class QuizDetailScreen extends StatefulWidget {
  final String quizId;

  /// Передаётся из списка библиотеки: true, если квиз открыт из вкладки «Мои квизы».
  final bool isOwnerHint;

  const QuizDetailScreen({
    super.key,
    required this.quizId,
    this.isOwnerHint = false,
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  Quiz? _quiz;
  bool _loading = true;
  bool _actionLoading = false;

  bool get _isOwner => widget.isOwnerHint;
  bool get _canEdit => _isOwner && _quiz?.isPublic == false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final quiz = await getIt<IQuizRepository>().getQuizById(widget.quizId);
      if (mounted) setState(() { _quiz = quiz; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copyQuiz() async {
    setState(() => _actionLoading = true);
    try {
      await getIt<IQuizRepository>().copyQuiz(widget.quizId);
      if (mounted) {
        EdiumNotification.show(context, 'Копия добавлена в ваши квизы');
      }
    } catch (e) {
      if (mounted) {
        EdiumNotification.show(
          context,
          'Ошибка копирования',
          type: EdiumNotificationType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _editQuiz() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditQuizTemplateScreen(quizId: widget.quizId),
      ),
    );
    if (updated == true && mounted) _load();
  }

  Future<void> _deleteQuiz() async {
    if (_quiz?.isPublic == true) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Нельзя удалить',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.mono900,
            ),
          ),
          content: const Text(
            'Публичный шаблон нельзя удалить — он доступен другим учителям.',
            style: TextStyle(fontSize: 14, color: AppColors.mono600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Понятно',
                style: TextStyle(color: AppColors.mono900, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Удалить шаблон?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.mono900,
          ),
        ),
        content: const Text(
          'Это действие нельзя отменить. Шаблон будет удалён из библиотеки.',
          style: TextStyle(fontSize: 14, color: AppColors.mono600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppColors.mono600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Удалить',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _actionLoading = true);
    try {
      await getIt<IQuizRepository>().deleteQuiz(widget.quizId);
      if (mounted) {
        EdiumNotification.show(context, 'Шаблон удалён');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _actionLoading = false);
        EdiumNotification.show(
          context,
          'Ошибка удаления',
          type: EdiumNotificationType.error,
        );
      }
    }
  }

  void _addToCourse() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddToCourseSheet(quizId: widget.quizId),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.mono700,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_quiz == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: AppColors.mono900,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.quiz_outlined,
                  size: 48, color: AppColors.mono200),
              const SizedBox(height: 12),
              Text('Квиз не найден', style: AppTextStyles.screenSubtitle),
            ],
          ),
        ),
      );
    }

    final quiz = _quiz!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(quiz),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.mono900,
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.screenPaddingH,
                    0,
                    AppDimens.screenPaddingH,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildHeader(quiz),
                      const SizedBox(height: 20),
                      _buildSettingsRow(quiz),
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: AppColors.mono100),
                      const SizedBox(height: 24),
                      _buildQuestionsSection(quiz),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom bar with "Add to course" action
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Quiz quiz) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.mono900),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          if (quiz.status == QuizStatus.active ||
              quiz.status == QuizStatus.completed)
            _TopBarButton(
              icon: Icons.bar_chart_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizResultsScreen(quizId: widget.quizId),
                ),
              ),
            ),
          if (_isOwner) ...[
            if (_canEdit)
              _TopBarButton(
                icon: Icons.edit_outlined,
                onTap: _actionLoading ? null : _editQuiz,
              ),
            _TopBarButton(
              icon: Icons.copy_outlined,
              onTap: _actionLoading ? null : _copyQuiz,
            ),
            _TopBarButton(
              icon: Icons.delete_outline,
              onTap: _actionLoading ? null : _deleteQuiz,
            ),
          ] else
            _TopBarButton(
              icon: Icons.copy_outlined,
              onTap: _actionLoading ? null : _copyQuiz,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(Quiz quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (quiz.isPublic) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mono900,
                  borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                ),
                child: const Text(
                  'ПУБЛИЧНЫЙ',
                  style: AppTextStyles.badgeText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Text(
          quiz.title,
          style: AppTextStyles.screenTitle.copyWith(fontSize: 24, height: 1.25),
        ),
        if (quiz.subject.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(quiz.subject, style: AppTextStyles.screenSubtitle),
        ],
        if (quiz.description != null && quiz.description!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            quiz.description!,
            style: AppTextStyles.screenSubtitle.copyWith(fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsRow(Quiz quiz) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (quiz.settings.totalTimeLimitSec != null &&
            quiz.settings.totalTimeLimitSec! > 0)
          _SettingChip(
            icon: Icons.timer_outlined,
            label: _quizTimeLimitTotalLabel(quiz.settings.totalTimeLimitSec!),
          )
        else if (quiz.settings.timeLimitMinutes != null)
          _SettingChip(
            icon: Icons.timer_outlined,
            label: '${quiz.settings.timeLimitMinutes} мин',
          ),
        if (quiz.settings.questionTimeLimitSec != null &&
            quiz.settings.questionTimeLimitSec! > 0)
          _SettingChip(
            icon: Icons.timer_outlined,
            label: _quizTimeLimitPerQuestionLabel(
              quiz.settings.questionTimeLimitSec!,
            ),
          ),
        if (quiz.settings.deadline != null)
          _SettingChip(
            icon: Icons.event_outlined,
            label: _fmtDeadline(quiz.settings.deadline!),
            highlight: _isExpired(quiz.settings.deadline!),
          ),
      ],
    );
  }

  Widget _buildQuestionsSection(Quiz quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Вопросы',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.mono900,
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.mono50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.mono100),
              ),
              child: Text(
                '${quiz.questionsCount}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (quiz.questions.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.mono25,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: AppColors.mono100),
            ),
            child: Center(
              child: Text(
                'Вопросы не добавлены',
                style: AppTextStyles.screenSubtitle,
              ),
            ),
          )
        else
          ...quiz.questions.asMap().entries.map(
                (entry) => _QuestionTile(
                  index: entry.key + 1,
                  question: entry.value,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewQuestionScreen(
                        index: entry.key + 1,
                        question: entry.value,
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimens.screenPaddingH,
        right: AppDimens.screenPaddingH,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.mono100)),
      ),
      child: EdiumButton(
        label: 'Добавить в курс',
        icon: Icons.add_circle_outline,
        onPressed: _addToCourse,
      ),
    );
  }

  /// Human-readable duration for quiz time limits (from seconds).
  String _formatDurationSec(int sec) {
    if (sec <= 0) return '0 с';
    if (sec >= 3600) {
      final h = sec ~/ 3600;
      final rem = sec % 3600;
      final m = rem ~/ 60;
      if (m == 0) return '$h ч';
      return '$h ч $m мин';
    }
    if (sec >= 60) {
      final m = sec ~/ 60;
      final s = sec % 60;
      if (s == 0) return '$m мин';
      return '$m мин $s с';
    }
    return '$sec с';
  }

  String _quizTimeLimitTotalLabel(int sec) => _formatDurationSec(sec);

  String _quizTimeLimitPerQuestionLabel(int sec) =>
      '${_formatDurationSec(sec)}/впр';

  String _fmtDeadline(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  bool _isExpired(DateTime dt) => dt.isBefore(DateTime.now());
}

// ── Add to Course bottom sheet ────────────────────────────────────────────────

class _AddToCourseSheet extends StatefulWidget {
  final String quizId;

  const _AddToCourseSheet({required this.quizId});

  @override
  State<_AddToCourseSheet> createState() => _AddToCourseSheetState();
}

class _AddToCourseSheetState extends State<_AddToCourseSheet> {
  final _searchCtrl = TextEditingController();

  // Step 0 = pick course, Step 1 = pick module + session type
  int _step = 0;
  CourseSummary? _selectedCourse;
  ModuleDetail? _selectedModule;
  SessionType _sessionType = SessionType.test;

  // Loaded data
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
            // Handle
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
            // Header
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
              // Search bar
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
              // Step 1: session type + module picker
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

class _CourseEntry {
  final String className;
  final CourseSummary course;
  const _CourseEntry({required this.className, required this.course});
}

class _CoursePickerTile extends StatelessWidget {
  final _CourseEntry entry;
  final VoidCallback onTap;

  const _CoursePickerTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.mono25,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.mono100),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.course.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mono900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.className,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.mono400),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.mono300),
          ],
        ),
      ),
    );
  }
}

class _SessionTypePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SessionTypePill({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.mono900 : AppColors.mono25,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color:
                  isActive ? AppColors.mono900 : AppColors.mono100,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : AppColors.mono400,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.mono700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _TopBarButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: AppColors.mono50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.mono100),
        ),
        child: Icon(icon, size: 18, color: AppColors.mono700),
      ),
    );
  }
}

class _SettingChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _SettingChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFEE2E2) : AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color:
              highlight ? AppColors.error.withAlpha(80) : AppColors.mono100,
          width: AppDimens.borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: highlight ? AppColors.error : AppColors.mono400,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: highlight ? AppColors.error : AppColors.mono700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final int index;
  final Question question;
  final VoidCallback? onTap;

  const _QuestionTile({
    required this.index,
    required this.question,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.mono25,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
              color: AppColors.mono100, width: AppDimens.borderWidth),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.mono100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mono900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  _QuestionTypeBadge(type: question.type),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.mono300),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuestionTypeBadge extends StatelessWidget {
  final QuestionType type;
  const _QuestionTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.mono100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _label(type),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.mono400,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _label(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice:
        return 'Один ответ';
      case QuestionType.multiChoice:
        return 'Несколько ответов';
      case QuestionType.withFreeAnswer:
        return 'Свободный ответ';
      case QuestionType.withGivenAnswer:
        return 'Данный ответ';
      case QuestionType.drag:
        return 'Порядок';
      case QuestionType.connection:
        return 'Соответствие';
    }
  }
}
