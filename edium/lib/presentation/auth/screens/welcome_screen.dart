import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();
  bool _codeFieldFocused = false;

  late final AnimationController _animController;
  late final Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _logoOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _codeFocus.addListener(() {
      final focused = _codeFocus.hasFocus;
      if (focused != _codeFieldFocused) {
        setState(() => _codeFieldFocused = focused);
        if (focused) {
          _animController.forward();
        } else {
          _animController.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submitCode() {
    final code = _codeController.text.trim();
    if (code.length == 6) {
      // TODO: навигация к квизу по коду
    }
  }

  void _onCellTap(int index) {
    _codeFocus.requestFocus();
    final text = _codeController.text;
    if (index < text.length) {
      final trimmed = text.substring(0, index);
      _codeController.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }
    setState(() {});
  }

  void _dismissKeyboard() {
    if (_codeFocus.hasFocus) {
      _codeFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Логотип с анимацией исчезновения
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoOpacity,
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/logo_e.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'edium',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Образовательная платформа',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const Spacer(flex: 4),
                // Кнопка "Войти"
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.push('/phone'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    child: const Text('Войти'),
                  ),
                ),
                const SizedBox(height: 20),
                // Разделитель
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'или',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFBBBBBB),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 20),
                // Блок "Присоединиться к квизу"
                _QuizCodeBlock(
                  controller: _codeController,
                  focusNode: _codeFocus,
                  isFocused: _codeFieldFocused,
                  onSubmit: _submitCode,
                  onCellTap: _onCellTap,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizCodeBlock extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final VoidCallback onSubmit;
  final void Function(int index) onCellTap;

  const _QuizCodeBlock({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.onSubmit,
    required this.onCellTap,
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
            color: isFocused
                ? const Color(0xFF333333)
                : const Color(0xFFCCCCCC),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const Text(
              'ПРИСОЕДИНИТЬСЯ К КВИЗУ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF999999),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 54,
              child: Stack(
                children: [
                  // Визуальные ячейки
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return GestureDetector(
                        onTap: () => onCellTap(i),
                        child: AnimatedBuilder(
                          animation: controller,
                          builder: (context, _) {
                            final text = controller.text;
                            final hasDigit = i < text.length;
                            final isNext = i == text.length;

                            Color borderColor;
                            if (hasDigit) {
                              borderColor = const Color(0xFF333333);
                            } else if (isNext && isFocused) {
                              borderColor = const Color(0xFF333333);
                            } else {
                              borderColor = const Color(0xFFDDDDDD);
                            }

                            return Container(
                              width: 46,
                              height: 54,
                              margin:
                                  EdgeInsets.only(left: i == 0 ? 0 : 8),
                              decoration: BoxDecoration(
                                color: hasDigit
                                    ? Colors.white
                                    : const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: hasDigit
                                    ? Text(
                                        text[i],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF333333),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                  // Скрытый TextField — без контекстного меню
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
                            if (value.length == 6) {
                              onSubmit();
                            }
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
            const Text(
              'Без авторизации',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
