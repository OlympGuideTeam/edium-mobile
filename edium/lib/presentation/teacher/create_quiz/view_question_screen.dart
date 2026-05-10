import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/presentation/shared/widgets/question_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'view_question_screen_question_text_view.dart';
part 'view_question_screen_type_chip.dart';
part 'view_question_screen_read_only_choice_section.dart';
part 'view_question_screen_read_only_option_tile.dart';
part 'view_question_screen_read_only_given_answer_section.dart';
part 'view_question_screen_read_only_free_answer_section.dart';
part 'view_question_screen_read_only_drag_section.dart';
part 'view_question_screen_read_only_drag_tile.dart';
part 'view_question_screen_read_only_connection_section.dart';
part 'view_question_screen_read_only_connection_pair_tile.dart';
part 'view_question_screen_read_only_text_tile.dart';
part 'view_question_screen_radio_icon.dart';
part 'view_question_screen_checkbox_icon.dart';


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

