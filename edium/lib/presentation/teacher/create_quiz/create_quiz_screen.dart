import 'dart:math' as math;

import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/teacher/create_quiz/add_question_screen.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_event.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CreateQuizScreen extends StatefulWidget {
  final List<ModuleDetail>? modules;
  final String? preselectedModuleId;
  final String? courseId;

  const CreateQuizScreen({
    super.key,
    this.modules,
    this.preselectedModuleId,
    this.courseId,
  });

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  var _syncedControllersFromBloc = false;
  var _excludeFocus = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_syncedControllersFromBloc) return;
    _syncedControllersFromBloc = true;
    final s = context.read<CreateQuizBloc>().state;
    _titleCtrl.text = s.title;
    _descCtrl.text = s.description;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<String?> _pickModule() async {
    if (widget.preselectedModuleId != null) return widget.preselectedModuleId;
    final modules = widget.modules;
    if (modules == null) return null;
    if (modules.isEmpty) return null;
    if (modules.length == 1) return modules.first.id;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.45,
          minChildSize: 0.3,
          maxChildSize: 0.7,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.mono150,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Выберите модуль',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mono900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.screenPaddingH,
                      vertical: 4,
                    ),
                    itemCount: modules.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final mod = modules[i];
                      return GestureDetector(
                        onTap: () => Navigator.of(sheetCtx).pop(mod.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusMd),
                            border: Border.all(
                              color: AppColors.mono150,
                              width: AppDimens.borderWidth,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.folder_outlined,
                                  size: 20, color: AppColors.mono400),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  mod.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.mono900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  size: 20, color: AppColors.mono300),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _onSavePressed() async {
    if (!mounted) return;
    context.read<CreateQuizBloc>().add(
          SubmitQuizEvent(saveOnly: true, courseId: widget.courseId),
        );
  }

  Future<void> _onStartPressed() async {
    final moduleId = await _pickModule();
    if (!mounted) return;
    context.read<CreateQuizBloc>().add(
          SubmitQuizEvent(moduleId: moduleId, courseId: widget.courseId),
        );
  }

  Future<void> _openAIGenerateSheet() async {
    FocusScope.of(context).unfocus();
    setState(() => _excludeFocus = true);
    final hostContext = context;
    final bloc = context.read<CreateQuizBloc>();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return BlocListener<CreateQuizBloc, CreateQuizState>(
          bloc: bloc,
          listenWhen: (prev, curr) =>
              curr.aiGenerateAckVersion > prev.aiGenerateAckVersion,
          listener: (_, __) {
            Navigator.pop(sheetCtx);
            EdiumNotification.show(
              hostContext,
              'Мы пришлём вам уведомление, когда вопросы будут готовы.',
            );
          },
          child: BlocBuilder<CreateQuizBloc, CreateQuizState>(
            bloc: bloc,
            buildWhen: (p, c) => p.isAiGenerating != c.isAiGenerating,
            builder: (ctx, s) => _AIGenerateSheet(
              isGenerating: s.isAiGenerating,
              onGenerate: (text) {
                bloc.add(
                  GenerateQuizQuestionsWithAiEvent(
                    text,
                    courseId: widget.courseId,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
    if (mounted) setState(() => _excludeFocus = false);
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
          Navigator.pop(context, state);
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
        return ExcludeFocus(
          excluding: _excludeFocus,
          child: Scaffold(
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
                          _QuizTypeSelector(
                            quizType: state.quizType,
                            isInCourseContext: state.isInCourseContext,
                          ),
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
                          onEdit: (i) => _openEditQuestion(
                              context, i, state.questions[i]),
                          onAIGenerate: _openAIGenerateSheet,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                _BottomBar(
                  state: state,
                  onSave: _onSavePressed,
                  onStart: _onStartPressed,
                ),
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, CreateQuizState state) {
    final title = state.isInCourseContext
        ? (state.quizType == QuizCreationMode.live
            ? 'Новый лайв'
            : 'Новый тест')
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
    FocusScope.of(context).unfocus();
    setState(() => _excludeFocus = true);
    final q = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddQuestionScreen()),
    );
    if (!mounted) return;
    setState(() => _excludeFocus = false);
    if (q != null) {
      context.read<CreateQuizBloc>().add(AddQuestionEvent(q));
    }
  }

  Future<void> _openEditQuestion(
    BuildContext context,
    int index,
    Map<String, dynamic> existing,
  ) async {
    FocusScope.of(context).unfocus();
    setState(() => _excludeFocus = true);
    final q = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddQuestionScreen(initialQuestion: existing),
      ),
    );
    if (!mounted) return;
    setState(() => _excludeFocus = false);
    if (q != null) {
      context.read<CreateQuizBloc>().add(ReplaceQuestionEvent(index, q));
    }
  }
}

// ─── AI Generate Sheet ────────────────────────────────────────────────────────

class _AIGenerateSheet extends StatefulWidget {
  final ValueChanged<String> onGenerate;
  final bool isGenerating;

  const _AIGenerateSheet({
    required this.onGenerate,
    required this.isGenerating,
  });

  @override
  State<_AIGenerateSheet> createState() => _AIGenerateSheetState();
}

class _AIGenerateSheetState extends State<_AIGenerateSheet> {
  final _textCtrl = TextEditingController();
  final _fieldFocus = FocusNode();
  static const _maxLength = 4000;
  static const _minGenerateLength = 500;

  @override
  void initState() {
    super.initState();
    _fieldFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fieldFocus.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mono150,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8B5CF6),
                          Color(0xFFEC4899),
                          Color(0xFFF59E0B),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Сгенерировать вопросы',
                          style: AppTextStyles.subtitle
                              .copyWith(color: AppColors.mono900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Вставьте текст – Edium AI создаст вопросы',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.mono400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: AppColors.mono25,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _fieldFocus.hasFocus
                        ? AppColors.mono900
                        : AppColors.mono150,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Column(
                    children: [
                      TextField(
                        controller: _textCtrl,
                        focusNode: _fieldFocus,
                        maxLength: _maxLength,
                        maxLines: 8,
                        minLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        style: AppTextStyles.fieldText
                            .copyWith(color: AppColors.mono700),
                        decoration: InputDecoration(
                          hintText:
                              'Вставьте текст лекции, главы учебника или любой материал...',
                          hintStyle: AppTextStyles.fieldHint,
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                          counterText: '',
                        ),
                        cursorColor: AppColors.mono900,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 14, right: 14, bottom: 10),
                        child: Row(
                          children: [
                            ListenableBuilder(
                              listenable: _textCtrl,
                              builder: (_, __) {
                                final len = _textCtrl.text.length;
                                if (len > 0 && len < _minGenerateLength) {
                                  return Text(
                                    'Минимум $_minGenerateLength символов',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.mono400,
                                      fontSize: 11,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const Spacer(),
                            ListenableBuilder(
                              listenable: _textCtrl,
                              builder: (_, __) => Text(
                                '${_textCtrl.text.length}/$_maxLength',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.mono300, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: _textCtrl,
                builder: (_, __) {
                  final hasEnoughText =
                      _textCtrl.text.trim().length >= _minGenerateLength;
                  final canTap = hasEnoughText && !widget.isGenerating;
                  return SizedBox(
                    width: double.infinity,
                    height: AppDimens.buttonH,
                    child: _RainbowBorderButton(
                      enabled: canTap,
                      isBusy: widget.isGenerating,
                      onTap: canTap
                          ? () {
                              _fieldFocus.unfocus();
                              widget.onGenerate(_textCtrl.text.trim());
                            }
                          : null,
                      child: widget.isGenerating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Сгенерировать',
                                  style: AppTextStyles.primaryButton.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Rainbow border button with animated shimmer ──────────────────────────────

class _RainbowBorderButton extends StatefulWidget {
  final bool enabled;
  final bool isBusy;
  final VoidCallback? onTap;
  final Widget child;

  const _RainbowBorderButton({
    required this.enabled,
    this.isBusy = false,
    required this.onTap,
    required this.child,
  });

  @override
  State<_RainbowBorderButton> createState() => _RainbowBorderButtonState();
}

class _RainbowBorderButtonState extends State<_RainbowBorderButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: (!widget.enabled && !widget.isBusy) ? 0.5 : 1.0,
            child: CustomPaint(
              painter: _RainbowBorderPainter(
                progress: _ctrl.value,
                borderRadius: 14,
                borderWidth: 2.5,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.mono900,
                  borderRadius: BorderRadius.circular(11.5),
                ),
                margin: const EdgeInsets.all(2.5),
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _RainbowBorderPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final double borderWidth;

  _RainbowBorderPainter({
    required this.progress,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Stroke is centered on the path; inset so the full stroke stays inside [size]
    // and matches neighbors that use in-box borders (e.g. «Добавить вопрос»).
    final inset = borderWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - borderWidth,
      size.height - borderWidth,
    );
    final r = borderRadius <= inset ? 0.0 : borderRadius - inset;
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(r),
    );

    final colors = [
      const Color(0xFFFF0000),
      const Color(0xFFFF8000),
      const Color(0xFFFFFF00),
      const Color(0xFF00FF00),
      const Color(0xFF00FFFF),
      const Color(0xFF0080FF),
      const Color(0xFF8000FF),
      const Color(0xFFFF00FF),
      const Color(0xFFFF0000),
    ];

    final sweepGradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: colors,
      transform: GradientRotation(progress * math.pi * 2),
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_RainbowBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─── AI Generate small button (rainbow animated border) ───────────────────────

class _AIGenerateButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AIGenerateButton({required this.onTap});

  @override
  State<_AIGenerateButton> createState() => _AIGenerateButtonState();
}

class _AIGenerateButtonState extends State<_AIGenerateButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return CustomPaint(
            painter: _RainbowBorderPainter(
              progress: _ctrl.value,
              borderRadius: 11,
              borderWidth: 1.5,
            ),
            child: Container(
              margin: const EdgeInsets.all(1.5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return SweepGradient(
                        colors: const [
                          Color(0xFF8B5CF6),
                          Color(0xFFEC4899),
                          Color(0xFFF59E0B),
                          Color(0xFF10B981),
                          Color(0xFF3B82F6),
                          Color(0xFF8B5CF6),
                        ],
                        transform:
                            GradientRotation(_ctrl.value * math.pi * 2),
                      ).createShader(bounds);
                    },
                    child: const Icon(Icons.auto_awesome,
                        size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AI',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mono900,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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

// ─── Quiz type selector with animated sliding indicator ───────────────────────

class _QuizTypeSelector extends StatefulWidget {
  final QuizCreationMode quizType;
  final bool isInCourseContext;
  const _QuizTypeSelector({
    required this.quizType,
    required this.isInCourseContext,
  });

  @override
  State<_QuizTypeSelector> createState() => _QuizTypeSelectorState();
}

class _QuizTypeSelectorState extends State<_QuizTypeSelector> {
  List<_TypePillData> get _items {
    final list = <_TypePillData>[];
    if (!widget.isInCourseContext) {
      list.add(_TypePillData(
        label: 'Шаблон',
        icon: Icons.bookmark_border_outlined,
        mode: QuizCreationMode.template,
      ));
    }
    list.add(_TypePillData(
      label: 'Тест',
      icon: Icons.timer_outlined,
      mode: QuizCreationMode.test,
    ));
    list.add(_TypePillData(
      label: 'Лайв',
      icon: Icons.bolt_outlined,
      mode: QuizCreationMode.live,
    ));
    return list;
  }

  int get _activeIndex {
    final items = _items;
    for (var i = 0; i < items.length; i++) {
      if (items[i].mode == widget.quizType) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final count = items.length;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono100),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / count;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: _activeIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.mono900,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mono900.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(count, (i) {
                  final item = items[i];
                  final isActive = i == _activeIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => context
                          .read<CreateQuizBloc>()
                          .add(SetQuizTypeEvent(item.mode)),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                fontSize: 0,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.mono400,
                              ),
                              child: Icon(
                                item.icon,
                                size: 18,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.mono400,
                              ),
                            ),
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.mono400,
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TypePillData {
  final String label;
  final IconData icon;
  final QuizCreationMode mode;
  const _TypePillData({
    required this.label,
    required this.icon,
    required this.mode,
  });
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

// ─── Settings card (mode-aware) with animated transitions ─────────────────────

class _SettingsCard extends StatelessWidget {
  final CreateQuizState state;
  const _SettingsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final showTotalTime = !state.isInCourseContext ||
        state.quizType == QuizCreationMode.template ||
        state.quizType == QuizCreationMode.test;
    final showQuestionTime = !state.isInCourseContext ||
        state.quizType == QuizCreationMode.template ||
        state.quizType == QuizCreationMode.live;
    final showShuffle =
        state.isInCourseContext && state.quizType == QuizCreationMode.test;
    final showDates =
        state.isInCourseContext && state.quizType == QuizCreationMode.test;

    final rows = <Widget>[];

    if (showTotalTime) {
      rows.add(_TimeRow(
        key: const ValueKey('totalTime'),
        label: 'Время на весь квиз',
        subtitle:
            !state.isInCourseContext ? 'Используется в режиме «Тест»' : null,
        valueSec: state.totalTimeLimitSec,
        unit: 'мин',
        unitDivisor: 60,
        sliderMinUnits: 5,
        sliderMaxUnits: 90,
        sliderStep: 5,
        defaultValueSec: 1200,
        onToggle: (on) => context
            .read<CreateQuizBloc>()
            .add(UpdateTotalTimeLimitEvent(on ? 1200 : null)),
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
        key: const ValueKey('questionTime'),
        label: 'Время на вопрос',
        subtitle:
            !state.isInCourseContext ? 'Используется в режиме «Лайв»' : null,
        valueSec: state.questionTimeLimitSec,
        unit: 'сек',
        unitDivisor: 1,
        sliderMinUnits: 5,
        sliderMaxUnits: 90,
        sliderStep: 5,
        defaultValueSec: 30,
        onToggle: (on) => context
            .read<CreateQuizBloc>()
            .add(UpdateQuestionTimeLimitEvent(on ? 30 : null)),
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

    if (showDates) {
      if (rows.isNotEmpty) rows.add(_CardDivider());
      rows.add(_DateTimeRow(
        key: const ValueKey('startedAt'),
        label: 'Открыть с',
        value: state.startedAt,
        onToggle: (on) => context.read<CreateQuizBloc>().add(
              UpdateStartedAtEvent(on ? DateTime.now() : null),
            ),
        onPick: (dt) =>
            context.read<CreateQuizBloc>().add(UpdateStartedAtEvent(dt)),
      ));
      rows.add(_CardDivider());
      rows.add(_DateTimeRow(
        key: const ValueKey('finishedAt'),
        label: 'Дедлайн',
        value: state.finishedAt,
        onToggle: (on) => context.read<CreateQuizBloc>().add(
              UpdateFinishedAtEvent(
                  on ? DateTime.now().add(const Duration(days: 7)) : null),
            ),
        onPick: (dt) =>
            context.read<CreateQuizBloc>().add(UpdateFinishedAtEvent(dt)),
      ));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: Container(
        key: ValueKey('settings_${state.quizType}_$showDates'),
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
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.mono700),
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

// ─── Custom DateTime picker (cross-platform) ─────────────────────────────────

class _DateTimeRow extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<bool> onToggle;
  final ValueChanged<DateTime> onPick;

  const _DateTimeRow({
    super.key,
    required this.label,
    required this.value,
    required this.onToggle,
    required this.onPick,
  });

  static final _dateFmt = DateFormat('d MMM, HH:mm', 'ru');

  Future<void> _pick(BuildContext context) async {
    final initial = value ?? DateTime.now();
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EdiumDateTimePicker(initial: initial),
    );
    if (result != null && context.mounted) {
      onPick(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.mono700),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: value != null ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: value == null,
              child: GestureDetector(
                onTap: () => _pick(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mono100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value != null ? _dateFmt.format(value!) : '—',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mono900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _MonoSwitch(value: value != null, onChanged: onToggle),
        ],
      ),
    );
  }
}

// ─── Custom cross-platform date-time picker ───────────────────────────────────

class _EdiumDateTimePicker extends StatefulWidget {
  final DateTime initial;

  const _EdiumDateTimePicker({required this.initial});

  @override
  State<_EdiumDateTimePicker> createState() => _EdiumDateTimePickerState();
}

class _EdiumDateTimePickerState extends State<_EdiumDateTimePicker> {
  late DateTime _selectedDate;
  late int _selectedHour;
  late int _selectedMinute;
  late int _displayedMonth;
  late int _displayedYear;

  static const _monthNames = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];

  static const _weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
        widget.initial.year, widget.initial.month, widget.initial.day);
    _selectedHour = widget.initial.hour;
    _selectedMinute = widget.initial.minute;
    _displayedMonth = widget.initial.month;
    _displayedYear = widget.initial.year;
  }

  void _prevMonth() {
    setState(() {
      if (_displayedMonth == 1) {
        _displayedMonth = 12;
        _displayedYear--;
      } else {
        _displayedMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_displayedMonth == 12) {
        _displayedMonth = 1;
        _displayedYear++;
      } else {
        _displayedMonth++;
      }
    });
  }

  List<DateTime?> _buildCalendarGrid() {
    final firstDay = DateTime(_displayedYear, _displayedMonth, 1);
    final daysInMonth =
        DateTime(_displayedYear, _displayedMonth + 1, 0).day;
    // Monday = 1
    final startWeekday = firstDay.weekday; // 1=Mon ... 7=Sun
    final leadingBlanks = startWeekday - 1;

    final List<DateTime?> cells = [];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_displayedYear, _displayedMonth, d));
    }
    // Pad to complete last row
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  void _confirm() {
    final result = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedHour,
      _selectedMinute,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final cells = _buildCalendarGrid();
    final today = DateTime.now();
    final canGoPrev = _displayedYear > today.year ||
        (_displayedYear == today.year && _displayedMonth > today.month);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mono150,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: canGoPrev ? _prevMonth : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.mono50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color:
                          canGoPrev ? AppColors.mono700 : AppColors.mono200,
                    ),
                  ),
                ),
                Text(
                  '${_monthNames[_displayedMonth - 1]} $_displayedYear',
                  style: AppTextStyles.subtitle
                      .copyWith(color: AppColors.mono900),
                ),
                GestureDetector(
                  onTap: _nextMonth,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.mono50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chevron_right,
                        size: 20, color: AppColors.mono700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekday headers
            Row(
              children: _weekDays
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mono400,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Calendar grid
            ...List.generate(cells.length ~/ 7, (row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: List.generate(7, (col) {
                    final cell = cells[row * 7 + col];
                    if (cell == null) {
                      return const Expanded(child: SizedBox(height: 40));
                    }

                    final isSelected = _isSameDay(cell, _selectedDate);
                    final isCurrentDay = _isToday(cell);
                    final isPast = cell.isBefore(
                        DateTime(today.year, today.month, today.day));

                    return Expanded(
                      child: GestureDetector(
                        onTap: isPast
                            ? null
                            : () => setState(() => _selectedDate = cell),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.mono900
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${cell.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected || isCurrentDay
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : isPast
                                        ? AppColors.mono200
                                        : isCurrentDay
                                            ? AppColors.mono900
                                            : AppColors.mono700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Time picker
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.mono50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.mono100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_outlined,
                      size: 18, color: AppColors.mono400),
                  const SizedBox(width: 10),
                  Text(
                    'Время',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.mono700),
                  ),
                  const Spacer(),
                  // Hour
                  _TimeScrollWheel(
                    value: _selectedHour,
                    maxValue: 23,
                    onChanged: (v) => setState(() => _selectedHour = v),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      ':',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.mono900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Minute
                  _TimeScrollWheel(
                    value: _selectedMinute,
                    maxValue: 59,
                    step: 5,
                    onChanged: (v) => setState(() => _selectedMinute = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: AppDimens.buttonH,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mono900,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                  textStyle: AppTextStyles.primaryButton,
                ),
                child: Text(
                  'Готово — ${_selectedDate.day} ${_monthNames[_selectedDate.month - 1].toLowerCase()}, '
                  '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small time scroll wheel ──────────────────────────────────────────────────

class _TimeScrollWheel extends StatefulWidget {
  final int value;
  final int maxValue;
  final int step;
  final ValueChanged<int> onChanged;

  const _TimeScrollWheel({
    required this.value,
    required this.maxValue,
    this.step = 1,
    required this.onChanged,
  });

  @override
  State<_TimeScrollWheel> createState() => _TimeScrollWheelState();
}

class _TimeScrollWheelState extends State<_TimeScrollWheel> {
  late final FixedExtentScrollController _scrollCtrl;

  List<int> get _values {
    final list = <int>[];
    for (var i = 0; i <= widget.maxValue; i += widget.step) {
      list.add(i);
    }
    return list;
  }

  int _indexOfValue(int val) {
    final vals = _values;
    for (var i = 0; i < vals.length; i++) {
      if (vals[i] >= val) return i;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _scrollCtrl =
        FixedExtentScrollController(initialItem: _indexOfValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant _TimeScrollWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final idx = _indexOfValue(widget.value);
      if (_scrollCtrl.selectedItem != idx) {
        _scrollCtrl.animateToItem(
          idx,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vals = _values;
    const itemH = 36.0;
    const visibleItems = 3;
    const wheelH = itemH * visibleItems;

    return SizedBox(
      width: 52,
      height: wheelH,
      child: Stack(
        children: [
          // Center selection highlight
          Positioned(
            top: itemH,
            left: 0,
            right: 0,
            height: itemH,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.mono100,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _scrollCtrl,
            itemExtent: itemH,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 8,
            perspective: 0.001,
            onSelectedItemChanged: (i) => widget.onChanged(vals[i]),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: vals.length,
              builder: (context, index) {
                final isSelected = vals[index] == widget.value;
                return Center(
                  child: Text(
                    vals[index].toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.mono900
                          : AppColors.mono400,
                    ),
                  ),
                );
              },
            ),
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
    super.key,
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
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: valueSec != null ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: valueSec == null,
                      child: GestureDetector(
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  _MonoSwitch(
                      value: valueSec != null, onChanged: onToggle),
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
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, bottom: 12),
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.mono900,
                      inactiveTrackColor: AppColors.mono150,
                      thumbColor: AppColors.mono900,
                      overlayColor:
                          AppColors.mono900.withValues(alpha: 0.08),
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: _currentUnits.toDouble().clamp(
                          sliderMinUnits.toDouble(),
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
      setState(() =>
          _error = 'От ${widget.minValue} до ${widget.maxValue} ${widget.unit}');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Введите значение',
              style:
                  AppTextStyles.subtitle.copyWith(color: AppColors.mono900),
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
              style: AppTextStyles.fieldText
                  .copyWith(color: AppColors.mono900),
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
                  borderSide: const BorderSide(
                      color: AppColors.mono700, width: 1.5),
                ),
                errorText: _error,
                errorStyle:
                    AppTextStyles.caption.copyWith(color: AppColors.error),
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
          alignment:
              value ? Alignment.centerRight : Alignment.centerLeft,
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
  final VoidCallback onAIGenerate;

  const _QuestionsList({
    required this.questions,
    required this.onAdd,
    required this.onRemove,
    required this.onEdit,
    required this.onAIGenerate,
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

  /// Row внутри scroll получает бесконечную maxHeight — без явной высоты строка схлопывается.
  static const double _questionsActionRowHeight = 48;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _questionsActionRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _AddQuestionButton(onTap: onAdd)),
              const SizedBox(width: 10),
              SizedBox(
                width: 76,
                child: _AIGenerateButton(onTap: onAIGenerate),
              ),
            ],
          ),
        ),
        if (questions.isEmpty) ...[
          const SizedBox(height: 12),
          _EmptyQuestionsState(),
        ],
        if (questions.isNotEmpty) ...[
          const SizedBox(height: 12),
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
        ],
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: AppColors.error,
        child: Dismissible(
          key: key!,
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(),
          background: Container(
            color: AppColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete_outline,
                color: Colors.white, size: 20),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _EmptyQuestionsState extends StatelessWidget {
  const _EmptyQuestionsState();

  @override
  Widget build(BuildContext context) {
    return Container(
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
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.mono200, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      Icon(typeIcon,
                          size: 12, color: AppColors.mono400),
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
  final Future<void> Function() onSave;
  final Future<void> Function() onStart;

  const _BottomBar({
    required this.state,
    required this.onSave,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final canSubmit = state.canSubmit && !state.isSubmitting;

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
          if (state.isInCourseContext)
            _CourseContextButtons(
              canSubmit: canSubmit,
              isSubmitting: state.isSubmitting,
              onSave: onSave,
              onStart: onStart,
            )
          else
            _LibraryButton(
              canSubmit: canSubmit,
              isSubmitting: state.isSubmitting,
              onPressed: onSave,
            ),
        ],
      ),
    );
  }
}

class _LibraryButton extends StatelessWidget {
  final bool canSubmit;
  final bool isSubmitting;
  final Future<void> Function() onPressed;

  const _LibraryButton({
    required this.canSubmit,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonH,
      child: ElevatedButton(
        onPressed: canSubmit ? onPressed : null,
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
        child: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Создать шаблон'),
      ),
    );
  }
}

class _CourseContextButtons extends StatelessWidget {
  final bool canSubmit;
  final bool isSubmitting;
  final Future<void> Function() onSave;
  final Future<void> Function() onStart;

  const _CourseContextButtons({
    required this.canSubmit,
    required this.isSubmitting,
    required this.onSave,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppDimens.buttonH,
            child: OutlinedButton(
              onPressed: canSubmit ? onSave : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mono900,
                disabledForegroundColor: AppColors.mono300,
                side: BorderSide(
                  color:
                      canSubmit ? AppColors.mono300 : AppColors.mono150,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusLg),
                ),
                textStyle: AppTextStyles.primaryButton,
              ),
              child: const Text('Сохранить'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: AppDimens.buttonH,
            child: ElevatedButton(
              onPressed: canSubmit ? onStart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mono900,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.mono200,
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusLg),
                ),
                textStyle: AppTextStyles.primaryButton,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Начать'),
            ),
          ),
        ),
      ],
    );
  }
}
