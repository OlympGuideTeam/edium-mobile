part of 'welcome_screen.dart';

class _QuizCodeBlock extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool loading;
  final VoidCallback onSubmit;
  final void Function(int index) onCellTap;
  final void Function(String) onChanged;

  const _QuizCodeBlock({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.loading,
    required this.onSubmit,
    required this.onCellTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isFocused ? AppColors.mono700 : AppColors.mono200,
            width: AppDimens.borderWidth,
          ),
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
        child: Column(
          children: [
            const Text('ПРИСОЕДИНИТЬСЯ К КВИЗУ', style: AppTextStyles.sectionTag),
            const SizedBox(height: 14),
            SizedBox(
              height: AppDimens.otpCellH,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Expanded(child: GestureDetector(
                        onTap: () => onCellTap(i),
                        child: AnimatedBuilder(
                          animation: controller,
                          builder: (context, _) {
                            final text = controller.text;
                            final hasDigit = i < text.length;
                            final isNext = i == text.length;

                            final borderColor = hasDigit
                                ? AppColors.mono700
                                : (isNext && isFocused)
                                    ? AppColors.mono700
                                    : AppColors.mono150;

                            return Container(
                              height: AppDimens.otpCellH,
                              margin: EdgeInsets.symmetric(
                                  horizontal: AppDimens.otpCellGap / 2),
                              decoration: BoxDecoration(
                                color: hasDigit ? Colors.white : AppColors.mono25,
                                borderRadius:
                                    BorderRadius.circular(AppDimens.radiusSm),
                                border: Border.all(
                                    color: borderColor,
                                    width: AppDimens.borderWidth),
                              ),
                              child: Center(
                                child: hasDigit
                                    ? Text(text[i],
                                        style: AppTextStyles.otpDigit)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ));
                    }),
                  ),
                  Positioned.fill(
                    child: ExcludeSemantics(
                      child: Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          showCursor: false,
                          enableInteractiveSelection: false,
                          stylusHandwritingEnabled: false,
                          contextMenuBuilder: (context, state) =>
                              const SizedBox.shrink(),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          onChanged: (value) {
                            onChanged(value);
                            if (value.length == 6) onSubmit();
                          },
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            loading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mono400),
                  )
                : const Text(
                    'Без авторизации',
                    style: TextStyle(fontSize: 12, color: AppColors.mono300),
                  ),
          ],
        ),
      ),
    );
  }
}

