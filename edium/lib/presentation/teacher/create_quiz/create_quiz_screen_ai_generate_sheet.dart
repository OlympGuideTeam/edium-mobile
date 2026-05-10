part of 'create_quiz_screen.dart';

class _AIGenerateSheet extends StatefulWidget {
  final ValueChanged<String> onGenerate;
  final bool isGenerating;
  final TextEditingController textController;

  const _AIGenerateSheet({
    required this.onGenerate,
    required this.isGenerating,
    required this.textController,
  });

  @override
  State<_AIGenerateSheet> createState() => _AIGenerateSheetState();
}

class _AIGenerateSheetState extends State<_AIGenerateSheet> {
  final _fieldFocus = FocusNode();
  static const _maxLength = 4000;
  static const _minGenerateLength = 500;

  TextEditingController get _textCtrl => widget.textController;

  @override
  void initState() {
    super.initState();
    _fieldFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fieldFocus.dispose();
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

