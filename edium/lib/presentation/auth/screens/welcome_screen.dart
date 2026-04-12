import 'package:edium/core/config/api_config.dart';
import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/main.dart';
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
  bool _switching = false;

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

  Future<void> _switchEnv(AppEnvironment env) async {
    if (env == ApiConfig.environment || _switching) return;
    setState(() => _switching = true);
    await reinitializeDependencies(env);
    appRestartKey.value++;
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
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) =>
                      FadeTransition(opacity: _logoOpacity, child: child),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                        child: Image.asset(
                          'assets/images/logo_e.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('edium', style: AppTextStyles.screenTitle),
                      const SizedBox(height: 6),
                      const Text(
                        'Образовательная платформа',
                        style: TextStyle(fontSize: 14, color: AppColors.mono300),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const Spacer(flex: 4),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonH,
                  child: ElevatedButton(
                    onPressed: () => context.push('/phone'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mono900,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      ),
                      elevation: 0,
                      textStyle: AppTextStyles.primaryButton,
                    ),
                    child: const Text('Войти'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.mono150)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'или',
                        style: TextStyle(fontSize: 13, color: AppColors.mono250),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.mono150)),
                  ],
                ),
                const SizedBox(height: 20),
                _QuizCodeBlock(
                  controller: _codeController,
                  focusNode: _codeFocus,
                  isFocused: _codeFieldFocused,
                  onSubmit: _submitCode,
                  onCellTap: _onCellTap,
                ),
                const SizedBox(height: 24),
                _EnvSwitcher(
                  current: ApiConfig.environment,
                  switching: _switching,
                  onSelect: _switchEnv,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EnvSwitcher extends StatelessWidget {
  final AppEnvironment current;
  final bool switching;
  final Future<void> Function(AppEnvironment) onSelect;

  const _EnvSwitcher({
    required this.current,
    required this.switching,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AppEnvironment.values.map((env) {
        final isActive = env == current;
        return GestureDetector(
          onTap: switching ? null : () => onSelect(env),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isActive ? AppColors.mono900 : AppColors.mono50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: switching && isActive
                ? const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    env.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isActive ? Colors.white : AppColors.mono300,
                    ),
                  ),
          ),
        );
      }).toList(),
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
            const Text(
              'Без авторизации',
              style: TextStyle(fontSize: 12, color: AppColors.mono300),
            ),
          ],
        ),
      ),
    );
  }
}
