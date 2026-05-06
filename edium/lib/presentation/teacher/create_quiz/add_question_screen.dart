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

// ─── Question types ───────────────────────────────────────────────────────────

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
        _QType.connection => 50, // Для соответствия - 50 символов
        _ => 100, // Для всех остальных типов - 100 символов
      };

  /// Картинка к тексту вопроса — только для вариантов с выбором / данным ответом.
  bool get allowsQuestionImage => switch (this) {
        _QType.withFreeAnswer || _QType.drag || _QType.connection => false,
        _ => true,
      };
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AddQuestionScreen extends StatefulWidget {
  final Map<String, dynamic>? initialQuestion;
  const AddQuestionScreen({super.key, this.initialQuestion});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  late _QType _type;
  late _QType _displayed; // the type whose form is actually rendered
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
    // Phase 1 done → swap form while invisible so AnimatedSize animates the height change
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
      // Phase 2: let layout settle one frame, then fade in
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

// ─── Shared helpers ───────────────────────────────────────────────────────────

// Widget _entryAnimation({required Key key, required Widget child}) {
//   return TweenAnimationBuilder<double>(
//     key: key,
//     tween: Tween(begin: 0.0, end: 1.0),
//     duration: const Duration(milliseconds: 280),
//     curve: Curves.easeOutCubic,
//     builder: (_, v, c) => Opacity(
//       opacity: v,
//       child: Transform.translate(offset: Offset(0, (1 - v) * 10), child: c),
//     ),
//     child: child,
//   );
// }

// Widget _dismissBackground() => Container(
//       alignment: Alignment.centerRight,
//       padding: const EdgeInsets.only(right: 20),
//       decoration: BoxDecoration(
//         color: AppColors.error,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
//     );

// ─── Shared helpers ───────────────────────────────────────────────────────────

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

/// Обёртка для Dismissible с правильной обрезкой
/// Обёртка для Dismissible без белых зазоров
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
      // Этот цвет будет виден в зазоре между child и background
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

// ─── Type selector ────────────────────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final _QType selected;
  final ValueChanged<_QType> onSelect;

  const _TypeSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: _QType.values.map((t) {
          final isSelected = t == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.mono900 : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.mono900 : AppColors.mono200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.icon,
                        size: 13,
                        color: isSelected ? Colors.white : AppColors.mono400),
                    const SizedBox(width: 5),
                    Text(
                      t.label,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? Colors.white : AppColors.mono600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Question text field ──────────────────────────────────────────────────────

class _QuestionTextField extends StatefulWidget {
  final TextEditingController controller;
  const _QuestionTextField({required this.controller});

  @override
  State<_QuestionTextField> createState() => _QuestionTextFieldState();
}

class _QuestionTextFieldState extends State<_QuestionTextField> {
  static const _maxLength = 300;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ТЕКСТ ВОПРОСА', style: AppTextStyles.sectionTag),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          textCapitalization: TextCapitalization.sentences,
          style: AppTextStyles.subtitle.copyWith(color: AppColors.mono900),
          decoration: InputDecoration(
            hintText: 'Введите вопрос...',
            hintStyle: AppTextStyles.subtitle.copyWith(
              color: AppColors.mono300,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            counterText: '',
          ),
          cursorColor: AppColors.mono900,
          minLines: 1,
          maxLines: null,
          maxLength: _maxLength,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.mono100)),
            const SizedBox(width: 8),
            ListenableBuilder(
              listenable: widget.controller,
              builder: (_, __) => Text(
                '${widget.controller.text.length}/$_maxLength',
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

// ─── Choice form ──────────────────────────────────────────────────────────────

class _ChoiceForm extends StatefulWidget {
  final List<_OptionDraft> options;
  final bool isMulti;
  final int maxChars;
  final VoidCallback onChanged;

  const _ChoiceForm({
    required this.options,
    required this.isMulti,
    required this.onChanged,
    required this.maxChars,
  });

  @override
  State<_ChoiceForm> createState() => _ChoiceFormState();
}

class _ChoiceFormState extends State<_ChoiceForm> {
  void _toggleCorrect(int i) {
    setState(() {
      if (!widget.isMulti) {
        for (var j = 0; j < widget.options.length; j++) {
          widget.options[j].isCorrect = j == i;
        }
      } else {
        widget.options[i].isCorrect = !widget.options[i].isCorrect;
      }
    });
    widget.onChanged();
  }

  void _addOption() {
    if (widget.options.length >= 6) return;
    setState(() => widget.options.add(_OptionDraft()));
    widget.onChanged();
  }

  void _removeOption(int i) {
    if (widget.options.length <= 2) return;
    setState(() {
      widget.options[i].ctrl.dispose();
      widget.options.removeAt(i);
    });
    widget.onChanged();
  }

  Widget _buildAddOptionButton() {
    final canAdd = widget.options.length < 6;
    return _dashedAddRowButton(
      label: '+ Добавить вариант',
      onTap: canAdd ? _addOption : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ВАРИАНТЫ ОТВЕТА', style: AppTextStyles.sectionTag),
            GestureDetector(
              onTap: widget.options.length < 6 ? _addOption : null,
              child: Row(
                children: [
                  Icon(Icons.add,
                      size: 14,
                      color: widget.options.length < 6
                          ? AppColors.mono700
                          : AppColors.mono300),
                  const SizedBox(width: 2),
                  Text(
                    'Добавить',
                    style: AppTextStyles.caption.copyWith(
                      color: widget.options.length < 6
                          ? AppColors.mono700
                          : AppColors.mono300,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
          ...List.generate(widget.options.length, (i) {
            final opt = widget.options[i];
            return _entryAnimation(
              key: ValueKey(opt.id),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildDismissible(
                  key: ValueKey(opt.id),
                  canDismiss: widget.options.length > 2,
                  onDismissed: () => _removeOption(i),
                  child: _OptionTile(
                    controller: opt.ctrl,
                    isCorrect: opt.isCorrect,
                    isMulti: widget.isMulti,
                    onToggle: () => _toggleCorrect(i),
                    maxChars: widget.maxChars,
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 4),
        _buildAddOptionButton(),
        const SizedBox(height: 8),
        Text(
          widget.isMulti
              ? 'Отметьте один или несколько правильных ответов'
              : 'Отметьте один правильный ответ',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      color != old.color ||
      radius != old.radius ||
      strokeWidth != old.strokeWidth;
}

Widget _dashedAddRowButton({
  required String label,
  required VoidCallback? onTap,
}) {
  final enabled = onTap != null;
  return GestureDetector(
    onTap: onTap,
    child: CustomPaint(
      painter: _DashedBorderPainter(
        color: enabled ? AppColors.mono300 : AppColors.mono200,
        radius: AppDimens.radiusLg,
        strokeWidth: AppDimens.borderWidth,
      ),
      child: Container(
        width: double.infinity,
        height: AppDimens.buttonHSm,
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.fieldText.copyWith(
            color: enabled ? AppColors.mono400 : AppColors.mono300,
          ),
        ),
      ),
    ),
  );
}

// ─── Option tile ──────────────────────────────────────────────────────────────

class _OptionTile extends StatefulWidget {
  final TextEditingController controller;
  final bool isCorrect;
  final bool isMulti;
  final VoidCallback onToggle;
  final int maxChars;

  const _OptionTile({
    required this.controller,
    required this.isCorrect,
    required this.isMulti,
    required this.onToggle,
    required this.maxChars,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isCorrect
              ? AppColors.mono900
              : focused
                  ? AppColors.mono700
                  : AppColors.mono150,
          width: widget.isCorrect || focused ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: widget.onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: widget.isMulti
                  ? _CheckboxIcon(isCorrect: widget.isCorrect)
                  : _RadioIcon(isCorrect: widget.isCorrect),
            ),
          ),
          Expanded(
            child: TextField(
              focusNode: _focus,
              controller: widget.controller,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
              maxLength: widget.maxChars,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              minLines: 1,
              maxLines: null,
              cursorColor: AppColors.mono900,
              decoration: InputDecoration(
                hintText: 'Вариант ответа...',
                hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mono300),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                counterText: '',
                filled: false,
                contentPadding: const EdgeInsets.only(right: 14, top: 14, bottom: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadioIcon extends StatelessWidget {
  final bool isCorrect;
  const _RadioIcon({required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
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

// ─── With given answer form ───────────────────────────────────────────────────

class _GivenAnswerForm extends StatefulWidget {
  final List<TextEditingController> answers;
  final int maxChars;
  final VoidCallback onChanged;

  const _GivenAnswerForm({
    required this.answers,
    required this.maxChars,
    required this.onChanged,
  });

  @override
  State<_GivenAnswerForm> createState() => _GivenAnswerFormState();
}

class _GivenAnswerFormState extends State<_GivenAnswerForm> {
  void _add() {
    setState(() => widget.answers.add(TextEditingController()));
    widget.onChanged();
  }

  void _remove(int i) {
    if (widget.answers.length <= 1) return;
    setState(() {
      widget.answers[i].dispose();
      widget.answers.removeAt(i);
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ПРАВИЛЬНЫЕ ОТВЕТЫ', style: AppTextStyles.sectionTag),
            GestureDetector(
              onTap: _add,
              child: Row(
                children: [
                  const Icon(Icons.add, size: 14, color: AppColors.mono700),
                  const SizedBox(width: 2),
                  Text('Добавить',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.mono700, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(widget.answers.length, (i) {
          final ctrl = widget.answers[i];
          return _entryAnimation(
            key: ValueKey(ctrl),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildDismissible(
                key: ValueKey(ctrl),
                canDismiss: widget.answers.length > 1,
                onDismissed: () => _remove(i),
                child: _TextInputTile(
                  controller: ctrl,
                  hint: 'Принимаемый ответ ${i + 1}',
                  maxChars: widget.maxChars,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        _dashedAddRowButton(label: '+ Добавить ответ', onTap: _add),
        const SizedBox(height: 8),
        Text(
          'Система примет любой из указанных вариантов написания',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

// ─── Free answer form ─────────────────────────────────────────────────────────

class _FreeAnswerForm extends StatelessWidget {
  const _FreeAnswerForm();

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
            child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.mono400),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Свободный ответ',
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
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

// ─── Drag form ────────────────────────────────────────────────────────────────

class _DragForm extends StatefulWidget {
  final List<TextEditingController> items;
  final int maxChars;
  final VoidCallback onChanged;

  const _DragForm({
    required this.items,
    required this.maxChars,
    required this.onChanged,
  });

  @override
  State<_DragForm> createState() => _DragFormState();
}

class _DragFormState extends State<_DragForm> {
  void _add() {
    setState(() => widget.items.add(TextEditingController()));
    widget.onChanged();
  }

  void _remove(int i) {
    if (widget.items.length <= 2) return;
    setState(() {
      widget.items[i].dispose();
      widget.items.removeAt(i);
    });
    widget.onChanged();
  }

  void _reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    setState(() {
      final ctrl = widget.items.removeAt(oldIndex);
      widget.items.insert(newIndex, ctrl);
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = widget.items.length > 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ЭЛЕМЕНТЫ В ПРАВИЛЬНОМ ПОРЯДКЕ', style: AppTextStyles.sectionTag),
            GestureDetector(
              onTap: _add,
              child: Row(
                children: [
                  const Icon(Icons.add, size: 14, color: AppColors.mono700),
                  const SizedBox(width: 2),
                  Text('Добавить',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.mono700, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, _, animation) => Material(
              elevation: 4,
              color: Colors.transparent,
              shadowColor: Colors.black12,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
            onReorder: _reorder,
            children: List.generate(widget.items.length, (i) {
              final ctrl = widget.items[i];
              return _entryAnimation(
                key: ObjectKey(ctrl),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildDismissible(
                    key: ValueKey(ctrl),
                    canDismiss: canDelete,
                    onDismissed: () => _remove(i),
                    child: _DragItemTile(index: i, controller: ctrl, maxChars: widget.maxChars),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        _dashedAddRowButton(label: '+ Добавить элемент', onTap: _add),
        const SizedBox(height: 8),
        Text(
          'Студент расставит элементы в нужном порядке перетаскиванием',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

// ─── Drag item tile ───────────────────────────────────────────────────────────

class _DragItemTile extends StatefulWidget {
  final int index;
  final TextEditingController controller;
  final int maxChars;

  const _DragItemTile({required this.index, required this.controller, required this.maxChars});

  @override
  State<_DragItemTile> createState() => _DragItemTileState();
}

class _DragItemTileState extends State<_DragItemTile> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused ? AppColors.mono700 : AppColors.mono150,
          width: focused ? 1.5 : 1.0,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReorderableDragStartListener(
              index: widget.index,
              child: Container(
                width: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.mono150)),
                ),
                child: const Icon(Icons.drag_indicator, size: 18, color: AppColors.mono300),
              ),
            ),
            Expanded(
              child: TextField(
                focusNode: _focus,
                controller: widget.controller,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
                maxLength: widget.maxChars,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                minLines: 1,
                maxLines: null,
                cursorColor: AppColors.mono900,
                decoration: InputDecoration(
                  hintText: 'Элемент ${widget.index + 1}',
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mono300),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  counterText: '',
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Connection form ──────────────────────────────────────────────────────────

class _ConnectionForm extends StatefulWidget {
  final List<_ConnectionPair> pairs;
  final int maxChars;
  final VoidCallback onChanged;

  const _ConnectionForm({
    required this.pairs,
    required this.maxChars,
    required this.onChanged,
  });

  @override
  State<_ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends State<_ConnectionForm> {
  void _add() {
    setState(() => widget.pairs.add(_ConnectionPair()));
    widget.onChanged();
  }

  void _remove(int i) {
    if (widget.pairs.length <= 2) return;
    setState(() {
      widget.pairs[i].leftCtrl.dispose();
      widget.pairs[i].rightCtrl.dispose();
      widget.pairs.removeAt(i);
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = widget.pairs.length > 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ПАРЫ СООТВЕТСТВИЯ', style: AppTextStyles.sectionTag),
            GestureDetector(
              onTap: _add,
              child: Row(
                children: [
                  const Icon(Icons.add, size: 14, color: AppColors.mono700),
                  const SizedBox(width: 2),
                  Text('Добавить',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.mono700, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text('Левая колонка',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.mono400, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 36),
            Expanded(
              child: Text('Правая колонка',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.mono400, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(widget.pairs.length, (i) {
          final pair = widget.pairs[i];
          return _entryAnimation(
            key: ValueKey(pair.id),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildDismissible(
                key: ValueKey(pair.id),
                canDismiss: canDelete,
                onDismissed: () => _remove(i),
                // Единый контейнер для всей пары
                child: _ConnectionPairTile(
                  leftController: pair.leftCtrl,
                  rightController: pair.rightCtrl,
                  index: i,
                  maxChars: widget.maxChars,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        _dashedAddRowButton(label: '+ Добавить пару', onTap: _add),
        const SizedBox(height: 8),
        Text(
          'Студент соединит левые элементы с правыми',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

class _ConnectionPairTile extends StatelessWidget {
  final TextEditingController leftController;
  final TextEditingController rightController;
  final int index;
  final int maxChars;

  const _ConnectionPairTile({
    required this.leftController,
    required this.rightController,
    required this.index,
    required this.maxChars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(  // ← Добавить
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,  // ← Изменить
          children: [
            Expanded(
              child: _ConnectionInputField(
                controller: leftController,
                hint: 'Термин ${index + 1}',
                isLeft: true,
                maxChars: maxChars,
              ),
            ),
            // Разделитель растянется на всю высоту Row
            Container(
              width: 36,  // ширина области с линией
              color: Colors.white,  // фон белый
              alignment: Alignment.center,
              child: Container(
                width: 20,
                height: 1,
                color: AppColors.mono300,
              ),
            ),
            Expanded(
              child: _ConnectionInputField(
                controller: rightController,
                hint: 'Определение ${index + 1}',
                isLeft: false,
                maxChars: maxChars,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isLeft;
  final int maxChars;
  const _ConnectionInputField({
    required this.controller,
    required this.hint,
    required this.isLeft,
    required this.maxChars,
  });

  @override
  State<_ConnectionInputField> createState() => _ConnectionInputFieldState();
}

class _ConnectionInputFieldState extends State<_ConnectionInputField> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused ? AppColors.mono700 : AppColors.mono150,
          width: focused ? 1.5 : 1.0,
        ),
      ),
      child: TextField(
        focusNode: _focus,
        controller: widget.controller,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
        maxLength: widget.maxChars,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        minLines: 1,
        maxLines: null,
        cursorColor: AppColors.mono900,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mono300),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          counterText: '',
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }
}


// ─── Text input tile ──────────────────────────────────────────────────────────

class _TextInputTile extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final int maxChars;

  const _TextInputTile({required this.controller, required this.hint, required this.maxChars});

  @override
  State<_TextInputTile> createState() => _TextInputTileState();
}

class _TextInputTileState extends State<_TextInputTile> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused ? AppColors.mono700 : AppColors.mono150,
          width: focused ? 1.5 : 1.0,
        ),
      ),
      child: TextField(
        focusNode: _focus,
        controller: widget.controller,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
        maxLength: widget.maxChars,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        minLines: 1,
        maxLines: null,
        cursorColor: AppColors.mono900,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mono300),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          counterText: '',
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }
}

// ─── Error banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(color: const Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final VoidCallback onSave;
  const _BottomBar({required this.onSave});

  @override
  Widget build(BuildContext context) {
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
      child: EdiumButton(label: 'Сохранить вопрос', onPressed: onSave),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _OptionDraft {
  final id = UniqueKey();
  final ctrl = TextEditingController();
  bool isCorrect = false;
}

class _ConnectionPair {
  final id = UniqueKey();
  final leftCtrl = TextEditingController();
  final rightCtrl = TextEditingController();
}

// ─── Image section ────────────────────────────────────────────────────────────

class _ImageSection extends StatelessWidget {
  final String? imageId;
  final bool uploading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ImageSection({
    required this.imageId,
    required this.uploading,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (uploading) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.mono25,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mono150),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.mono700, strokeWidth: 2),
              SizedBox(height: 12),
              Text('Загрузка изображения...', style: AppTextStyles.helperText),
            ],
          ),
        ),
      );
    }

    if (imageId != null) {
      return Stack(
        children: [
          QuestionImageWidget(imageId: imageId!),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onPick,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.mono300,
          radius: AppDimens.radiusLg,
          strokeWidth: AppDimens.borderWidth,
        ),
        child: Container(
          width: double.infinity,
          height: AppDimens.buttonHSm,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.image_outlined, size: 16, color: AppColors.mono400),
              const SizedBox(width: 6),
              Text(
                'Добавить изображение',
                style: AppTextStyles.fieldText.copyWith(color: AppColors.mono400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
