import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/take_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum QuizUserStatus { notStarted, inProgress, completed }

class QuizPreviewScreen extends StatelessWidget {
  final Quiz quiz;
  final QuizUserStatus userStatus;
  final String? sessionId; // for resuming in-progress
  final int? userScore;
  final int? userTotal;

  const QuizPreviewScreen({
    super.key,
    required this.quiz,
    this.userStatus = QuizUserStatus.notStarted,
    this.sessionId,
    this.userScore,
    this.userTotal,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = userStatus == QuizUserStatus.completed;
    final isInProgress = userStatus == QuizUserStatus.inProgress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('О квизе'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject chip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                quiz.subject,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(quiz.title, style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(
              'Автор: ${quiz.authorName}',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            // Info cards
            _InfoRow(
              icon: Icons.quiz_outlined,
              label: 'Количество вопросов',
              value: '${quiz.questionsCount}',
              color: AppColors.primary,
            ),
            if (quiz.settings.timeLimitMinutes != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.timer_outlined,
                label: 'Ограничение по времени',
                value: '${quiz.settings.timeLimitMinutes} мин',
                color: AppColors.secondary,
              ),
            ],
            if (quiz.settings.deadline != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.event_outlined,
                label: 'Дедлайн',
                value: _formatDeadline(quiz.settings.deadline!),
                color: AppColors.error,
              ),
            ],
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.shuffle_outlined,
              label: 'Перемешивание вопросов',
              value: quiz.settings.shuffleQuestions ? 'Да' : 'Нет',
              color: AppColors.textSecondary,
            ),

            // Completed — show results
            if (isCompleted && userScore != null && userTotal != null) ...[
              const SizedBox(height: 24),
              _ResultCard(score: userScore!, total: userTotal!),
            ],

            // In-progress warning
            if (isInProgress &&
                quiz.settings.timeLimitMinutes != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: AppColors.secondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Таймер продолжает идти. Вернитесь к квизу, чтобы завершить его.',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Not started — timer warning
            if (!isInProgress &&
                !isCompleted &&
                quiz.settings.timeLimitMinutes != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_outlined,
                        color: AppColors.secondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Таймер начнётся сразу после нажатия «Начать» и не остановится, даже если вы покинете экран.',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            // Bottom action
            if (isCompleted)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Вернуться к квизам'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              )
            else if (isInProgress)
              EdiumButton(
                label: 'Продолжить квиз',
                icon: Icons.play_arrow_outlined,
                onPressed: () => _navigateToQuiz(context, sessionId),
              )
            else
              EdiumButton(
                label: 'Начать квиз',
                icon: Icons.play_arrow_outlined,
                onPressed: () => _navigateToQuiz(context, null),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _navigateToQuiz(BuildContext context, String? resumeId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => TakeQuizBloc(
            startSession: getIt(),
            submitAnswer: getIt(),
            completeSession: getIt(),
            getQuizzes: getIt(),
            sessionRepo: getIt(),
          ),
          child: TakeQuizScreen(
            quizId: quiz.id,
            resumeSessionId: resumeId,
          ),
        ),
      ),
    );
  }

  String _formatDeadline(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}

class _ResultCard extends StatelessWidget {
  final int score;
  final int total;

  const _ResultCard({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (score / total * 100).round() : 0;
    final passed = pct >= 60;
    final color = passed ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Icon(
            passed ? Icons.emoji_events : Icons.refresh_outlined,
            color: color,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            '$pct%',
            style: AppTextStyles.heading1.copyWith(
              color: color,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score из $total правильных',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            passed ? 'Квиз пройден!' : 'Не сдавайтесь!',
            style: AppTextStyles.subtitle.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
