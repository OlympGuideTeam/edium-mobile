import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/presentation/shared/widgets/edium_text_field.dart';
import 'package:flutter/material.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  QuestionType _type = QuestionType.singleChoice;
  final _textCtrl = TextEditingController();
  final _explanationCtrl = TextEditingController();
  final List<_OptionDraft> _options = [
    _OptionDraft(),
    _OptionDraft(),
  ];
  String? _error;

  @override
  void dispose() {
    _textCtrl.dispose();
    _explanationCtrl.dispose();
    for (final o in _options) {
      o.ctrl.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() => _options.add(_OptionDraft()));
  }

  void _removeOption(int i) {
    if (_options.length <= 2) return;
    setState(() {
      _options[i].ctrl.dispose();
      _options.removeAt(i);
    });
  }

  void _toggleCorrect(int i) {
    setState(() {
      if (_type == QuestionType.singleChoice) {
        for (var j = 0; j < _options.length; j++) {
          _options[j].isCorrect = j == i;
        }
      } else {
        _options[i].isCorrect = !_options[i].isCorrect;
      }
    });
  }

  Map<String, dynamic>? _buildQuestion() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Введите текст вопроса');
      return null;
    }
    if (_type != QuestionType.textInput) {
      for (final o in _options) {
        if (o.ctrl.text.trim().isEmpty) {
          setState(() => _error = 'Заполните все варианты ответа');
          return null;
        }
      }
      final hasCorrect = _options.any((o) => o.isCorrect);
      if (!hasCorrect) {
        setState(() => _error = 'Отметьте хотя бы один правильный ответ');
        return null;
      }
    }
    setState(() => _error = null);

    final typeStr = {
      QuestionType.singleChoice: 'single_choice',
      QuestionType.multiChoice: 'multi_choice',
      QuestionType.textInput: 'text_input',
    }[_type]!;

    return {
      'text': text,
      'type': typeStr,
      'options': _type == QuestionType.textInput
          ? []
          : _options.asMap().entries.map((e) => {
                'id': 'opt_${e.key}',
                'text': e.value.ctrl.text.trim(),
                'is_correct': e.value.isCorrect,
              }).toList(),
      if (_explanationCtrl.text.trim().isNotEmpty)
        'explanation': _explanationCtrl.text.trim(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить вопрос')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            Text('Тип вопроса', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),
            Row(
              children: [
                _TypeChip(
                  label: 'Один ответ',
                  icon: Icons.radio_button_checked,
                  selected: _type == QuestionType.singleChoice,
                  onTap: () => setState(() {
                    _type = QuestionType.singleChoice;
                    for (final o in _options) {
                      o.isCorrect = false;
                    }
                  }),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'Несколько',
                  icon: Icons.check_box_outlined,
                  selected: _type == QuestionType.multiChoice,
                  onTap: () => setState(() {
                    _type = QuestionType.multiChoice;
                    for (final o in _options) {
                      o.isCorrect = false;
                    }
                  }),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'Текст',
                  icon: Icons.text_fields,
                  selected: _type == QuestionType.textInput,
                  onTap: () => setState(() => _type = QuestionType.textInput),
                ),
              ],
            ),
            const SizedBox(height: 24),
            EdiumTextField(
              label: 'Текст вопроса',
              hint: 'Введите вопрос...',
              controller: _textCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            if (_type != QuestionType.textInput) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Варианты ответа', style: AppTextStyles.subtitle),
                  TextButton.icon(
                    onPressed: _options.length < 6 ? _addOption : null,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Добавить'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(_options.length, (i) {
                final opt = _options[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _toggleCorrect(i),
                        child: _type == QuestionType.singleChoice
                            ? Radio<int>(
                                value: i,
                                groupValue: _options.indexWhere((o) => o.isCorrect),
                                onChanged: (_) => _toggleCorrect(i),
                                activeColor: AppColors.success,
                              )
                            : Checkbox(
                                value: opt.isCorrect,
                                onChanged: (_) => _toggleCorrect(i),
                                activeColor: AppColors.success,
                              ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: opt.ctrl,
                          style: AppTextStyles.bodySmall,
                          decoration: InputDecoration(
                            hintText: 'Вариант ${i + 1}',
                            hintStyle: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.cardBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: opt.isCorrect
                                    ? AppColors.success
                                    : AppColors.cardBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: opt.isCorrect
                                ? AppColors.successLight
                                : AppColors.surface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18,
                            color: AppColors.textSecondary),
                        onPressed: () => _removeOption(i),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
            EdiumTextField(
              label: 'Объяснение (необязательно)',
              hint: 'Объясните правильный ответ...',
              controller: _explanationCtrl,
              maxLines: 2,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Text(_error!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            EdiumButton(
              label: 'Сохранить вопрос',
              onPressed: () {
                final q = _buildQuestion();
                if (q != null) Navigator.pop(context, q);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OptionDraft {
  final ctrl = TextEditingController();
  bool isCorrect = false;
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
