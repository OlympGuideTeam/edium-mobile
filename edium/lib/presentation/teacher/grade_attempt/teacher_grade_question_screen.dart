import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/usecases/test_session/grade_submission_usecase.dart';
import 'package:flutter/material.dart';

class TeacherGradeQuestionScreen extends StatefulWidget {
  final String attemptId;
  final AnswerReview answer;
  final int index;

  const TeacherGradeQuestionScreen({
    super.key,
    required this.attemptId,
    required this.answer,
    required this.index,
  });

  @override
  State<TeacherGradeQuestionScreen> createState() =>
      _TeacherGradeQuestionScreenState();
}

class _TeacherGradeQuestionScreenState
    extends State<TeacherGradeQuestionScreen> {
  late final TextEditingController _scoreCtrl;
  late final TextEditingController _feedbackCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = TextEditingController(
      text: widget.answer.finalScore?.toStringAsFixed(0) ?? '',
    );
    _feedbackCtrl = TextEditingController(
      text: widget.answer.finalFeedback ?? '',
    );
    _scoreCtrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  bool get _canSave => _scoreCtrl.text.trim().isNotEmpty && !_isSaving;

  @override
  void dispose() {
    _scoreCtrl.removeListener(_rebuild);
    _scoreCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final score = double.tryParse(_scoreCtrl.text.trim());
    if (score == null) return;
    setState(() => _isSaving = true);
    try {
      await getIt<GradeSubmissionUsecase>()(
        attemptId: widget.attemptId,
        submissionId: widget.answer.submissionId,
        score: score,
        feedback: _feedbackCtrl.text.trim().isEmpty
            ? null
            : _feedbackCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.mono900,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentText = widget.answer.answerData['text']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppDimens.screenPaddingH, 0, AppDimens.screenPaddingH, 16),
                children: [
                  const SizedBox(height: 8),
                  const Text('Проверка ответа', style: AppTextStyles.screenTitle),
                  const SizedBox(height: 20),

                  // Вопрос
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IndexBadge(index: widget.index),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.answer.questionText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mono900,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Ответ студента
                  Text('Ответ ученика', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.mono50,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      border: Border.all(color: AppColors.mono150),
                    ),
                    child: Text(
                      studentText.isEmpty ? '— нет ответа —' : studentText,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.mono700, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ИИ-статус
                  if (widget.answer.finalScore == null) ...[
                    Row(
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.mono400,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('ИИ проверяет...', style: AppTextStyles.helperText),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Выставьте балл самостоятельно, чтобы не ждать ИИ',
                      style:
                          AppTextStyles.caption.copyWith(color: AppColors.mono400),
                    ),
                  ],
                  if (widget.answer.finalSource == 'llm' &&
                      widget.answer.finalScore != null) ...[
                    Text(
                      'ИИ предложил: ${widget.answer.finalScore!.toStringAsFixed(0)} — можно изменить',
                      style:
                          AppTextStyles.caption.copyWith(color: AppColors.mono400),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Балл
                  Text('Балл', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 8),
                  _ScorePicker(controller: _scoreCtrl),
                  const SizedBox(height: 20),

                  // Комментарий
                  Text('Комментарий', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _feedbackCtrl,
                    maxLines: 4,
                    style: AppTextStyles.fieldText,
                    decoration: InputDecoration(
                      hintText: 'Необязательно',
                      hintStyle: AppTextStyles.fieldHint,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: const BorderSide(
                            color: AppColors.mono150,
                            width: AppDimens.borderWidth),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: const BorderSide(
                            color: AppColors.mono600,
                            width: AppDimens.borderWidth),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Кнопка сохранить
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPaddingH, 8, AppDimens.screenPaddingH, 16),
              child: SizedBox(
                width: double.infinity,
                height: AppDimens.buttonH,
                child: ElevatedButton(
                  onPressed: _canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mono900,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.mono200,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusLg),
                    ),
                    elevation: 0,
                    textStyle: AppTextStyles.primaryButton,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Сохранить'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ──────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: AppColors.mono900),
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  final int index;
  const _IndexBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _ScorePicker extends StatelessWidget {
  final TextEditingController controller;
  const _ScorePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    final selected = int.tryParse(controller.text.trim());
    return Column(
      children: [
        _ScoreRow(
            values: const [1, 2, 3, 4, 5],
            selected: selected,
            controller: controller),
        const SizedBox(height: 6),
        _ScoreRow(
            values: const [6, 7, 8, 9, 10],
            selected: selected,
            controller: controller),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final List<int> values;
  final int? selected;
  final TextEditingController controller;

  const _ScoreRow({
    required this.values,
    required this.selected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
              child: _ScoreChip(
                  value: values[i],
                  isSelected: selected == values[i],
                  controller: controller)),
        ],
      ],
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final int value;
  final bool isSelected;
  final TextEditingController controller;

  const _ScoreChip({
    required this.value,
    required this.isSelected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.text = value.toString(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mono900 : Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          border: Border.all(
            color: isSelected ? AppColors.mono900 : AppColors.mono150,
            width: AppDimens.borderWidth,
          ),
        ),
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.mono600,
          ),
          child: Text('$value'),
        ),
      ),
    );
  }
}
