import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/teacher/create_quiz/add_question_screen.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_event.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateQuizScreen extends StatefulWidget {
  /// When non-null the screen is opened in course context:
  /// user can pick Шаблон / Тест / Лайв and quiz is linked to the module.
  final String? moduleId;

  const CreateQuizScreen({super.key, this.moduleId});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateQuizBloc, CreateQuizState>(
      listener: (context, state) {
        if (state.success) {
          final label = switch (state.quizType) {
            QuizCreationMode.test => 'Тест создан',
            QuizCreationMode.live => 'Лайв создан',
            QuizCreationMode.template => 'Шаблон создан',
          };
          EdiumNotification.show(context, label);
          Navigator.pop(context, true);
          context.read<CreateQuizBloc>().add(const ResetCreateQuizEvent());
        }
        if (state.error != null) {
          EdiumNotification.show(
            context,
            state.error!,
            type: EdiumNotificationType.error,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context, state),
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
                        _TitleField(controller: _titleCtrl),
                        const SizedBox(height: 16),
                        _DescriptionField(controller: _descCtrl),
                        if (state.isInCourseContext) ...[
                          const SizedBox(height: 28),
                          _SectionLabel('ТИП КВИЗА'),
                          const SizedBox(height: 12),
                          _QuizTypeSelector(quizType: state.quizType),
                        ],
                        const SizedBox(height: 28),
                        _SectionLabel('НАСТРОЙКИ'),
                        const SizedBox(height: 12),
                        _SettingsCard(state: state),
                        const SizedBox(height: 28),
                        _SectionLabel('ВОПРОСЫ (${state.questions.length})'),
                        const SizedBox(height: 12),
                        _QuestionsList(
                          questions: state.questions,
                          onAdd: () => _openAddQuestion(context),
                          onRemove: (i) => context
                              .read<CreateQuizBloc>()
                              .add(RemoveQuestionEvent(i)),
                          onEdit: (i) =>
                              _openEditQuestion(context, i, state.questions[i]),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                _BottomBar(state: state),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, CreateQuizState state) {
    final title = state.isInCourseContext
        ? switch (state.quizType) {
            QuizCreationMode.test => 'Новый тест',
            QuizCreationMode.live => 'Новый лайв',
            QuizCreationMode.template => 'Новый шаблон',
          }
        : 'Новый шаблон';
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.mono700, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(title, style: AppTextStyles.screenTitle),
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  Future<void> _openAddQuestion(BuildContext context) async {
    final q = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddQuestionScreen()),
    );
    if (q != null && context.mounted) {
      context.read<CreateQuizBloc>().add(AddQuestionEvent(q));
    }
  }

  Future<void> _openEditQuestion(
    BuildContext context,
    int index,
    Map<String, dynamic> existing,
  ) async {
    final q = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddQuestionScreen(initialQuestion: existing),
      ),
    );
    if (q != null && context.mounted) {
      context.read<CreateQuizBloc>().add(ReplaceQuestionEvent(index, q));
    }
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.sectionTag);
  }
}

// ─── Quiz type selector ───────────────────────────────────────────────────────

class _QuizTypeSelector extends StatelessWidget {
  final QuizCreationMode quizType;
  const _QuizTypeSelector({required this.quizType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono100),
      ),
      child: Row(
        children: [
          _TypePill(
            label: 'Шаблон',
            icon: Icons.bookmark_border_outlined,
            isActive: quizType == QuizCreationMode.template,
            onTap: () => context
                .read<CreateQuizBloc>()
                .add(SetQuizTypeEvent(QuizCreationMode.template)),
          ),
          _TypePill(
            label: 'Тест',
            icon: Icons.timer_outlined,
            isActive: quizType == QuizCreationMode.test,
            onTap: () => context
                .read<CreateQuizBloc>()
                .add(SetQuizTypeEvent(QuizCreationMode.test)),
          ),
          _TypePill(
            label: 'Лайв',
            icon: Icons.bolt_outlined,
            isActive: quizType == QuizCreationMode.live,
            onTap: () => context
                .read<CreateQuizBloc>()
                .add(SetQuizTypeEvent(QuizCreationMode.live)),
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TypePill({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.mono900 : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? Colors.white : AppColors.mono400,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : AppColors.mono400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Title field ──────────────────────────────────────────────────────────────

class _TitleField extends StatelessWidget {
  final TextEditingController controller;
  const _TitleField({required this.controller});

  static const _maxLength = 100;

  static const _inputDecoration = InputDecoration(
    hintText: 'Например: Алгебра — контрольная',
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    contentPadding: EdgeInsets.zero,
    isDense: true,
    counterText: '',
  );

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
          decoration: _inputDecoration.copyWith(
            hintStyle: AppTextStyles.subtitle.copyWith(
              color: AppColors.mono300,
              fontWeight: FontWeight.w400,
            ),
          ),
          cursorColor: AppColors.mono900,
          minLines: 1,
          maxLines: null,
          maxLength: _maxLength,
          textInputAction: TextInputAction.next,
          onChanged: (v) =>
              context.read<CreateQuizBloc>().add(UpdateTitleEvent(v)),
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

  static const _inputDecoration = InputDecoration(
    hintText: 'Краткое описание шаблона...',
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    contentPadding: EdgeInsets.zero,
    isDense: true,
    counterText: '',
  );

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
          decoration: _inputDecoration.copyWith(
            hintStyle: AppTextStyles.fieldHint,
          ),
          cursorColor: AppColors.mono900,
          minLines: 1,
          maxLines: null,
          maxLength: _maxLength,
          textInputAction: TextInputAction.done,
          onChanged: (v) =>
              context.read<CreateQuizBloc>().add(UpdateDescriptionEvent(v)),
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

// ─── Settings card (mode-aware) ───────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final CreateQuizState state;
  const _SettingsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    // For library context (no moduleId) show all settings with hints.
    // For course context, show only settings relevant to the chosen type.
    final showTotalTime = !state.isInCourseContext ||
        state.quizType == QuizCreationMode.template ||
        state.quizType == QuizCreationMode.test;
    final showQuestionTime = !state.isInCourseContext ||
        state.quizType == QuizCreationMode.template ||
        state.quizType == QuizCreationMode.live;
    final showShuffle = !state.isInCourseContext ||
        state.quizType == QuizCreationMode.template ||
        state.quizType == QuizCreationMode.test;

    // Nothing to show for some edge case — show empty card.
    if (!showTotalTime && !showQuestionTime && !showShuffle) {
      return const SizedBox.shrink();
    }

    final rows = <Widget>[];

    if (showTotalTime) {
      rows.add(_TimeRow(
        label: 'Время на весь квиз',
        subtitle: state.isInCourseContext && state.quizType == QuizCreationMode.template
            ? 'Применяется только в режиме «Тест»'
            : null,
        valueSec: state.totalTimeLimitSec,
        unit: 'мин',
        unitDivisor: 60,
        sliderMinUnits: 5,
        sliderMaxUnits: 90,
        sliderStep: 5,
        defaultValueSec: 1200,
        onToggle: (on) => context.read<CreateQuizBloc>().add(
              UpdateTotalTimeLimitEvent(on ? 1200 : null),
            ),
        onValueChanged: (sec) => context
            .read<CreateQuizBloc>()
            .add(UpdateTotalTimeLimitEvent(sec)),
      ));
    }

    if (showTotalTime && showQuestionTime) {
      rows.add(_CardDivider());
    }

    if (showQuestionTime) {
      rows.add(_TimeRow(
        label: 'Время на вопрос',
        subtitle: state.isInCourseContext && state.quizType == QuizCreationMode.template
            ? 'Применяется только в режиме «Лайв»'
            : null,
        valueSec: state.questionTimeLimitSec,
        unit: 'сек',
        unitDivisor: 1,
        sliderMinUnits: 5,
        sliderMaxUnits: 90,
        sliderStep: 5,
        defaultValueSec: 30,
        onToggle: (on) => context.read<CreateQuizBloc>().add(
              UpdateQuestionTimeLimitEvent(on ? 30 : null),
            ),
        onValueChanged: (sec) => context
            .read<CreateQuizBloc>()
            .add(UpdateQuestionTimeLimitEvent(sec)),
      ));
    }

    if (showShuffle && (showTotalTime || showQuestionTime)) {
      rows.add(_CardDivider());
    }

    if (showShuffle) {
      rows.add(_ShuffleRow(value: state.shuffleQuestions));
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      child: Container(
        key: ValueKey(state.quizType),
        decoration: BoxDecoration(
          color: AppColors.mono25,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mono100),
        ),
        child: Column(children: rows),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColors.mono100);
}

class _ShuffleRow extends StatelessWidget {
  final bool value;
  const _ShuffleRow({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Перемешать вопросы',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.mono700),
            ),
          ),
          _MonoSwitch(
            value: value,
            onChanged: (v) => context
                .read<CreateQuizBloc>()
                .add(UpdateShuffleQuestionsEvent(v)),
          ),
        ],
      ),
    );
  }
}

// ─── Time row with stepped slider + tap-to-input ─────────────────────────────

class _TimeRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final int? valueSec;
  final String unit;
  final int unitDivisor;
  final int sliderMinUnits;
  final int sliderMaxUnits;
  final int sliderStep;
  final int defaultValueSec;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onValueChanged;

  const _TimeRow({
    required this.label,
    this.subtitle,
    required this.valueSec,
    required this.unit,
    required this.unitDivisor,
    required this.sliderMinUnits,
    required this.sliderMaxUnits,
    required this.sliderStep,
    required this.defaultValueSec,
    required this.onToggle,
    required this.onValueChanged,
  });

  int get _currentUnits =>
      valueSec != null ? (valueSec! / unitDivisor).round() : sliderMinUnits;

  int get _divisions => (sliderMaxUnits - sliderMinUnits) ~/ sliderStep;

  String get _displayText => '$_currentUnits $unit';

  Future<void> _showInputDialog(BuildContext context) async {
    final ctrl = TextEditingController(text: '$_currentUnits');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => _TimeInputDialog(
        controller: ctrl,
        unit: unit,
        minValue: sliderMinUnits,
        maxValue: sliderMaxUnits,
      ),
    );
    if (result != null) {
      final clamped = result.clamp(sliderMinUnits, sliderMaxUnits);
      onValueChanged(clamped * unitDivisor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.mono700)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.mono400, fontSize: 11)),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  if (valueSec != null)
                    GestureDetector(
                      onTap: () => _showInputDialog(context),
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
                  const SizedBox(width: 8),
                  _MonoSwitch(value: valueSec != null, onChanged: onToggle),
                ],
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: valueSec != null
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.mono900,
                      inactiveTrackColor: AppColors.mono150,
                      thumbColor: AppColors.mono900,
                      overlayColor:
                          AppColors.mono900.withValues(alpha: 0.08),
                      trackHeight: 2,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: _currentUnits
                          .toDouble()
                          .clamp(sliderMinUnits.toDouble(),
                              sliderMaxUnits.toDouble()),
                      min: sliderMinUnits.toDouble(),
                      max: sliderMaxUnits.toDouble(),
                      divisions: _divisions,
                      onChanged: (v) =>
                          onValueChanged(v.round() * unitDivisor),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _TimeInputDialog extends StatefulWidget {
  final TextEditingController controller;
  final String unit;
  final int minValue;
  final int maxValue;

  const _TimeInputDialog({
    required this.controller,
    required this.unit,
    required this.minValue,
    required this.maxValue,
  });

  @override
  State<_TimeInputDialog> createState() => _TimeInputDialogState();
}

class _TimeInputDialogState extends State<_TimeInputDialog> {
  String? _error;

  void _confirm() {
    final v = int.tryParse(widget.controller.text.trim());
    if (v == null) {
      setState(() => _error = 'Введите число');
      return;
    }
    if (v < widget.minValue || v > widget.maxValue) {
      setState(
          () => _error = 'От ${widget.minValue} до ${widget.maxValue} ${widget.unit}');
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
            Text(
              'Введите значение',
              style: AppTextStyles.subtitle.copyWith(color: AppColors.mono900),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.minValue}–${widget.maxValue} ${widget.unit}',
              style: AppTextStyles.helperText,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style:
                  AppTextStyles.fieldText.copyWith(color: AppColors.mono900),
              decoration: InputDecoration(
                suffixText: widget.unit,
                suffixStyle: AppTextStyles.fieldText
                    .copyWith(color: AppColors.mono400),
                filled: true,
                fillColor: AppColors.mono25,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
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
                  borderSide:
                      const BorderSide(color: AppColors.mono700, width: 1.5),
                ),
                errorText: _error,
                errorStyle: AppTextStyles.caption
                    .copyWith(color: AppColors.error),
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
                        child: Text(
                          'Отмена',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mono600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                        child: Text(
                          'Готово',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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

class _MonoSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _MonoSwitch({required this.value, required this.onChanged});

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

// ─── Questions list ───────────────────────────────────────────────────────────

class _QuestionsList extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int index) onEdit;

  const _QuestionsList({
    required this.questions,
    required this.onAdd,
    required this.onRemove,
    required this.onEdit,
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
    return Column(
      children: [
        if (questions.isEmpty) _EmptyQuestionsState(onAdd: onAdd),
        ...List.generate(questions.length, (i) {
          final q = questions[i];
          final type = q['type'] as String? ?? 'single_choice';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SwipeToDeleteTile(
              key: ValueKey('$i-${q['text']}'),
              onDelete: () => onRemove(i),
              child: _QuestionTile(
                index: i,
                text: q['text'] as String? ?? '',
                type: type,
                typeLabel: _typeLabel[type] ?? type,
                typeIcon: _typeIcon[type] ?? Icons.help_outline,
                onTap: () => onEdit(i),
              ),
            ),
          );
        }),
        if (questions.isNotEmpty) _AddQuestionButton(onTap: onAdd),
      ],
    );
  }
}

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
    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
      ),
      child: child,
    );
  }
}

class _EmptyQuestionsState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyQuestionsState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
                child: const Icon(Icons.quiz_outlined,
                    size: 24, color: AppColors.mono400),
              ),
              const SizedBox(height: 12),
              Text(
                'Вопросов пока нет',
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
        ),
        const SizedBox(height: 12),
        _AddQuestionButton(onTap: onAdd),
      ],
    );
  }
}

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
          border:
              Border.all(color: AppColors.mono200, style: BorderStyle.solid),
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

class _QuestionTile extends StatelessWidget {
  final int index;
  final String text;
  final String type;
  final String typeLabel;
  final IconData typeIcon;
  final VoidCallback onTap;

  const _QuestionTile({
    required this.index,
    required this.text,
    required this.type,
    required this.typeLabel,
    required this.typeIcon,
    required this.onTap,
  });

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
                  '${index + 1}',
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
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.mono900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(typeIcon, size: 12, color: AppColors.mono400),
                      const SizedBox(width: 4),
                      Text(typeLabel, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.mono300),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final CreateQuizState state;
  const _BottomBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final canSubmit = state.canSubmit && !state.isSubmitting;

    final buttonLabel = state.isInCourseContext
        ? switch (state.quizType) {
            QuizCreationMode.test => 'Создать тест',
            QuizCreationMode.live => 'Создать лайв',
            QuizCreationMode.template => 'Создать шаблон',
          }
        : 'Создать шаблон';

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!state.canSubmit && state.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                state.questions.isEmpty
                    ? 'Добавьте хотя бы один вопрос'
                    : 'Введите название',
                style: AppTextStyles.helperText,
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: AppDimens.buttonH,
            child: ElevatedButton(
              onPressed: canSubmit
                  ? () => context
                      .read<CreateQuizBloc>()
                      .add(const SubmitQuizEvent())
                  : null,
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
              child: state.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
