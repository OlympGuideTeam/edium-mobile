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

  // Original questions still active (not deleted)
  late List<Question> _existingQuestions;
  // IDs of original questions the user has removed
  final Set<String> _removedIds = {};
  // New questions added in this session
  final List<Map<String, dynamic>> _newQuestions = [];
  // Existing questions edited in this session: id → new map data
  final Map<String, Map<String, dynamic>> _modifiedQuestions = {};

  // Settings state
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
    try {
      final repo = getIt<IQuizRepository>();
      final title = _titleCtrl.text.trim();
      final desc = _descCtrl.text.trim();

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
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Опубликовать для всех?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.mono900,
          ),
        ),
        content: const Text(
          'Это действие безвозвратно — редактирование шаблона будет недоступно. '
          'Квиз станет доступен другим учителям.',
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
              'Опубликовать',
              style: TextStyle(
                color: AppColors.mono900,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
            _BottomBar(canSave: _canSave, submitting: _submitting, onSave: _save),
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
          // Existing questions (editable, can delete)
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

          // New questions (editable)
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

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.sectionTag);
}

// ─── Title field ──────────────────────────────────────────────────────────────

class _TitleField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  const _TitleField({required this.controller, required this.onChanged});

  static const _maxLength = 100;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Название', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          style: AppTextStyles.subtitle.copyWith(color: AppColors.mono900),
          decoration: InputDecoration(
            hintText: 'Например: Алгебра — контрольная',
            hintStyle: AppTextStyles.subtitle.copyWith(
              color: AppColors.mono300,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            counterText: '',
          ),
          cursorColor: AppColors.mono900,
          minLines: 1,
          maxLines: null,
          maxLength: _maxLength,
          textInputAction: TextInputAction.next,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.mono100)),
            const SizedBox(width: 8),
            ListenableBuilder(
              listenable: controller,
              builder: (_, __) => Text(
                '${controller.text.length}/$_maxLength',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.mono300, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Description field ────────────────────────────────────────────────────────

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const _DescriptionField({required this.controller});

  static const _maxLength = 200;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Описание', style: AppTextStyles.fieldLabel),
            const SizedBox(width: 6),
            Text(
              '— необязательно',
              style: AppTextStyles.helperText.copyWith(fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          style: AppTextStyles.fieldText.copyWith(color: AppColors.mono700),
          decoration: InputDecoration(
            hintText: 'Краткое описание шаблона...',
            hintStyle: AppTextStyles.fieldHint,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            counterText: '',
          ),
          cursorColor: AppColors.mono900,
          minLines: 1,
          maxLines: null,
          maxLength: _maxLength,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.mono100)),
            const SizedBox(width: 8),
            ListenableBuilder(
              listenable: controller,
              builder: (_, __) => Text(
                '${controller.text.length}/$_maxLength',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.mono300, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Swipe-to-delete wrapper ──────────────────────────────────────────────────

class _SwipeToDeleteTile extends StatelessWidget {
  final Widget child;
  final VoidCallback onDelete;

  const _SwipeToDeleteTile({
    super.key,
    required this.child,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: AppColors.error,
        child: Dismissible(
          key: key!,
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(),
          background: Container(
            color: AppColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Existing question tile (editable) ───────────────────────────────────────

class _ExistingQuestionTile extends StatelessWidget {
  final int index;
  final Question question;
  final String? overrideText;
  final String? overrideType;
  final bool isModified;
  final VoidCallback onTap;

  const _ExistingQuestionTile({
    required this.index,
    required this.question,
    required this.onTap,
    this.overrideText,
    this.overrideType,
    this.isModified = false,
  });

  static const _typeLabel = {
    QuestionType.singleChoice: 'Один ответ',
    QuestionType.multiChoice: 'Несколько ответов',
    QuestionType.withFreeAnswer: 'Свободный ответ',
    QuestionType.withGivenAnswer: 'Данный ответ',
    QuestionType.drag: 'Порядок',
    QuestionType.connection: 'Соответствие',
  };

  static const _typeLabelStr = {
    'single_choice': 'Один ответ',
    'multiple_choice': 'Несколько ответов',
    'with_free_answer': 'Свободный ответ',
    'with_given_answer': 'Данный ответ',
    'drag': 'Порядок',
    'connection': 'Соответствие',
  };

  static const _typeIcon = {
    QuestionType.singleChoice: Icons.radio_button_checked_outlined,
    QuestionType.multiChoice: Icons.check_box_outlined,
    QuestionType.withFreeAnswer: Icons.edit_outlined,
    QuestionType.withGivenAnswer: Icons.text_fields_outlined,
    QuestionType.drag: Icons.swap_vert_outlined,
    QuestionType.connection: Icons.device_hub_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final displayText = overrideText ?? question.text;
    final displayTypeLabel = overrideType != null
        ? (_typeLabelStr[overrideType] ?? 'Вопрос')
        : (_typeLabel[question.type] ?? 'Вопрос');
    final displayTypeIcon = overrideType == null
        ? (_typeIcon[question.type] ?? Icons.help_outline)
        : Icons.help_outline;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isModified ? AppColors.mono300 : AppColors.mono100,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.mono900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
                    displayText.isEmpty ? 'Без текста' : displayText,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(displayTypeIcon, size: 12, color: AppColors.mono400),
                      const SizedBox(width: 4),
                      Text(displayTypeLabel, style: AppTextStyles.caption),
                      if (isModified) ...[
                        const SizedBox(width: 6),
                        Text(
                          '• изменён',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mono400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.mono300),
          ],
        ),
      ),
    );
  }
}

// ─── New question tile (editable) ─────────────────────────────────────────────

class _NewQuestionTile extends StatelessWidget {
  final int index;
  final String text;
  final String type;
  final VoidCallback onTap;

  const _NewQuestionTile({
    required this.index,
    required this.text,
    required this.type,
    required this.onTap,
  });

  static const _typeLabel = {
    'single_choice': 'Один ответ',
    'multiple_choice': 'Несколько ответов',
    'with_given_answer': 'Данный ответ',
    'with_free_answer': 'Свободный ответ',
    'drag': 'Порядок',
    'connection': 'Соответствие',
  };

  static const _typeIcon = {
    'single_choice': Icons.radio_button_checked_outlined,
    'multiple_choice': Icons.check_box_outlined,
    'with_given_answer': Icons.text_fields_outlined,
    'with_free_answer': Icons.edit_outlined,
    'drag': Icons.swap_vert_outlined,
    'connection': Icons.device_hub_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mono100),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.mono900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
                    text.isEmpty ? 'Без текста' : text,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        _typeIcon[type] ?? Icons.help_outline,
                        size: 12,
                        color: AppColors.mono400,
                      ),
                      const SizedBox(width: 4),
                      Text(_typeLabel[type] ?? type, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.mono300),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mono100),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.quiz_outlined, size: 24, color: AppColors.mono400),
          ),
          const SizedBox(height: 12),
          Text(
            'Вопросов нет',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mono700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Добавьте хотя бы один вопрос',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

// ─── Add question button ──────────────────────────────────────────────────────

class _AddQuestionButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddQuestionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mono200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 18, color: AppColors.mono700),
            const SizedBox(width: 6),
            Text(
              'Добавить вопрос',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mono700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool canSave;
  final bool submitting;
  final VoidCallback onSave;

  const _BottomBar({
    required this.canSave,
    required this.submitting,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.mono100)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppDimens.buttonH,
        child: ElevatedButton(
          onPressed: canSave ? onSave : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mono900,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.mono200,
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            textStyle: AppTextStyles.primaryButton,
          ),
          child: submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Сохранить'),
        ),
      ),
    );
  }
}

// ─── Settings card ────────────────────────────────────────────────────────────

class _EditSettingsCard extends StatelessWidget {
  final int? totalTimeLimitSec;
  final int? questionTimeLimitSec;
  final ValueChanged<bool> onTotalTimeToggle;
  final ValueChanged<int> onTotalTimeChanged;
  final ValueChanged<bool> onQuestionTimeToggle;
  final ValueChanged<int> onQuestionTimeChanged;

  const _EditSettingsCard({
    required this.totalTimeLimitSec,
    required this.questionTimeLimitSec,
    required this.onTotalTimeToggle,
    required this.onTotalTimeChanged,
    required this.onQuestionTimeToggle,
    required this.onQuestionTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mono100),
      ),
      child: Column(
        children: [
          _EditTimeRow(
            label: 'Время на весь квиз',
            subtitle: 'Используется в режиме «Тест»',
            valueSec: totalTimeLimitSec,
            unit: 'мин',
            unitDivisor: 60,
            minUnits: 5,
            maxUnits: 90,
            sliderStep: 5,
            onToggle: onTotalTimeToggle,
            onChanged: onTotalTimeChanged,
          ),
          Container(height: 1, color: AppColors.mono100),
          _EditTimeRow(
            label: 'Время на вопрос',
            subtitle: 'Используется в режиме «Лайв»',
            valueSec: questionTimeLimitSec,
            unit: 'сек',
            unitDivisor: 1,
            minUnits: 5,
            maxUnits: 90,
            sliderStep: 5,
            onToggle: onQuestionTimeToggle,
            onChanged: onQuestionTimeChanged,
          ),
        ],
      ),
    );
  }
}

class _EditTimeRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final int? valueSec;
  final String unit;
  final int unitDivisor;
  final int minUnits;
  final int maxUnits;
  final int sliderStep;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onChanged;

  const _EditTimeRow({
    required this.label,
    required this.subtitle,
    required this.valueSec,
    required this.unit,
    required this.unitDivisor,
    required this.minUnits,
    required this.maxUnits,
    required this.sliderStep,
    required this.onToggle,
    required this.onChanged,
  });

  int get _currentUnits =>
      valueSec != null ? (valueSec! / unitDivisor).round() : minUnits;

  int get _divisions => (maxUnits - minUnits) ~/ sliderStep;

  String get _displayText => '$_currentUnits $unit';

  Future<void> _showInput(BuildContext context) async {
    final ctrl = TextEditingController(text: '$_currentUnits');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => _EditTimeInputDialog(
        controller: ctrl,
        unit: unit,
        minValue: minUnits,
        maxValue: maxUnits,
      ),
    );
    if (result != null) {
      onChanged(result.clamp(minUnits, maxUnits) * unitDivisor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.mono700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.mono400, fontSize: 11)),
                  ],
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: valueSec != null ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: valueSec == null,
                  child: GestureDetector(
                    onTap: () => _showInput(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mono100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _displayText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mono900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _EditMonoSwitch(value: valueSec != null, onChanged: onToggle),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: valueSec != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.mono900,
                      inactiveTrackColor: AppColors.mono150,
                      thumbColor: AppColors.mono900,
                      overlayColor: AppColors.mono900.withValues(alpha: 0.08),
                      trackHeight: 2,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: _currentUnits.toDouble().clamp(
                            minUnits.toDouble(), maxUnits.toDouble()),
                      min: minUnits.toDouble(),
                      max: maxUnits.toDouble(),
                      divisions: _divisions,
                      onChanged: (v) => onChanged(v.round() * unitDivisor),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _EditTimeInputDialog extends StatefulWidget {
  final TextEditingController controller;
  final String unit;
  final int minValue;
  final int maxValue;

  const _EditTimeInputDialog({
    required this.controller,
    required this.unit,
    required this.minValue,
    required this.maxValue,
  });

  @override
  State<_EditTimeInputDialog> createState() => _EditTimeInputDialogState();
}

class _EditTimeInputDialogState extends State<_EditTimeInputDialog> {
  String? _error;

  void _confirm() {
    final v = int.tryParse(widget.controller.text.trim());
    if (v == null) {
      setState(() => _error = 'Введите число');
      return;
    }
    if (v < widget.minValue || v > widget.maxValue) {
      setState(() =>
          _error = 'От ${widget.minValue} до ${widget.maxValue} ${widget.unit}');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Введите значение',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.mono900)),
            const SizedBox(height: 4),
            Text('${widget.minValue}–${widget.maxValue} ${widget.unit}',
                style: AppTextStyles.helperText),
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.fieldText.copyWith(color: AppColors.mono900),
              cursorColor: AppColors.mono900,
              decoration: InputDecoration(
                suffixText: widget.unit,
                suffixStyle: AppTextStyles.fieldText.copyWith(color: AppColors.mono400),
                filled: true,
                fillColor: AppColors.mono25,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.mono150),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.mono150),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.mono700, width: 1.5),
                ),
                errorText: _error,
                errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
              onSubmitted: (_) => _confirm(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.mono150),
                      ),
                      child: Center(
                        child: Text('Отмена',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mono600,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _confirm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.mono900,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text('Готово',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── AI Generate button (rainbow animated border) ────────────────────────────

class _AIGenerateButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AIGenerateButton({required this.onTap});

  @override
  State<_AIGenerateButton> createState() => _AIGenerateButtonState();
}

class _AIGenerateButtonState extends State<_AIGenerateButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return CustomPaint(
            painter: _RainbowBorderPainter(
              progress: _ctrl.value,
              borderRadius: 11,
              borderWidth: 1.5,
            ),
            child: Container(
              margin: const EdgeInsets.all(1.5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return SweepGradient(
                        colors: const [
                          Color(0xFF8B5CF6),
                          Color(0xFFEC4899),
                          Color(0xFFF59E0B),
                          Color(0xFF10B981),
                          Color(0xFF3B82F6),
                          Color(0xFF8B5CF6),
                        ],
                        transform:
                            GradientRotation(_ctrl.value * math.pi * 2),
                      ).createShader(bounds);
                    },
                    child: const Icon(Icons.auto_awesome,
                        size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AI',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mono900,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── AI Generate sheet ────────────────────────────────────────────────────────

class _AIGenerateSheet extends StatefulWidget {
  final Future<void> Function(String text) onGenerate;
  const _AIGenerateSheet({required this.onGenerate});

  @override
  State<_AIGenerateSheet> createState() => _AIGenerateSheetState();
}

class _AIGenerateSheetState extends State<_AIGenerateSheet> {
  final _textCtrl = TextEditingController();
  final _fieldFocus = FocusNode();
  bool _isGenerating = false;
  static const _maxLength = 4000;
  static const _minGenerateLength = 500;

  @override
  void initState() {
    super.initState();
    _fieldFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fieldFocus.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8B5CF6),
                          Color(0xFFEC4899),
                          Color(0xFFF59E0B),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Сгенерировать вопросы',
                          style: AppTextStyles.subtitle
                              .copyWith(color: AppColors.mono900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Вставьте текст – Edium AI создаст вопросы',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.mono400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: AppColors.mono25,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _fieldFocus.hasFocus
                        ? AppColors.mono900
                        : AppColors.mono150,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Column(
                    children: [
                      TextField(
                        controller: _textCtrl,
                        focusNode: _fieldFocus,
                        maxLength: _maxLength,
                        maxLines: 8,
                        minLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        style: AppTextStyles.fieldText
                            .copyWith(color: AppColors.mono700),
                        decoration: InputDecoration(
                          hintText:
                              'Вставьте текст лекции, главы учебника или любой материал...',
                          hintStyle: AppTextStyles.fieldHint,
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                          counterText: '',
                        ),
                        cursorColor: AppColors.mono900,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 14, right: 14, bottom: 10),
                        child: Row(
                          children: [
                            ListenableBuilder(
                              listenable: _textCtrl,
                              builder: (_, __) {
                                final len = _textCtrl.text.length;
                                if (len > 0 && len < _minGenerateLength) {
                                  return Text(
                                    'Минимум $_minGenerateLength символов',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.mono400,
                                      fontSize: 11,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const Spacer(),
                            ListenableBuilder(
                              listenable: _textCtrl,
                              builder: (_, __) => Text(
                                '${_textCtrl.text.length}/$_maxLength',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.mono300, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: _textCtrl,
                builder: (_, __) {
                  final hasEnoughText =
                      _textCtrl.text.trim().length >= _minGenerateLength;
                  final canTap = hasEnoughText && !_isGenerating;
                  return SizedBox(
                    width: double.infinity,
                    height: AppDimens.buttonH,
                    child: _RainbowBorderButton(
                      enabled: canTap,
                      isBusy: _isGenerating,
                      onTap: canTap
                          ? () async {
                              _fieldFocus.unfocus();
                              setState(() => _isGenerating = true);
                              try {
                                await widget.onGenerate(_textCtrl.text.trim());
                              } catch (_) {
                                if (mounted) {
                                  setState(() => _isGenerating = false);
                                }
                              }
                            }
                          : null,
                      child: _isGenerating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Сгенерировать',
                                  style: AppTextStyles.primaryButton.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Rainbow border button ────────────────────────────────────────────────────

class _RainbowBorderButton extends StatefulWidget {
  final bool enabled;
  final bool isBusy;
  final VoidCallback? onTap;
  final Widget child;

  const _RainbowBorderButton({
    required this.enabled,
    this.isBusy = false,
    required this.onTap,
    required this.child,
  });

  @override
  State<_RainbowBorderButton> createState() => _RainbowBorderButtonState();
}

class _RainbowBorderButtonState extends State<_RainbowBorderButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: (!widget.enabled && !widget.isBusy) ? 0.5 : 1.0,
            child: CustomPaint(
              painter: _RainbowBorderPainter(
                progress: _ctrl.value,
                borderRadius: 14,
                borderWidth: 2.5,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.mono900,
                  borderRadius: BorderRadius.circular(11.5),
                ),
                margin: const EdgeInsets.all(2.5),
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _RainbowBorderPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final double borderWidth;

  _RainbowBorderPainter({
    required this.progress,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final inset = borderWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - borderWidth,
      size.height - borderWidth,
    );
    final r = borderRadius <= inset ? 0.0 : borderRadius - inset;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));

    final colors = [
      const Color(0xFFFF0000),
      const Color(0xFFFF8000),
      const Color(0xFFFFFF00),
      const Color(0xFF00FF00),
      const Color(0xFF00FFFF),
      const Color(0xFF0080FF),
      const Color(0xFF8000FF),
      const Color(0xFFFF00FF),
      const Color(0xFFFF0000),
    ];

    final sweepGradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: colors,
      transform: GradientRotation(progress * math.pi * 2),
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_RainbowBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────

class _EditMonoSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _EditMonoSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: value ? AppColors.mono900 : AppColors.mono200,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
