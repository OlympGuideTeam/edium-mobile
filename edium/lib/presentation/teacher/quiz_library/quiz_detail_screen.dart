import 'package:edium/core/di/injection.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Опубликовать квиз?'),
        content: const Text('После публикации студенты смогут проходить этот квиз.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
            ),
            child: const Text('Опубликовать'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await getIt<IQuizRepository>().updateQuizStatus(widget.quizId, 'active');
      await _load();
      if (mounted) {
        EdiumNotification.show(context, 'Квиз опубликован!');
      }
    } catch (e) {
      if (mounted) {
        EdiumNotification.show(context, 'Ошибка: $e', type: EdiumNotificationType.error);
      }
    }
  }

  Future<void> _deleteQuiz() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Удалить квиз?'),
        content: const Text('Черновик будет удалён без возможности восстановления.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await getIt<IQuizRepository>().deleteQuiz(widget.quizId);
      if (mounted) {
        EdiumNotification.show(context, 'Квиз удалён');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        EdiumNotification.show(context, 'Ошибка: $e', type: EdiumNotificationType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_quiz == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.quiz_outlined, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text('Квиз не найден', style: AppTextStyles.subtitle),
            ],
          ),
        ),
      );
    }

    final quiz = _quiz!;
    final isDraft = quiz.status == QuizStatus.draft;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Top header area
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF7C6CF9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            _HeaderChip(label: quiz.subject),
                            const SizedBox(width: 8),
                            _StatusHeaderChip(status: quiz.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          quiz.title,
                          style: AppTextStyles.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              if (quiz.status == QuizStatus.active || quiz.status == QuizStatus.completed)
                IconButton(
                  icon: const Icon(Icons.bar_chart_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizResultsScreen(quizId: widget.quizId),
                    ),
                  ),
                  tooltip: 'Результаты',
                ),
              if (isDraft && _isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _deleteQuiz,
                  tooltip: 'Удалить',
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            quiz.authorName.isNotEmpty ? quiz.authorName[0] : '?',
                            style: AppTextStyles.subtitle.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quiz.authorName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _isOwner ? 'Ваш квиз' : 'Автор',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.favorite,
                                size: 16, color: quiz.isLiked ? AppColors.secondary : AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${quiz.likesCount}', style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settings grid
                  _SettingsGrid(quiz: quiz),
                  const SizedBox(height: 24),

                  // Questions list
                  Row(
                    children: [
                      Text('Вопросы', style: AppTextStyles.subtitle),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${quiz.questionsCount}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...quiz.questions.asMap().entries.map((entry) {
                    final i = entry.key;
                    final q = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
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
                                  q.text,
                                  style: AppTextStyles.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _questionTypeLabel(q.type.name),
                                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Action buttons
                  if (isDraft && _isOwner) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _publishQuiz,
                        icon: const Icon(Icons.publish_outlined),
                        label: const Text('Опубликовать'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _deleteQuiz,
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        label: Text('Удалить черновик',
                            style: TextStyle(color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'После публикации студенты смогут проходить квиз.',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  if ((quiz.status == QuizStatus.active || quiz.status == QuizStatus.completed)) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizResultsScreen(quizId: widget.quizId),
                          ),
                        ),
                        icon: const Icon(Icons.bar_chart_outlined),
                        label: const Text('Посмотреть результаты'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _questionTypeLabel(String type) {
    switch (type) {
      case 'singleChoice':
        return 'Один ответ';
      case 'multiChoice':
        return 'Несколько ответов';
      case 'textInput':
        return 'Текстовый ввод';
      default:
        return type;
    }
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;

  const _HeaderChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusHeaderChip extends StatelessWidget {
  final QuizStatus status;

  const _StatusHeaderChip({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (status) {
      case QuizStatus.active:
        label = 'Активен';
        break;
      case QuizStatus.completed:
        label = 'Завершён';
        break;
      case QuizStatus.draft:
        label = 'Черновик';
        break;
      case QuizStatus.future:
        label = 'Запланирован';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withAlpha(60)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsGrid extends StatelessWidget {
  final Quiz quiz;

  const _SettingsGrid({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _SettingCard(
          icon: Icons.quiz_outlined,
          label: 'Вопросов',
          value: '${quiz.questionsCount}',
          color: AppColors.primary,
        ),
        if (quiz.settings.timeLimitMinutes != null)
          _SettingCard(
            icon: Icons.timer_outlined,
            label: 'Время',
            value: '${quiz.settings.timeLimitMinutes} мин',
            color: AppColors.secondary,
          ),
        if (quiz.settings.deadline != null)
          _SettingCard(
            icon: Icons.event_outlined,
            label: 'Дедлайн',
            value: _fmtDeadline(quiz.settings.deadline!),
            color: _isExpired(quiz.settings.deadline!) ? AppColors.error : AppColors.success,
          ),
        _SettingCard(
          icon: quiz.settings.shuffleQuestions ? Icons.shuffle : Icons.format_list_numbered,
          label: 'Порядок',
          value: quiz.settings.shuffleQuestions ? 'Случайный' : 'Фиксированный',
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  String _fmtDeadline(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}';
  }

  bool _isExpired(DateTime dt) => dt.isBefore(DateTime.now());
}

class _SettingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SettingCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 50) / 2,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w700)),
                Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
