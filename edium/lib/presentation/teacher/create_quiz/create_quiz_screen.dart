import 'dart:math' as math;

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/services/navigation_block_service/navigation_block_service.dart';
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

part 'create_quiz_screen_ai_generate_sheet.dart';
part 'create_quiz_screen_rainbow_border_button.dart';
part 'create_quiz_screen_rainbow_border_painter.dart';
part 'create_quiz_screen_ai_generate_button.dart';
part 'create_quiz_screen_section_label.dart';
part 'create_quiz_screen_quiz_type_selector.dart';
part 'create_quiz_screen_type_pill_data.dart';
part 'create_quiz_screen_title_field.dart';
part 'create_quiz_screen_description_field.dart';
part 'create_quiz_screen_settings_card.dart';
part 'create_quiz_screen_card_divider.dart';
part 'create_quiz_screen_shuffle_row.dart';
part 'create_quiz_screen_date_time_row.dart';
part 'create_quiz_screen_edium_date_time_picker.dart';
part 'create_quiz_screen_time_scroll_wheel.dart';
part 'create_quiz_screen_time_row.dart';
part 'create_quiz_screen_time_input_dialog.dart';
part 'create_quiz_screen_mono_switch.dart';
part 'create_quiz_screen_questions_list.dart';
part 'create_quiz_screen_swipe_to_delete_tile.dart';
part 'create_quiz_screen_empty_questions_state.dart';
part 'create_quiz_screen_add_question_button.dart';
part 'create_quiz_screen_question_tile.dart';
part 'create_quiz_screen_bottom_bar.dart';
part 'create_quiz_screen_library_button.dart';
part 'create_quiz_screen_course_context_buttons.dart';


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
  final _aiTextCtrl = TextEditingController();
  var _syncedControllersFromBloc = false;
  var _excludeFocus = false;

  @override
  void initState() {
    super.initState();
    getIt<NavigationBlockService>().block();
  }

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
    getIt<NavigationBlockService>().unblock();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _aiTextCtrl.dispose();
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
    final state = context.read<CreateQuizBloc>().state;
    if (state.isInCourseContext && state.quizType == QuizCreationMode.live) {
      final hasFreeAnswer = state.questions
          .any((q) => q['type'] == 'with_free_answer');
      if (hasFreeAnswer) {
        EdiumNotification.show(
          context,
          'Лайв недоступен: есть вопросы со свободным ответом',
          type: EdiumNotificationType.error,
        );
        return;
      }
    }
    final moduleId = await _pickModule();
    if (!mounted) return;
    context.read<CreateQuizBloc>().add(
          SubmitQuizEvent(moduleId: moduleId, courseId: widget.courseId),
        );
  }

  Future<void> _openAIGenerateSheet() async {
    final title = context.read<CreateQuizBloc>().state.title;
    if (title.trim().isEmpty) {
      EdiumNotification.show(
        context,
        'Введите название перед генерацией',
        type: EdiumNotificationType.error,
      );
      return;
    }
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
              textController: _aiTextCtrl,
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
    final bloc = context.read<CreateQuizBloc>();
    FocusScope.of(context).unfocus();
    setState(() => _excludeFocus = true);
    final q = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddQuestionScreen()),
    );
    if (!mounted) return;
    setState(() => _excludeFocus = false);
    if (q != null) {
      bloc.add(AddQuestionEvent(q));
    }
  }

  Future<void> _openEditQuestion(
    BuildContext context,
    int index,
    Map<String, dynamic> existing,
  ) async {
    final bloc = context.read<CreateQuizBloc>();
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
      bloc.add(ReplaceQuestionEvent(index, q));
    }
  }
}

