import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/teacher/create_quiz/quiz_results_screen.dart';
import 'package:flutter/material.dart';

class QuizDetailScreen extends StatefulWidget {
  final String quizId;

  const QuizDetailScreen({super.key, required this.quizId});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  Quiz? _quiz;
  bool _loading = true;
  bool _actionLoading = false;

  bool get _isOwner => _quiz?.authorId == 'mock-user-1';

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

  Future<void> _publishQuiz() async {
    bool isPublic = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _PublishDialog(
        onPublicChanged: (v) => isPublic = v,
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _actionLoading = true);
    try {
      await getIt<IQuizRepository>().publishQuiz(
        widget.quizId,
        isPublic: isPublic,
      );
      await _load();
      if (mounted) {
        EdiumNotification.show(
          context,
          isPublic ? 'Квиз опубликован в библиотеке' : 'Квиз опубликован (только для вас)',
        );
      }
    } catch (e) {
      if (mounted) {
        EdiumNotification.show(
          context,
          'Ошибка публикации',
          type: EdiumNotificationType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
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

  Future<void> _deleteQuiz() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Удалить квиз?',
        body: 'Черновик будет удалён без возможности восстановления.',
        confirmLabel: 'Удалить',
        danger: true,
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _actionLoading = true);
    try {
      await getIt<IQuizRepository>().deleteQuiz(widget.quizId);
      if (mounted) {
        EdiumNotification.show(context, 'Квиз удалён');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        EdiumNotification.show(
          context,
          'Ошибка удаления',
          type: EdiumNotificationType.error,
        );
      }
      if (mounted) setState(() => _actionLoading = false);
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
              const Icon(Icons.quiz_outlined, size: 48, color: AppColors.mono200),
              const SizedBox(height: 12),
              Text('Квиз не найден', style: AppTextStyles.screenSubtitle),
            ],
          ),
        ),
      );
    }

    final quiz = _quiz!;
    final isDraft = quiz.status == QuizStatus.draft;
    final isPublished = quiz.status == QuizStatus.active ||
        quiz.status == QuizStatus.completed ||
        quiz.status == QuizStatus.future;

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
                      _buildAuthorRow(quiz),
                      const SizedBox(height: 20),
                      _buildSettingsRow(quiz),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildQuestionsSection(quiz),
                      const SizedBox(height: 32),
                      if (_actionLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.mono700,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        _buildActions(
                          quiz: quiz,
                          isDraft: isDraft,
                          isPublished: isPublished,
                        ),
                    ],
                  ),
                ),
              ),
            ),
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
          if (quiz.status != QuizStatus.draft)
            _TopBarButton(
              icon: Icons.copy_outlined,
              onTap: _actionLoading ? null : _copyQuiz,
            ),
          if (quiz.status == QuizStatus.draft && _isOwner)
            _TopBarButton(
              icon: Icons.delete_outline,
              onTap: _actionLoading ? null : _deleteQuiz,
              color: AppColors.error,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(Quiz quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.mono900,
                borderRadius: BorderRadius.circular(AppDimens.radiusXs),
              ),
              child: const Text('УЧИТЕЛЬ', style: AppTextStyles.badgeText),
            ),
            const SizedBox(width: 8),
            _StatusChip(status: quiz.status),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          quiz.title,
          style: AppTextStyles.screenTitle.copyWith(fontSize: 24, height: 1.25),
        ),
        if (quiz.subject.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(quiz.subject, style: AppTextStyles.screenSubtitle),
        ],
      ],
    );
  }

  Widget _buildAuthorRow(Quiz quiz) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.mono100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              quiz.authorName.isNotEmpty ? quiz.authorName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.mono600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz.authorName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.mono900,
              ),
            ),
            Text(
              _isOwner ? 'Ваш квиз' : 'Автор',
              style: AppTextStyles.screenSubtitle.copyWith(fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Icon(
              quiz.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: quiz.isLiked ? AppColors.error : AppColors.mono300,
            ),
            const SizedBox(width: 4),
            Text(
              '${quiz.likesCount}',
              style: AppTextStyles.screenSubtitle.copyWith(fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsRow(Quiz quiz) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SettingChip(
          icon: Icons.quiz_outlined,
          label: '${quiz.questionsCount} вопр.',
        ),
        if (quiz.settings.timeLimitMinutes != null)
          _SettingChip(
            icon: Icons.timer_outlined,
            label: '${quiz.settings.timeLimitMinutes} мин',
          ),
        _SettingChip(
          icon: quiz.settings.shuffleQuestions
              ? Icons.shuffle
              : Icons.format_list_numbered,
          label: quiz.settings.shuffleQuestions ? 'Перемешан' : 'По порядку',
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

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppColors.mono100);
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          _buildEmptyQuestions()
        else
          ...quiz.questions.asMap().entries.map(
                (entry) => _QuestionTile(
                  index: entry.key + 1,
                  question: entry.value,
                ),
              ),
      ],
    );
  }

  Widget _buildEmptyQuestions() {
    return Container(
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
    );
  }

  Widget _buildActions({
    required Quiz quiz,
    required bool isDraft,
    required bool isPublished,
  }) {
    final actions = <Widget>[];

    if (isDraft && _isOwner) {
      actions.add(_ActionButton(
        label: 'Опубликовать',
        icon: Icons.publish_outlined,
        onTap: _publishQuiz,
        filled: true,
      ));
      actions.add(const SizedBox(height: 10));
      actions.add(_ActionButton(
        label: 'Удалить черновик',
        icon: Icons.delete_outline,
        onTap: _deleteQuiz,
        danger: true,
      ));
    }

    if (isPublished) {
      if (quiz.status == QuizStatus.active ||
          quiz.status == QuizStatus.completed) {
        actions.add(_ActionButton(
          label: 'Результаты',
          icon: Icons.bar_chart_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizResultsScreen(quizId: widget.quizId),
            ),
          ),
          filled: true,
        ));
        actions.add(const SizedBox(height: 10));
      }
      actions.add(_ActionButton(
        label: 'Скопировать в мои квизы',
        icon: Icons.copy_outlined,
        onTap: _copyQuiz,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: actions,
    );
  }

  String _fmtDeadline(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  bool _isExpired(DateTime dt) => dt.isBefore(DateTime.now());
}

// ── Publish Dialog ───────────────────────────────────────────────────────────

class _PublishDialog extends StatefulWidget {
  final ValueChanged<bool> onPublicChanged;

  const _PublishDialog({required this.onPublicChanged});

  @override
  State<_PublishDialog> createState() => _PublishDialogState();
}

class _PublishDialogState extends State<_PublishDialog> {
  bool _isPublic = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Публикация квиза',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.mono900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Выберите режим видимости',
              style: AppTextStyles.screenSubtitle,
            ),
            const SizedBox(height: 20),
            _VisibilityOption(
              title: 'Публичный',
              subtitle: 'Квиз появится в общей библиотеке',
              icon: Icons.public_outlined,
              selected: _isPublic,
              onTap: () {
                setState(() => _isPublic = true);
                widget.onPublicChanged(true);
              },
            ),
            const SizedBox(height: 8),
            _VisibilityOption(
              title: 'Приватный',
              subtitle: 'Только вы увидите этот квиз',
              icon: Icons.lock_outline,
              selected: !_isPublic,
              onTap: () {
                setState(() => _isPublic = false);
                widget.onPublicChanged(false);
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: AppDimens.buttonHSm,
                      decoration: BoxDecoration(
                        color: AppColors.mono50,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusLg),
                        border: Border.all(color: AppColors.mono100),
                      ),
                      child: const Center(
                        child: Text(
                          'Отмена',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mono600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: AppDimens.buttonHSm,
                      decoration: BoxDecoration(
                        color: AppColors.mono900,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusLg),
                      ),
                      child: const Center(
                        child: Text(
                          'Опубликовать',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
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

class _VisibilityOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.mono900 : AppColors.mono25,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: selected ? AppColors.mono900 : AppColors.mono100,
            width: AppDimens.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? Colors.white : AppColors.mono400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.mono900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white70 : AppColors.mono400,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ── Confirm Dialog ───────────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final bool danger;

  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.mono900,
              ),
            ),
            const SizedBox(height: 8),
            Text(body, style: AppTextStyles.screenSubtitle),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: AppDimens.buttonHSm,
                      decoration: BoxDecoration(
                        color: AppColors.mono50,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusLg),
                        border: Border.all(color: AppColors.mono100),
                      ),
                      child: const Center(
                        child: Text(
                          'Отмена',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mono600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: AppDimens.buttonHSm,
                      decoration: BoxDecoration(
                        color: danger ? AppColors.error : AppColors.mono900,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusLg),
                      ),
                      child: Center(
                        child: Text(
                          confirmLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
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

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  const _TopBarButton({
    required this.icon,
    required this.onTap,
    this.color,
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
        child: Icon(icon, size: 18, color: color ?? AppColors.mono700),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final QuizStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case QuizStatus.draft:
        bg = AppColors.mono100;
        fg = AppColors.mono600;
        label = 'Черновик';
        break;
      case QuizStatus.active:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        label = 'Активен';
        break;
      case QuizStatus.completed:
        bg = AppColors.mono100;
        fg = AppColors.mono600;
        label = 'Завершён';
        break;
      case QuizStatus.future:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        label = 'Запланирован';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.3,
        ),
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
        color: highlight
            ? const Color(0xFFFEE2E2)
            : AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: highlight ? AppColors.error.withAlpha(80) : AppColors.mono100,
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

  const _QuestionTile({required this.index, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono100, width: AppDimens.borderWidth),
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
        ],
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
      case QuestionType.textInput:
        return 'Свободный ответ';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;
  final bool danger;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color? borderColor;

    if (danger) {
      bg = Colors.white;
      fg = AppColors.error;
      borderColor = AppColors.error.withAlpha(120);
    } else if (filled) {
      bg = AppColors.mono900;
      fg = Colors.white;
      borderColor = null;
    } else {
      bg = AppColors.mono50;
      fg = AppColors.mono900;
      borderColor = AppColors.mono100;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimens.buttonH,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: borderColor != null
              ? Border.all(color: borderColor, width: AppDimens.borderWidth)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
