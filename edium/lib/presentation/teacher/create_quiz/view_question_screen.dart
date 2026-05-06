import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/presentation/shared/widgets/question_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewQuestionScreen extends StatelessWidget {
  final int index;
  final Question question;

  const ViewQuestionScreen({
    super.key,
    required this.index,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Вопрос $index',
          style: AppTextStyles.screenTitle,
        ),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _QuestionTextView(text: question.text, type: question.type),
              if (question.imageId != null) ...[
                const SizedBox(height: 12),
                QuestionImageWidget(imageId: question.imageId!),
              ],
              const SizedBox(height: 24),
              _buildAnswerSection(question),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerSection(Question q) {
    switch (q.type) {
      case QuestionType.singleChoice:
        return _ReadOnlyChoiceSection(options: q.options, isMulti: false);
      case QuestionType.multiChoice:
        return _ReadOnlyChoiceSection(options: q.options, isMulti: true);
      case QuestionType.withGivenAnswer:
        final answers =
            (q.metadata?['correct_answers'] as List?)?.cast<String>() ?? [];
        return _ReadOnlyGivenAnswerSection(answers: answers);
      case QuestionType.withFreeAnswer:
        return const _ReadOnlyFreeAnswerSection();
      case QuestionType.drag:
        final order =
            (q.metadata?['correct_order'] as List?)?.cast<String>() ?? [];
        return _ReadOnlyDragSection(items: order);
      case QuestionType.connection:
        final left = (q.metadata?['left'] as List?)?.cast<String>() ?? [];
        final right = (q.metadata?['right'] as List?)?.cast<String>() ?? [];
        return _ReadOnlyConnectionSection(left: left, right: right);
    }
  }
}

// ─── Question text + type chip ────────────────────────────────────────────────

class _QuestionTextView extends StatelessWidget {
  final String text;
  final QuestionType type;

  const _QuestionTextView({required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ТЕКСТ ВОПРОСА', style: AppTextStyles.sectionTag),
        const SizedBox(height: 8),
        Text(
          text,
          style: AppTextStyles.subtitle.copyWith(color: AppColors.mono900),
        ),
        const SizedBox(height: 10),
        _TypeChip(type: type),
        const SizedBox(height: 10),
        Container(height: 1, color: AppColors.mono100),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final QuestionType type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.mono100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(type), size: 13, color: AppColors.mono400),
          const SizedBox(width: 5),
          Text(
            _labelFor(type),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mono600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(QuestionType t) => switch (t) {
        QuestionType.singleChoice => Icons.radio_button_checked_outlined,
        QuestionType.multiChoice => Icons.check_box_outlined,
        QuestionType.withGivenAnswer => Icons.text_fields_outlined,
        QuestionType.withFreeAnswer => Icons.edit_outlined,
        QuestionType.drag => Icons.swap_vert_outlined,
        QuestionType.connection => Icons.device_hub_outlined,
      };

  String _labelFor(QuestionType t) => switch (t) {
        QuestionType.singleChoice => 'Один ответ',
        QuestionType.multiChoice => 'Несколько ответов',
        QuestionType.withGivenAnswer => 'Данный ответ',
        QuestionType.withFreeAnswer => 'Свободный ответ',
        QuestionType.drag => 'Порядок',
        QuestionType.connection => 'Соответствие',
      };
}

// ─── Single / multi choice ────────────────────────────────────────────────────

class _ReadOnlyChoiceSection extends StatelessWidget {
  final List<AnswerOption> options;
  final bool isMulti;

  const _ReadOnlyChoiceSection({required this.options, required this.isMulti});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ВАРИАНТЫ ОТВЕТА', style: AppTextStyles.sectionTag),
        const SizedBox(height: 10),
        ...options.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ReadOnlyOptionTile(option: opt, isMulti: isMulti),
            )),
        const SizedBox(height: 8),
        Text(
          isMulti
              ? 'Правильных ответов: ${options.where((o) => o.isCorrect).length}'
              : 'Один правильный ответ',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

class _ReadOnlyOptionTile extends StatelessWidget {
  final AnswerOption option;
  final bool isMulti;

  const _ReadOnlyOptionTile({required this.option, required this.isMulti});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: option.isCorrect ? AppColors.mono900 : AppColors.mono150,
          width: option.isCorrect ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: isMulti
                ? _CheckboxIcon(isCorrect: option.isCorrect)
                : _RadioIcon(isCorrect: option.isCorrect),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 14, top: 14, bottom: 14),
              child: Text(
                option.text,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Given answer ─────────────────────────────────────────────────────────────

class _ReadOnlyGivenAnswerSection extends StatelessWidget {
  final List<String> answers;
  const _ReadOnlyGivenAnswerSection({required this.answers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ПРАВИЛЬНЫЕ ОТВЕТЫ', style: AppTextStyles.sectionTag),
        const SizedBox(height: 10),
        ...answers.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ReadOnlyTextTile(
                text: e.value,
                hint: 'Принимаемый ответ ${e.key + 1}',
              ),
            )),
        const SizedBox(height: 8),
        Text(
          'Система примет любой из указанных вариантов написания',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

// ─── Free answer ──────────────────────────────────────────────────────────────

class _ReadOnlyFreeAnswerSection extends StatelessWidget {
  const _ReadOnlyFreeAnswerSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit_outlined,
                size: 20, color: AppColors.mono400),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Свободный ответ',
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Студент пишет текст произвольной формы. Проверяется учителем вручную.',
                  style: AppTextStyles.helperText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Drag order ───────────────────────────────────────────────────────────────

class _ReadOnlyDragSection extends StatelessWidget {
  final List<String> items;
  const _ReadOnlyDragSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ЭЛЕМЕНТЫ В ПРАВИЛЬНОМ ПОРЯДКЕ', style: AppTextStyles.sectionTag),
        const SizedBox(height: 10),
        ...items.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ReadOnlyDragTile(index: e.key, text: e.value),
            )),
        const SizedBox(height: 8),
        Text(
          'Студент расставит элементы в нужном порядке перетаскиванием',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

class _ReadOnlyDragTile extends StatelessWidget {
  final int index;
  final String text;

  const _ReadOnlyDragTile({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono150),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.mono150)),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono400,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                child: Text(
                  text,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.mono900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Connection pairs ─────────────────────────────────────────────────────────

class _ReadOnlyConnectionSection extends StatelessWidget {
  final List<String> left;
  final List<String> right;

  const _ReadOnlyConnectionSection(
      {required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final count = left.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ПАРЫ СООТВЕТСТВИЯ', style: AppTextStyles.sectionTag),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Левая колонка',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.mono400, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 36),
            Expanded(
              child: Text(
                'Правая колонка',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.mono400, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(count, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ReadOnlyConnectionPairTile(
                leftText: i < left.length ? left[i] : '',
                rightText: i < right.length ? right[i] : '',
                index: i,
              ),
            )),
        const SizedBox(height: 8),
        Text(
          'Студент соединит левые элементы с правыми',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

class _ReadOnlyConnectionPairTile extends StatelessWidget {
  final String leftText;
  final String rightText;
  final int index;

  const _ReadOnlyConnectionPairTile({
    required this.leftText,
    required this.rightText,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.mono25,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mono150),
              ),
              child: Text(
                leftText,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mono900),
              ),
            ),
          ),
          Container(
            width: 36,
            color: Colors.white,
            alignment: Alignment.center,
            child: Container(width: 20, height: 1, color: AppColors.mono300),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.mono25,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mono150),
              ),
              child: Text(
                rightText,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mono900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared read-only text tile ───────────────────────────────────────────────

class _ReadOnlyTextTile extends StatelessWidget {
  final String text;
  final String hint;

  const _ReadOnlyTextTile({required this.text, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Text(
        text.isNotEmpty ? text : hint,
        style: AppTextStyles.bodySmall.copyWith(
          color: text.isNotEmpty ? AppColors.mono900 : AppColors.mono300,
        ),
      ),
    );
  }
}

// ─── Icon helpers (reused from add_question_screen style) ─────────────────────

class _RadioIcon extends StatelessWidget {
  final bool isCorrect;
  const _RadioIcon({required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCorrect ? AppColors.mono900 : Colors.transparent,
        border: Border.all(
          color: isCorrect ? AppColors.mono900 : AppColors.mono300,
          width: 1.5,
        ),
      ),
      child: isCorrect
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}

class _CheckboxIcon extends StatelessWidget {
  final bool isCorrect;
  const _CheckboxIcon({required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: isCorrect ? AppColors.mono900 : Colors.transparent,
        border: Border.all(
          color: isCorrect ? AppColors.mono900 : AppColors.mono300,
          width: 1.5,
        ),
      ),
      child: isCorrect
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );
  }
}
