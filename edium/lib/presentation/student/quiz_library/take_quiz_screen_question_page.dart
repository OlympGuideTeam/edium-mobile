part of 'take_quiz_screen.dart';

class _QuestionPage extends StatefulWidget {
  final QuizQuestionForStudent question;
  final Map<String, dynamic>? answer;

  const _QuestionPage({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<_QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<_QuestionPage>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _textController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.answer?['text'] as String? ?? '',
    );
  }

  @override
  void didUpdateWidget(_QuestionPage old) {
    super.didUpdateWidget(old);
    if (old.question.id != widget.question.id) {
      final text = widget.answer?['text'] as String? ?? '';
      _textController.text = text;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.mono900,
                height: 1.4,
              ),
            ),
            if (widget.question.imageId != null) ...[
              const SizedBox(height: 16),
              QuestionImageWidget(imageId: widget.question.imageId!),
            ],
            const SizedBox(height: 24),
            _buildAnswerWidget(context),
            if (widget.question.type ==
                QuizQuestionType.withFreeAnswer) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mono50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.mono150),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome_outlined,
                        size: 14, color: AppColors.mono400),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Свободный ответ проверяется автоматически с помощью ИИ.',
                        style: AppTextStyles.helperText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerWidget(BuildContext context) {
    final question = widget.question;
    final answer = widget.answer;

    switch (question.type) {
      case QuizQuestionType.singleChoice:
        final selectedId = answer?['selected_option_id'] as String?;
        return Column(
          children: (question.options ?? []).map((opt) {
            final isSelected = selectedId == opt.id;
            return GestureDetector(
              onTap: () => context.read<TakeQuizBloc>().add(
                    SetAnswerEvent({'selected_option_id': opt.id}),
                  ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.mono25,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.mono900
                        : AppColors.mono150,
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.mono900
                              : AppColors.mono250,
                          width: isSelected ? 6 : 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt.text,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected
                              ? AppColors.mono900
                              : AppColors.mono700,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

      case QuizQuestionType.multipleChoice:
        final selectedIds = ((answer?['selected_option_ids']
                    as List<dynamic>?) ??
                [])
            .map((e) => e.toString())
            .toSet();
        return Column(
          children: (question.options ?? []).map((opt) {
            final isSelected = selectedIds.contains(opt.id);
            return GestureDetector(
              onTap: () {
                final updated = Set<String>.from(selectedIds);
                if (isSelected) {
                  updated.remove(opt.id);
                } else {
                  updated.add(opt.id);
                }
                context.read<TakeQuizBloc>().add(SetAnswerEvent(
                    {'selected_option_ids': updated.toList()}));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.mono25,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.mono900
                        : AppColors.mono150,
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.mono900
                            : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.mono900
                              : AppColors.mono250,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 13, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt.text,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected
                              ? AppColors.mono900
                              : AppColors.mono700,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

      case QuizQuestionType.withGivenAnswer:
        return SizedBox(
          height: AppDimens.buttonH,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mono25,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: AppColors.mono100,
                width: AppDimens.borderWidth,
              ),
            ),
            child: NoCopyTextField(
              controller: _textController,
              maxLines: 1,
              style: const TextStyle(fontSize: 15, color: AppColors.mono700),
              cursorColor: AppColors.mono900,
              onChanged: (v) => context
                  .read<TakeQuizBloc>()
                  .add(SetAnswerEvent({'text': v})),
              decoration: const InputDecoration(
                hintText: 'Введите ответ…',
                hintStyle:
                    TextStyle(fontSize: 15, color: AppColors.mono250),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        );

      case QuizQuestionType.withFreeAnswer:
        return Container(
          decoration: BoxDecoration(
            color: AppColors.mono25,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: AppColors.mono100,
              width: AppDimens.borderWidth,
            ),
          ),
          child: NoCopyTextField(
            controller: _textController,
            maxLines: 5,
            style: const TextStyle(fontSize: 15, color: AppColors.mono700),
            cursorColor: AppColors.mono900,
            onChanged: (v) => context
                .read<TakeQuizBloc>()
                .add(SetAnswerEvent({'text': v})),
            decoration: const InputDecoration(
              hintText: 'Введите развёрнутый ответ…',
              hintStyle:
                  TextStyle(fontSize: 15, color: AppColors.mono250),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        );

      case QuizQuestionType.drag:
        return _DragQuestion(
          question: question,
          currentOrder: (answer?['order'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              ((question.metadata?['items'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  []),
          onReorder: (order) => context
              .read<TakeQuizBloc>()
              .add(SetAnswerEvent({'order': order})),
        );

      case QuizQuestionType.connection:
        return _ConnectionQuestion(
          question: question,
          currentPairs:
              (answer?['pairs'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, v.toString())),
          onPairsChanged: (pairs) => context
              .read<TakeQuizBloc>()
              .add(SetAnswerEvent({'pairs': pairs})),
        );
    }
  }
}

