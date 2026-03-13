import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/presentation/shared/widgets/edium_text_field.dart';
import 'package:edium/presentation/teacher/create_quiz/add_question_screen.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_event.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _titleCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateQuizBloc, CreateQuizState>(
      listener: (context, state) {
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Квиз успешно создан!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<CreateQuizBloc>().add(const ResetCreateQuizEvent());
          _titleCtrl.clear();
          _subjectCtrl.clear();
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!),
                backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Создать квиз')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Основная информация', style: AppTextStyles.subtitle),
                const SizedBox(height: 16),
                EdiumTextField(
                  label: 'Название квиза',
                  hint: 'Например: Алгебра — контрольная работа',
                  controller: _titleCtrl,
                  onChanged: (v) =>
                      context.read<CreateQuizBloc>().add(UpdateTitleEvent(v)),
                ),
                const SizedBox(height: 14),
                EdiumTextField(
                  label: 'Предмет',
                  hint: 'Математика, История, Физика...',
                  controller: _subjectCtrl,
                  onChanged: (v) =>
                      context.read<CreateQuizBloc>().add(UpdateSubjectEvent(v)),
                ),
                const SizedBox(height: 24),
                Text('Настройки', style: AppTextStyles.subtitle),
                const SizedBox(height: 12),
                _SettingsCard(settings: state.settings),
                if (state.needsTimeOrDeadline) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Укажите ограничение по времени или дедлайн',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Вопросы (${state.questions.length})',
                        style: AppTextStyles.subtitle),
                    TextButton.icon(
                      onPressed: () async {
                        final q = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddQuestionScreen()),
                        );
                        if (q != null && context.mounted) {
                          context
                              .read<CreateQuizBloc>()
                              .add(AddQuestionEvent(q));
                        }
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Добавить'),
                    ),
                  ],
                ),
                if (state.questions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.cardBorder,
                          style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.quiz_outlined,
                            size: 40, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Text('Нет вопросов',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Нажмите «Добавить» для создания',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.questions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final q = state.questions[i];
                      return _QuestionTile(
                        index: i,
                        question: q,
                        onRemove: () => context
                            .read<CreateQuizBloc>()
                            .add(RemoveQuestionEvent(i)),
                      );
                    },
                  ),
                const SizedBox(height: 32),
                EdiumButton(
                  label: 'Создать квиз',
                  onPressed: state.canSubmit && !state.isSubmitting
                      ? () => context
                          .read<CreateQuizBloc>()
                          .add(const SubmitQuizEvent())
                      : null,
                  isLoading: state.isSubmitting,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final QuizSettings settings;

  const _SettingsCard({required this.settings});

  void _emit(BuildContext context, QuizSettings s) =>
      context.read<CreateQuizBloc>().add(UpdateSettingsEvent(s));

  @override
  Widget build(BuildContext context) {
    final hasTimeLimit = settings.timeLimitMinutes != null;
    final hasDeadline = settings.deadline != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _SettingRow(
            label: 'Перемешать вопросы',
            value: settings.shuffleQuestions,
            onChanged: (v) => _emit(
              context,
              QuizSettings(
                timeLimitMinutes: settings.timeLimitMinutes,
                shuffleQuestions: v,
                showExplanations: settings.showExplanations,
                deadline: settings.deadline,
              ),
            ),
          ),
          const Divider(height: 16),
          _SettingRow(
            label: 'Показывать объяснения',
            value: settings.showExplanations,
            onChanged: (v) => _emit(
              context,
              QuizSettings(
                timeLimitMinutes: settings.timeLimitMinutes,
                shuffleQuestions: settings.shuffleQuestions,
                showExplanations: v,
                deadline: settings.deadline,
              ),
            ),
          ),
          // Time limit — hidden when deadline is active
          if (!hasDeadline) ...[
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ограничение времени', style: AppTextStyles.bodySmall),
                Row(
                  children: [
                    if (hasTimeLimit)
                      Text(
                        '${settings.timeLimitMinutes} мин',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary),
                      ),
                    Switch(
                      value: hasTimeLimit,
                      onChanged: (v) => _emit(
                        context,
                        QuizSettings(
                          timeLimitMinutes: v ? 20 : null,
                          shuffleQuestions: settings.shuffleQuestions,
                          showExplanations: settings.showExplanations,
                          deadline: null,
                        ),
                      ),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
            if (hasTimeLimit) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 4),
                  Expanded(
                    child: Slider(
                      value: (settings.timeLimitMinutes ?? 20).toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      label: '${settings.timeLimitMinutes} мин',
                      activeColor: AppColors.primary,
                      onChanged: (v) => _emit(
                        context,
                        QuizSettings(
                          timeLimitMinutes: v.round(),
                          shuffleQuestions: settings.shuffleQuestions,
                          showExplanations: settings.showExplanations,
                          deadline: null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
          // Deadline — hidden when time limit is active
          if (!hasTimeLimit) ...[
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Дедлайн', style: AppTextStyles.bodySmall),
                Row(
                  children: [
                    if (hasDeadline)
                      Text(
                        _formatDeadline(settings.deadline!),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.secondary),
                      ),
                    Switch(
                      value: hasDeadline,
                      onChanged: (v) async {
                        if (v) {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
                          );
                          if (picked != null && context.mounted) {
                            _emit(
                              context,
                              QuizSettings(
                                timeLimitMinutes: null,
                                shuffleQuestions: settings.shuffleQuestions,
                                showExplanations: settings.showExplanations,
                                deadline: picked,
                              ),
                            );
                          }
                        } else {
                          _emit(
                            context,
                            QuizSettings(
                              timeLimitMinutes: null,
                              shuffleQuestions: settings.shuffleQuestions,
                              showExplanations: settings.showExplanations,
                              deadline: null,
                            ),
                          );
                        }
                      },
                      activeColor: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDeadline(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> question;
  final VoidCallback onRemove;

  const _QuestionTile({
    required this.index,
    required this.question,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final type = question['type'] as String? ?? 'single_choice';
    final typeLabel = {
      'single_choice': 'Один ответ',
      'multi_choice': 'Несколько',
      'text_input': 'Текст',
    }[type] ?? type;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
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
                  question['text'] as String? ?? '',
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(typeLabel, style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: AppColors.error),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
