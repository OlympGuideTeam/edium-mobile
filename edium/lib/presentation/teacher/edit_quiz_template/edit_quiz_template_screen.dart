import 'dart:math' as math;

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/teacher/create_quiz/add_question_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'edit_quiz_template_screen_section_label.dart';
part 'edit_quiz_template_screen_title_field.dart';
part 'edit_quiz_template_screen_description_field.dart';
part 'edit_quiz_template_screen_swipe_to_delete_tile.dart';
part 'edit_quiz_template_screen_existing_question_tile.dart';
part 'edit_quiz_template_screen_new_question_tile.dart';
part 'edit_quiz_template_screen_empty_state.dart';
part 'edit_quiz_template_screen_add_question_button.dart';
part 'edit_quiz_template_screen_bottom_bar.dart';
part 'edit_quiz_template_screen_edit_settings_card.dart';
part 'edit_quiz_template_screen_edit_time_row.dart';
part 'edit_quiz_template_screen_edit_time_input_dialog.dart';
part 'edit_quiz_template_screen_ai_generate_button.dart';
part 'edit_quiz_template_screen_ai_generate_sheet.dart';
part 'edit_quiz_template_screen_rainbow_border_button.dart';
part 'edit_quiz_template_screen_rainbow_border_painter.dart';
part 'edit_quiz_template_screen_edit_mono_switch.dart';


class EditQuizTemplateScreen extends StatefulWidget {
  final String quizId;

  const EditQuizTemplateScreen({super.key, required this.quizId});

  @override
  State<EditQuizTemplateScreen> createState() => _EditQuizTemplateScreenState();
}

class _EditQuizTemplateScreenState extends State<EditQuizTemplateScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  Quiz? _quiz;
  bool _loading = true;
  bool _submitting = false;


  late List<Question> _existingQuestions;

  final Set<String> _removedIds = {};

  final List<Map<String, dynamic>> _newQuestions = [];

  final Map<String, Map<String, dynamic>> _modifiedQuestions = {};


  int? _totalTimeLimitSec;
  int? _questionTimeLimitSec;

  bool get _canSave {
    final totalCount = _existingQuestions.length + _newQuestions.length;
    return _titleCtrl.text.trim().isNotEmpty && totalCount > 0 && !_submitting;
  }

  @override
  void initState() {
    super.initState();
    _existingQuestions = [];
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final quiz = await getIt<IQuizRepository>().getQuizById(widget.quizId);
      if (mounted) {
        setState(() {
          _quiz = quiz;
          _existingQuestions = List.from(quiz.questions);
          _titleCtrl.text = quiz.title;
          _descCtrl.text = quiz.description ?? '';
          _totalTimeLimitSec = quiz.settings.timeLimitMinutes != null
              ? quiz.settings.timeLimitMinutes! * 60
              : null;
          _questionTimeLimitSec = quiz.settings.questionTimeLimitSec;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _submitting = true);
    final repo = getIt<IQuizRepository>();
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    try {
      await repo.updateQuiz(
        widget.quizId,
        title: title,
        description: desc.isEmpty ? null : desc,
        defaultSettings: {
          if (_totalTimeLimitSec != null)
            'total_time_limit_sec': _totalTimeLimitSec,
          if (_questionTimeLimitSec != null)
            'question_time_limit_sec': _questionTimeLimitSec,
        },
      );
      for (final id in _removedIds) {
        await repo.removeQuestion(widget.quizId, id);
      }
      for (final entry in _modifiedQuestions.entries) {
        if (!_removedIds.contains(entry.key)) {
          await repo.removeQuestion(widget.quizId, entry.key);
          await repo.addQuestion(widget.quizId, entry.value);
        }
      }
      for (final q in _newQuestions) {
        await repo.addQuestion(widget.quizId, q);
      }
      if (mounted) {
        EdiumNotification.show(context, 'Шаблон обновлён');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        EdiumNotification.show(
          context,
          'Ошибка сохранения',
          type: EdiumNotificationType.error,
        );
      }
    }
  }

  Future<void> _addQuestion() async {
    final q = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddQuestionScreen()),
    );
    if (q != null && mounted) {
      setState(() => _newQuestions.add(q));
    }
  }

  static const Map<QuestionType, String> _questionTypeStr = {
    QuestionType.singleChoice: 'single_choice',
    QuestionType.multiChoice: 'multiple_choice',
    QuestionType.withFreeAnswer: 'with_free_answer',
    QuestionType.withGivenAnswer: 'with_given_answer',
    QuestionType.drag: 'drag',
    QuestionType.connection: 'connection',
  };

  Map<String, dynamic> _questionToMap(Question q) {
    return {
      'type': _questionTypeStr[q.type] ?? 'single_choice',
      'text': q.text,
      'max_score': q.maxScore ?? 10,
      if (q.imageId != null) 'image_id': q.imageId,
      'answer_options': q.options
          .map((o) => {'text': o.text, 'is_correct': o.isCorrect})
          .toList(),
      if (q.explanation != null && q.explanation!.isNotEmpty)
        'explanation': q.explanation,
      if (q.metadata != null) 'metadata': q.metadata,
    };
  }

  Future<void> _editExistingQuestion(int index) async {
    final q = _existingQuestions[index];
    final initial = _modifiedQuestions.containsKey(q.id)
        ? _modifiedQuestions[q.id]!
        : _questionToMap(q);
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddQuestionScreen(initialQuestion: initial),
      ),
    );
    if (result != null && mounted) {
      setState(() => _modifiedQuestions[q.id] = result);
    }
  }

  Future<void> _openAIGenerateSheet() async {
    FocusScope.of(context).unfocus();
    final hostContext = context;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return _AIGenerateSheet(
          onGenerate: (text) async {
            await getIt<IQuizRepository>()
                .generateQuizQuestions(widget.quizId, text);
            if (sheetCtx.mounted) Navigator.pop(sheetCtx);
            if (hostContext.mounted) {
              EdiumNotification.show(
                hostContext,
                'Мы пришлём вам уведомление, когда вопросы будут готовы.',
              );
            }
          },
        );
      },
    );
  }

  Future<void> _editNewQuestion(int index) async {
    final q = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddQuestionScreen(initialQuestion: _newQuestions[index]),
      ),
    );
    if (q != null && mounted) {
      setState(() => _newQuestions[index] = q);
    }
  }

  void _removeExisting(Question q) {
    setState(() {
      _removedIds.add(q.id);
      _existingQuestions.remove(q);
    });
  }

  void _removeNew(int index) {
    setState(() => _newQuestions.removeAt(index));
  }

  Future<void> _copyQuiz() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await getIt<IQuizRepository>().copyQuiz(widget.quizId);
      if (mounted) {
        EdiumNotification.show(context, 'Копия добавлена в ваши квизы');
      }
    } catch (_) {
      if (mounted) {
        EdiumNotification.show(
          context,
          'Ошибка копирования',
          type: EdiumNotificationType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _publishQuiz() async {
    if (_submitting) return;
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
                'Опубликовать для всех?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Это действие безвозвратно — редактирование шаблона будет недоступно. '
                'Квиз станет доступен другим учителям.',
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
                    'Опубликовать',
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
    setState(() => _submitting = true);
    try {
      final repo = getIt<IQuizRepository>();
      final title = _titleCtrl.text.trim();
      final desc = _descCtrl.text.trim();
      if (title.isNotEmpty) {
        await repo.updateQuiz(
          widget.quizId,
          title: title,
          description: desc.isEmpty ? null : desc,
        );
      }
      for (final id in _removedIds) {
        await repo.removeQuestion(widget.quizId, id);
      }
      for (final q in _newQuestions) {
        await repo.addQuestion(widget.quizId, q);
      }
      await repo.publishQuiz(widget.quizId, isPublic: true);
      if (mounted) {
        EdiumNotification.show(context, 'Опубликовано для всех');
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        EdiumNotification.show(
          context,
          'Ошибка публикации',
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
          child: CircularProgressIndicator(color: AppColors.mono700, strokeWidth: 2),
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
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Text('Шаблон не найден', style: AppTextStyles.screenSubtitle),
        ),
      );
    }

    final totalCount = _existingQuestions.length + _newQuestions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.mono700, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Редактировать', style: AppTextStyles.screenTitle),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            tooltip: 'Копировать',
            icon: const Icon(Icons.copy_outlined,
                color: AppColors.mono700, size: 20),
            onPressed: _submitting ? null : _copyQuiz,
          ),
          IconButton(
            tooltip: 'Опубликовать для всех',
            icon: const Icon(Icons.public,
                color: AppColors.mono700, size: 22),
            onPressed: _submitting ? null : _publishQuiz,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _TitleField(controller: _titleCtrl, onChanged: () => setState(() {})),
                    const SizedBox(height: 16),
                    _DescriptionField(controller: _descCtrl),
                    const SizedBox(height: 28),
                    _SectionLabel('НАСТРОЙКИ'),
                    const SizedBox(height: 12),
                    _EditSettingsCard(
                      totalTimeLimitSec: _totalTimeLimitSec,
                      questionTimeLimitSec: _questionTimeLimitSec,
                      onTotalTimeToggle: (on) => setState(() =>
                          _totalTimeLimitSec = on ? 1200 : null),
                      onTotalTimeChanged: (v) =>
                          setState(() => _totalTimeLimitSec = v),
                      onQuestionTimeToggle: (on) => setState(() =>
                          _questionTimeLimitSec = on ? 30 : null),
                      onQuestionTimeChanged: (v) =>
                          setState(() => _questionTimeLimitSec = v),
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel('ВОПРОСЫ ($totalCount)'),
                    const SizedBox(height: 12),
                    _buildQuestionsList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _BottomBar(
              canSave: _canSave,
              submitting: _submitting,
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsList() {
    final hasAny = _existingQuestions.isNotEmpty || _newQuestions.isNotEmpty;

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _AddQuestionButton(onTap: _addQuestion)),
              const SizedBox(width: 10),
              SizedBox(
                width: 76,
                child: _AIGenerateButton(onTap: _openAIGenerateSheet),
              ),
            ],
          ),
        ),
        if (!hasAny) ...[
          const SizedBox(height: 12),
          const _EmptyState(),
        ],
        if (hasAny) ...[
          const SizedBox(height: 12),

          ...List.generate(_existingQuestions.length, (i) {
            final q = _existingQuestions[i];
            final isModified = _modifiedQuestions.containsKey(q.id);
            final displayMap =
                isModified ? _modifiedQuestions[q.id]! : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SwipeToDeleteTile(
                key: ValueKey('existing-${q.id}-$isModified'),
                onDelete: () => _removeExisting(q),
                child: _ExistingQuestionTile(
                  index: i + 1,
                  question: q,
                  overrideText: displayMap?['text'] as String?,
                  overrideType: displayMap?['type'] as String?,
                  isModified: isModified,
                  onTap: () => _editExistingQuestion(i),
                ),
              ),
            );
          }),


          ...List.generate(_newQuestions.length, (i) {
            final q = _newQuestions[i];
            final type = q['type'] as String? ?? 'single_choice';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SwipeToDeleteTile(
                key: ValueKey('new-$i-${q['text']}'),
                onDelete: () => _removeNew(i),
                child: _NewQuestionTile(
                  index: _existingQuestions.length + i + 1,
                  text: q['text'] as String? ?? '',
                  type: type,
                  onTap: () => _editNewQuestion(i),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

