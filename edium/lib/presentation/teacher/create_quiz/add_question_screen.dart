import 'dart:io';
import 'dart:math';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/presentation/shared/widgets/question_image_widget.dart';
import 'package:edium/services/louvre_service/louvre_service.dart';
import 'package:edium/services/navigation_block_service/navigation_block_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

part 'add_question_screen_type_selector.dart';
part 'add_question_screen_question_text_field.dart';
part 'add_question_screen_choice_form.dart';
part 'add_question_screen_dashed_border_painter.dart';
part 'add_question_screen_option_tile.dart';
part 'add_question_screen_radio_icon.dart';
part 'add_question_screen_checkbox_icon.dart';
part 'add_question_screen_given_answer_form.dart';
part 'add_question_screen_free_answer_form.dart';
part 'add_question_screen_drag_form.dart';
part 'add_question_screen_drag_item_tile.dart';
part 'add_question_screen_connection_form.dart';
part 'add_question_screen_connection_pair_tile.dart';
part 'add_question_screen_connection_input_field.dart';
part 'add_question_screen_text_input_tile.dart';
part 'add_question_screen_error_banner.dart';
part 'add_question_screen_bottom_bar.dart';
part 'add_question_screen_option_draft.dart';
part 'add_question_screen_connection_pair.dart';
part 'add_question_screen_image_section.dart';



enum _QType {
  singleChoice,
  multipleChoice,
  withGivenAnswer,
  withFreeAnswer,
  drag,
  connection,
}

extension _QTypeX on _QType {
  String get apiValue => switch (this) {
        _QType.singleChoice => 'single_choice',
        _QType.multipleChoice => 'multiple_choice',
        _QType.withGivenAnswer => 'with_given_answer',
        _QType.withFreeAnswer => 'with_free_answer',
        _QType.drag => 'drag',
        _QType.connection => 'connection',
      };

  String get label => switch (this) {
        _QType.singleChoice => 'Один ответ',
        _QType.multipleChoice => 'Несколько',
        _QType.withGivenAnswer => 'Данный ответ',
        _QType.withFreeAnswer => 'Свободный',
        _QType.drag => 'Порядок',
        _QType.connection => 'Соответствие',
      };

  IconData get icon => switch (this) {
        _QType.singleChoice => Icons.radio_button_checked_outlined,
        _QType.multipleChoice => Icons.check_box_outlined,
        _QType.withGivenAnswer => Icons.text_fields_outlined,
        _QType.withFreeAnswer => Icons.edit_outlined,
        _QType.drag => Icons.swap_vert_outlined,
        _QType.connection => Icons.device_hub_outlined,
      };

  int get maxCharsPerField => switch (this) {
        _QType.connection => 50,
        _ => 100,
      };


  bool get allowsQuestionImage => switch (this) {
        _QType.withFreeAnswer || _QType.drag || _QType.connection => false,
        _ => true,
      };
}


class AddQuestionScreen extends StatefulWidget {
  final Map<String, dynamic>? initialQuestion;
  const AddQuestionScreen({super.key, this.initialQuestion});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  late _QType _type;
  late _QType _displayed;
  double _formOpacity = 1.0;
  bool _switching = false;

  final _textCtrl = TextEditingController();
  String? _error;
  String? _imageId;
  bool _uploadingImage = false;

  late final List<_OptionDraft> _options;
  late final List<TextEditingController> _correctAnswers;
  late final List<TextEditingController> _dragItems;
  late final List<_ConnectionPair> _pairs;

  @override
  void initState() {
    super.initState();
    getIt<NavigationBlockService>().block();
    final q = widget.initialQuestion;
    if (q == null) {
      _type = _QType.singleChoice;
      _displayed = _QType.singleChoice;
      _options = [_OptionDraft(), _OptionDraft()];
      _correctAnswers = [TextEditingController()];
      _dragItems = [TextEditingController(), TextEditingController()];
      _pairs = [_ConnectionPair(), _ConnectionPair()];
      return;
    }

    _type = _QType.values.firstWhere(
      (t) => t.apiValue == q['type'],
      orElse: () => _QType.singleChoice,
    );
    _displayed = _type;
    _textCtrl.text = q['text'] as String? ?? '';
    _imageId = _type.allowsQuestionImage ? (q['image_id'] as String?) : null;

    final rawOpts = q['answer_options'] as List? ?? [];
    _options = rawOpts.isNotEmpty
        ? rawOpts.map((o) {
            final d = _OptionDraft();
            d.ctrl.text = o['text'] as String? ?? '';
            d.isCorrect = o['is_correct'] as bool? ?? false;
            return d;
          }).toList()
        : [_OptionDraft(), _OptionDraft()];

    final answers = (q['metadata']?['correct_answers'] as List?)?.cast<String>() ?? [];
    _correctAnswers = answers.isNotEmpty
        ? answers.map((a) => TextEditingController(text: a)).toList()
        : [TextEditingController()];

    final dragOrder = (q['metadata']?['correct_order'] as List?)?.cast<String>() ?? [];
    _dragItems = dragOrder.length >= 2
        ? dragOrder.map((s) => TextEditingController(text: s)).toList()
        : [TextEditingController(), TextEditingController(), TextEditingController()];

    final left = (q['metadata']?['left'] as List?)?.cast<String>() ?? [];
    final right = (q['metadata']?['right'] as List?)?.cast<String>() ?? [];
    if (left.length >= 2) {
      _pairs = List.generate(left.length, (i) {
        final p = _ConnectionPair();
        p.leftCtrl.text = left[i];
        if (i < right.length) p.rightCtrl.text = right[i];
        return p;
      });
    } else {
      _pairs = [_ConnectionPair(), _ConnectionPair()];
    }
  }

  @override
  void dispose() {
    getIt<NavigationBlockService>().unblock();
    _textCtrl.dispose();
    for (final o in _options) { o.ctrl.dispose(); }
    for (final c in _correctAnswers) { c.dispose(); }
    for (final d in _dragItems) { d.dispose(); }
    for (final p in _pairs) {
      p.leftCtrl.dispose();
      p.rightCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _uploadingImage = true);
    try {
      final id = await getIt<LouvreService>().uploadImage(File(picked.path));
      setState(() => _imageId = id);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Не удалось загрузить изображение');
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _removeImage() => setState(() => _imageId = null);

  void _changeType(_QType t) {
    if (_type == t || _switching) return;
    setState(() {
      _type = t;
      _switching = true;
      _error = null;
      _formOpacity = 0.0;
      if (!t.allowsQuestionImage) {
        _imageId = null;
        _uploadingImage = false;
      }
    });

    Future.delayed(const Duration(milliseconds: 140), () {
      if (!mounted) return;
      setState(() {
        _displayed = t;
        if (t == _QType.singleChoice) {
          final firstCorrect = _options.indexWhere((o) => o.isCorrect);
          for (var i = 0; i < _options.length; i++) {
            _options[i].isCorrect = firstCorrect != -1 && i == firstCorrect;
          }
        }
      });

      Future.delayed(const Duration(milliseconds: 60), () {
        if (!mounted) return;
        setState(() {
          _formOpacity = 1.0;
          _switching = false;
        });
      });
    });
  }

  Map<String, dynamic>? _buildQuestion() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Введите текст вопроса');
      return null;
    }

    switch (_type) {
      case _QType.singleChoice:
      case _QType.multipleChoice:
        for (final o in _options) {
          if (o.ctrl.text.trim().isEmpty) {
            setState(() => _error = 'Заполните все варианты ответа');
            return null;
          }
        }
        final hasCorrect = _options.any((o) => o.isCorrect);
        if (!hasCorrect) {
          setState(() => _error = 'Отметьте правильный ответ');
          return null;
        }
        setState(() => _error = null);
        return {
          'type': _type.apiValue,
          'text': text,
          'max_score': 10,
          if (_imageId != null) 'image_id': _imageId,
          'answer_options': _options
              .map((o) => {'text': o.ctrl.text.trim(), 'is_correct': o.isCorrect})
              .toList(),
        };

      case _QType.withGivenAnswer:
        final answers =
            _correctAnswers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
        if (answers.isEmpty) {
          setState(() => _error = 'Введите хотя бы один правильный ответ');
          return null;
        }
        setState(() => _error = null);
        return {
          'type': _type.apiValue,
          'text': text,
          'max_score': 10,
          if (_imageId != null) 'image_id': _imageId,
          'answer_options': [],
          'metadata': {'correct_answers': answers},
        };

      case _QType.withFreeAnswer:
        setState(() => _error = null);
        return {
          'type': _type.apiValue,
          'text': text,
          'max_score': 10,
          'answer_options': [],
        };

      case _QType.drag:
        final items = _dragItems
            .map((c) => c.text.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (items.length < 2) {
          setState(() => _error = 'Введите минимум 2 элемента');
          return null;
        }
        setState(() => _error = null);
        final shuffled = List<String>.from(items)..shuffle(Random());
        return {
          'type': _type.apiValue,
          'text': text,
          'max_score': 10,
          'answer_options': [],
          'metadata': {'items': shuffled, 'correct_order': items},
        };

      case _QType.connection:
        for (final p in _pairs) {
          if (p.leftCtrl.text.trim().isEmpty || p.rightCtrl.text.trim().isEmpty) {
            setState(() => _error = 'Заполните все пары соответствия');
            return null;
          }
        }
        final left = _pairs.map((p) => p.leftCtrl.text.trim()).toList();
        final right = _pairs.map((p) => p.rightCtrl.text.trim()).toList();
        final pairsMap = <String, String>{};
        for (var i = 0; i < _pairs.length; i++) {
          pairsMap[left[i]] = right[i];
        }
        setState(() => _error = null);
        return {
          'type': _type.apiValue,
          'text': text,
          'max_score': 10,
          'answer_options': [],
          'metadata': {'left': left, 'right': right, 'correct_pairs': pairsMap},
        };
    }
  }

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
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.initialQuestion != null ? 'Редактировать вопрос' : 'Добавить вопрос',
          style: AppTextStyles.screenTitle,
        ),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _TypeSelector(selected: _type, onSelect: _changeType),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _QuestionTextField(controller: _textCtrl),
                          if (_type.allowsQuestionImage) ...[
                            const SizedBox(height: 16),
                            _ImageSection(
                              imageId: _imageId,
                              uploading: _uploadingImage,
                              onPick: _pickImage,
                              onRemove: _removeImage,
                            ),
                          ],
                          const SizedBox(height: 24),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topCenter,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 140),
                              opacity: _formOpacity,
                              child: _buildFormForType(),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            _ErrorBanner(message: _error!),
                          ],
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomBar(
              onSave: () {
                FocusScope.of(context).unfocus();
                final q = _buildQuestion();
                if (q != null) {
                  final ctx = context;
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (ctx.mounted) Navigator.pop(ctx, q);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormForType() {
    return switch (_displayed) {
      _QType.singleChoice => _ChoiceForm(
          options: _options,
          isMulti: false,
          maxChars: _type.maxCharsPerField,
          onChanged: () => setState(() {}),
        ),
      _QType.multipleChoice => _ChoiceForm(
          options: _options,
          isMulti: true,
          maxChars: _type.maxCharsPerField,
          onChanged: () => setState(() {}),
        ),
      _QType.withGivenAnswer => _GivenAnswerForm(
          answers: _correctAnswers,
          maxChars: _type.maxCharsPerField,
          onChanged: () => setState(() {}),
        ),
      _QType.withFreeAnswer => const _FreeAnswerForm(),
      _QType.drag => _DragForm(
          items: _dragItems,
          maxChars: _type.maxCharsPerField,
          onChanged: () => setState(() {}),
        ),
      _QType.connection => _ConnectionForm(
          pairs: _pairs,
          maxChars: _type.maxCharsPerField,
          onChanged: () => setState(() {}),
        ),
    };
  }
}


Widget _entryAnimation({required Key key, required Widget child}) {
  return TweenAnimationBuilder<double>(
    key: key,
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 280),
    curve: Curves.easeOutCubic,
    builder: (_, v, c) => Opacity(
      opacity: v,
      child: Transform.translate(offset: Offset(0, (1 - v) * 10), child: c),
    ),
    child: child,
  );
}


Widget _buildDismissible({
  required Key key,
  required bool canDismiss,
  required VoidCallback onDismissed,
  required Widget child,
}) {
  if (!canDismiss) {
    return child;
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(

      color: AppColors.error,
      child: Dismissible(
        key: key,
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed(),
        background: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
        ),
        child: child,
      ),
    ),
  );
}

