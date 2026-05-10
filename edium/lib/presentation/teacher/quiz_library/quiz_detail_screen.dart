import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/class/get_class_detail_usecase.dart';
import 'package:edium/domain/usecases/class/get_my_classes_usecase.dart';
import 'package:edium/domain/usecases/course/get_course_detail_usecase.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/presentation/live/teacher/live_teacher_screen.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/teacher/create_quiz/quiz_results_screen.dart';
import 'package:edium/presentation/teacher/create_quiz/view_question_screen.dart';
import 'package:edium/presentation/teacher/edit_quiz_template/edit_quiz_template_screen.dart';
import 'package:flutter/material.dart';

part 'quiz_detail_screen_add_to_course_sheet.dart';
part 'quiz_detail_screen_course_entry.dart';
part 'quiz_detail_screen_course_picker_tile.dart';
part 'quiz_detail_screen_session_type_pill.dart';
part 'quiz_detail_screen_top_bar_button.dart';
part 'quiz_detail_screen_setting_chip.dart';
part 'quiz_detail_screen_question_tile.dart';
part 'quiz_detail_screen_question_type_badge.dart';


class QuizDetailScreen extends StatefulWidget {
  final String quizId;


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
        builder: (ctx) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Нельзя удалить',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Публичный шаблон нельзя удалить — он доступен другим учителям.',
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
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mono900,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Понятно',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Удалить шаблон?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Это действие нельзя отменить. Шаблон будет удалён из библиотеки.',
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
                  onPressed: () => Navigator.pop(ctx, true),
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHSm,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
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

  Future<void> _startLive() async {
    setState(() => _actionLoading = true);
    try {
      final sessionId = await getIt<ILiveRepository>()
          .createLiveLibrarySession(widget.quizId);
      if (!mounted) return;
      setState(() => _actionLoading = false);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LiveTeacherScreen(
            sessionId: sessionId,
            quizTitle: _quiz?.title ?? '',
            questionCount: _quiz?.questionsCount ?? 0,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _actionLoading = false);
        EdiumNotification.show(
          context,
          'Ошибка создания лайва',
          type: EdiumNotificationType.error,
        );
      }
    }
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
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
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
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
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
    final showLive = _quiz?.needEvaluation == false;
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
      child: showLive
          ? Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppDimens.buttonH,
                    child: OutlinedButton(
                      onPressed: _actionLoading ? null : _startLive,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.mono900,
                        disabledForegroundColor: AppColors.mono300,
                        side: const BorderSide(color: AppColors.mono300),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusLg),
                        ),
                        textStyle: AppTextStyles.primaryButton,
                      ),
                      child: _actionLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.mono700,
                              ),
                            )
                          : const Text('Начать лайв'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: EdiumButton(
                    label: 'Добавить в курс',
                    onPressed: _actionLoading ? null : _addToCourse,
                  ),
                ),
              ],
            )
          : EdiumButton(
              label: 'Добавить в курс',
              onPressed: _addToCourse,
            ),
    );
  }


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

