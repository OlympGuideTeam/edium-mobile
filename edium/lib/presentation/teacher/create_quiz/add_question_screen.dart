import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Question types (Riddler API) ─────────────────────────────────────────────

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
  final _textCtrl = TextEditingController();
  String? _error;

  late final List<_OptionDraft> _options;
  late final List<TextEditingController> _correctAnswers;
  late final List<TextEditingController> _dragItems;
  late final List<_ConnectionPair> _pairs;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuestion;
    if (q == null) {
      _type = _QType.singleChoice;
      _options = [_OptionDraft(), _OptionDraft()];
      _correctAnswers = [TextEditingController()];
      _dragItems = [TextEditingController(), TextEditingController(), TextEditingController()];
      _pairs = [_ConnectionPair(), _ConnectionPair()];
      return;
    }

    _type = _QType.values.firstWhere(
      (t) => t.apiValue == q['type'],
      orElse: () => _QType.singleChoice,
    );
    _textCtrl.text = q['text'] as String? ?? '';

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

  void _changeType(_QType t) {
    if (_type == t) return;
    setState(() {
      _type = t;
      _error = null;
      // При переключении на одиночный — оставить только один выбранный вариант
      if (t == _QType.singleChoice) {
        final firstCorrect = _options.indexWhere((o) => o.isCorrect);
        for (var i = 0; i < _options.length; i++) {
          _options[i].isCorrect = firstCorrect != -1 && i == firstCorrect;
        }
      }
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
          'answer_options': _options
              .map((o) => {
                    'text': o.ctrl.text.trim(),
                    'is_correct': o.isCorrect,
                  })
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
        return {
          'type': _type.apiValue,
          'text': text,
          'max_score': 10,
          'answer_options': [],
          'metadata': {'correct_order': items},
        };

      case _QType.connection:
        for (final p in _pairs) {
          if (p.leftCtrl.text.trim().isEmpty ||
              p.rightCtrl.text.trim().isEmpty) {
            setState(() => _error = 'Заполните все пары соответствия');
            return null;
          }
        }
        final left = _pairs.map((p) => p.leftCtrl.text.trim()).toList();
        final right = _pairs.map((p) => p.rightCtrl.text.trim()).toList();
        final pairs = <String, String>{};
        for (var i = 0; i < _pairs.length; i++) {
          pairs[left[i]] = right[i];
        }
        setState(() => _error = null);
        return {
          'type': _type.apiValue,
          'text': text,
          'max_score': 10,
          'answer_options': [],
          'metadata': {
            'left': left,
            'right': right,
            'correct_pairs': pairs,
          },
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _TypeSelector(selected: _type, onSelect: _changeType),
                    const SizedBox(height: 24),
                    _QuestionTextField(controller: _textCtrl),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.06),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(_type),
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
            ),
            _BottomBar(
              onSave: () {
                FocusScope.of(context).unfocus();
                final q = _buildQuestion();
                if (q != null) Navigator.pop(context, q);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormForType() {
    return switch (_type) {
      _QType.singleChoice => _ChoiceForm(
          options: _options,
          isMulti: false,
          onChanged: () => setState(() {}),
        ),
      _QType.multipleChoice => _ChoiceForm(
          options: _options,
          isMulti: true,
          onChanged: () => setState(() {}),
        ),
      _QType.withGivenAnswer => _GivenAnswerForm(
          answers: _correctAnswers,
          onChanged: () => setState(() {}),
        ),
      _QType.withFreeAnswer => const _FreeAnswerForm(),
      _QType.drag => _DragForm(
          items: _dragItems,
          onChanged: () => setState(() {}),
        ),
      _QType.connection => _ConnectionForm(
          pairs: _pairs,
          onChanged: () => setState(() {}),
        ),
    };
  }
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
                    Icon(
                      t.icon,
                      size: 13,
                      color: isSelected ? Colors.white : AppColors.mono400,
                    ),
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

// ─── Choice form (single & multiple) ─────────────────────────────────────────

class _ChoiceForm extends StatefulWidget {
  final List<_OptionDraft> options;
  final bool isMulti;
  final VoidCallback onChanged;

  const _ChoiceForm({
    required this.options,
    required this.isMulti,
    required this.onChanged,
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
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OptionTile(
              controller: opt.ctrl,
              isCorrect: opt.isCorrect,
              isMulti: widget.isMulti,
              onToggle: () => _toggleCorrect(i),
              onRemove: widget.options.length > 2 ? () => _removeOption(i) : null,
            ),
          );
        }),
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

class _OptionTile extends StatelessWidget {
  final TextEditingController controller;
  final bool isCorrect;
  final bool isMulti;
  final VoidCallback onToggle;
  final VoidCallback? onRemove;

  const _OptionTile({
    required this.controller,
    required this.isCorrect,
    required this.isMulti,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? AppColors.mono900 : AppColors.mono150,
          width: isCorrect ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: isMulti
                  ? _CheckboxIcon(isCorrect: isCorrect)
                  : _RadioIcon(isCorrect: isCorrect),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
              maxLength: 50,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              minLines: 1,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Вариант ответа...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mono300,
                ),
                border: InputBorder.none,
                isDense: true,
                counterText: '',
                contentPadding: const EdgeInsets.only(
                  right: 14,
                  top: 14,
                  bottom: 14,
                ),
              ),
              cursorColor: AppColors.mono900,
            ),
          ),
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Icon(Icons.close, size: 16, color: AppColors.mono350),
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
  final VoidCallback onChanged;

  const _GivenAnswerForm({required this.answers, required this.onChanged});

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
                          color: AppColors.mono700,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(widget.answers.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TextInputTile(
                controller: widget.answers[i],
                hint: 'Принимаемый ответ ${i + 1}',
                onRemove: widget.answers.length > 1 ? () => _remove(i) : null,
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

// ─── Drag form ────────────────────────────────────────────────────────────────

class _DragForm extends StatefulWidget {
  final List<TextEditingController> items;
  final VoidCallback onChanged;

  const _DragForm({required this.items, required this.onChanged});

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

  @override
  Widget build(BuildContext context) {
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
                          color: AppColors.mono700,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(widget.items.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DragItemTile(
                index: i,
                controller: widget.items[i],
                onRemove: widget.items.length > 2 ? () => _remove(i) : null,
              ),
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

class _DragItemTile extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final VoidCallback? onRemove;

  const _DragItemTile({
    required this.index,
    required this.controller,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mono400,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
                maxLength: 50,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                minLines: 1,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Элемент ${index + 1}',
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mono300),
                  border: InputBorder.none,
                  isDense: true,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                ),
                cursorColor: AppColors.mono900,
              ),
            ),
            if (onRemove != null)
              GestureDetector(
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                  child: Icon(Icons.close, size: 16, color: AppColors.mono350),
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
  final VoidCallback onChanged;

  const _ConnectionForm({required this.pairs, required this.onChanged});

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
                          color: AppColors.mono700,
                          fontWeight: FontWeight.w600)),
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
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.mono400,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 36),
            Expanded(
              child: Text('Правая колонка',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.mono400,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(widget.pairs.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _TextInputTile(
                          controller: widget.pairs[i].leftCtrl,
                          hint: 'Термин ${i + 1}',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 20,
                          height: 1,
                          color: AppColors.mono300,
                        ),
                      ),
                      Expanded(
                        child: _TextInputTile(
                          controller: widget.pairs[i].rightCtrl,
                          hint: 'Определение ${i + 1}',
                        ),
                      ),
                    ],
                  ),
                  if (widget.pairs.length > 2)
                    GestureDetector(
                      onTap: () => _remove(i),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Удалить пару',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mono400,
                          ),
                        ),
                      ),
                    ),
                ],
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

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _TextInputTile extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onRemove;

  const _TextInputTile({
    required this.controller,
    required this.hint,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
      maxLength: 50,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      minLines: 1,
      maxLines: null,
      cursorColor: AppColors.mono900,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mono300),
        filled: true,
        fillColor: AppColors.mono25,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        suffixIcon: onRemove != null
            ? GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close, size: 16, color: AppColors.mono350),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mono150),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mono150),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mono700, width: 1.5),
        ),
        counterText: '',
      ),
    );
  }
}

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
              style: AppTextStyles.caption
                  .copyWith(color: const Color(0xFFEF4444)),
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
      child: EdiumButton(
        label: 'Сохранить вопрос',
        onPressed: onSave,
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _OptionDraft {
  final ctrl = TextEditingController();
  bool isCorrect = false;
}

class _ConnectionPair {
  final leftCtrl = TextEditingController();
  final rightCtrl = TextEditingController();
}
