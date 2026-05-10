part of 'teacher_grade_attempt_screen.dart';

class _FreeAnswerInlineCard extends StatefulWidget {
  final int index;
  final AnswerReview answer;
  final double? initialScore;
  final String? initialFeedback;
  final void Function(double score, String? feedback) onGradeChanged;

  const _FreeAnswerInlineCard({
    required this.index,
    required this.answer,
    required this.initialScore,
    required this.initialFeedback,
    required this.onGradeChanged,
  });

  @override
  State<_FreeAnswerInlineCard> createState() => _FreeAnswerInlineCardState();
}

class _FreeAnswerInlineCardState extends State<_FreeAnswerInlineCard> {
  late final TextEditingController _scoreCtrl;
  late final TextEditingController _feedbackCtrl;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = TextEditingController(
      text: widget.initialScore?.toStringAsFixed(0) ?? '',
    );
    _feedbackCtrl = TextEditingController(
      text: widget.initialFeedback ?? '',
    );
    _scoreCtrl.addListener(_onScoreChanged);
  }

  void _onScoreChanged() {
    final score = double.tryParse(_scoreCtrl.text.trim());
    if (score != null) {
      final feedback = _feedbackCtrl.text.trim();
      widget.onGradeChanged(score, feedback.isEmpty ? null : feedback);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _scoreCtrl.removeListener(_onScoreChanged);
    _scoreCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentText = widget.answer.answerData['text']?.toString() ?? '';
    final hasScore = double.tryParse(_scoreCtrl.text.trim()) != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IndexBadge(index: widget.index),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.answer.questionText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                    height: 1.3,
                  ),
                ),
              ),
              if (hasScore)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mono900,
                    borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                  ),
                  child: Text(
                    _scoreCtrl.text,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          if (widget.answer.imageId != null) ...[
            const SizedBox(height: 10),
            QuestionImageWidget(imageId: widget.answer.imageId!),
          ],
          const SizedBox(height: 14),

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

          if (!hasScore)
            Row(
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: AppColors.mono400),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'ИИ проверяет... Выставьте балл самостоятельно, чтобы не ждать',
                    style: AppTextStyles.caption.copyWith(color: AppColors.mono400),
                  ),
                ),
              ],
            )
          else if (widget.answer.finalSource == 'llm')
            Text(
              'ИИ предложил: ${widget.initialScore!.toStringAsFixed(0)} — можно изменить',
              style: AppTextStyles.caption.copyWith(color: AppColors.mono400),
            ),
          const SizedBox(height: 16),

          Text('Балл', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 8),
          _ScorePicker(
            controller: _scoreCtrl,
            onFeedbackChanged: () {
              final score = double.tryParse(_scoreCtrl.text.trim());
              if (score != null) {
                final fb = _feedbackCtrl.text.trim();
                widget.onGradeChanged(score, fb.isEmpty ? null : fb);
              }
            },
          ),
          const SizedBox(height: 16),

          Text('Комментарий', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 6),
          TextField(
            controller: _feedbackCtrl,
            maxLines: 4,
            style: AppTextStyles.fieldText,
            onChanged: (_) {
              final score = double.tryParse(_scoreCtrl.text.trim());
              if (score != null) {
                final fb = _feedbackCtrl.text.trim();
                widget.onGradeChanged(score, fb.isEmpty ? null : fb);
              }
            },
            decoration: InputDecoration(
              hintText: 'Необязательно',
              hintStyle: AppTextStyles.fieldHint,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                borderSide: const BorderSide(
                    color: AppColors.mono150, width: AppDimens.borderWidth),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                borderSide: const BorderSide(
                    color: AppColors.mono600, width: AppDimens.borderWidth),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

