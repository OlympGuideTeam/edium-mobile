part of 'live_student_screen.dart';

class _AnswerOptions extends StatefulWidget {
  final LiveQuestion question;
  final ValueChanged<Map<String, dynamic>> onSelect;

  const _AnswerOptions({required this.question, required this.onSelect});

  @override
  State<_AnswerOptions> createState() => _AnswerOptionsState();
}

class _AnswerOptionsState extends State<_AnswerOptions> {
  String? _selectedId;
  final Set<String> _selectedIds = {};
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.question.type) {
      QuestionType.multiChoice => _buildMultiChoice(),
      QuestionType.withGivenAnswer => _buildTextInput(multiline: false),
      QuestionType.withFreeAnswer => _buildTextInput(multiline: true),
      QuestionType.drag => _LiveDragQuestion(
          question: widget.question,
          onConfirm: (order) => widget.onSelect({'order': order}),
        ),
      QuestionType.connection => _LiveConnectionQuestion(
          question: widget.question,
          onConfirm: (pairs) => widget.onSelect({'pairs': pairs}),
        ),
      _ => _buildSingleChoice(),
    };
  }

  Widget _buildSingleChoice() {
    return Column(
      children: widget.question.options.map((opt) {
        final isSelected = _selectedId == opt.id;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedId = opt.id);
            widget.onSelect({'selected_option_id': opt.id});
          },
          child: _OptionCard(
            isSelected: isSelected,
            child: Row(
              children: [
                _RadioDot(isSelected: isSelected),
                const SizedBox(width: 12),
                Expanded(child: _OptionText(opt.text, isSelected: isSelected)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiChoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.question.options.map((opt) {
          final isSelected = _selectedIds.contains(opt.id);
          return GestureDetector(
            onTap: () => setState(() {
              if (isSelected) {
                _selectedIds.remove(opt.id);
              } else {
                _selectedIds.add(opt.id);
              }
            }),
            child: _OptionCard(
              isSelected: isSelected,
              child: Row(
                children: [
                  _CheckDot(isSelected: isSelected),
                  const SizedBox(width: 12),
                  Expanded(child: _OptionText(opt.text, isSelected: isSelected)),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        _ConfirmButton(
          enabled: _selectedIds.isNotEmpty,
          onTap: () =>
              widget.onSelect({'selected_option_ids': _selectedIds.toList()}),
        ),
      ],
    );
  }

  Widget _buildTextInput({required bool multiline}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.liveDarkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.liveDarkBorder),
          ),
          child: TextField(
            controller: _textCtrl,
            maxLines: multiline ? 4 : 1,
            style: const TextStyle(fontSize: 15, color: Colors.white),
            cursorColor: AppColors.liveAccent,
            enableInteractiveSelection: false,
            contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
            decoration: InputDecoration(
              hintText: multiline ? 'Введите развёрнутый ответ…' : 'Введите ответ…',
              hintStyle: const TextStyle(
                  color: AppColors.liveDarkMuted, fontSize: 15),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: multiline
                  ? const EdgeInsets.all(16)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        _ConfirmButton(
          enabled: _textCtrl.text.trim().isNotEmpty,
          onTap: () => widget.onSelect({'text': _textCtrl.text.trim()}),
        ),
      ],
    );
  }
}

