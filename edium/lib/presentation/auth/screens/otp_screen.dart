import 'dart:async';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _codeLength = 4;
  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_codeLength, (_) => FocusNode());
  String? _error;
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  String get _code =>
      _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    setState(() => _error = null);

    if (value.length > 1) {
      // Handle paste — distribute digits across fields
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (var i = 0; i < _codeLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final nextIndex = digits.length < _codeLength
          ? digits.length
          : _codeLength - 1;
      _focusNodes[nextIndex].requestFocus();
      if (digits.length >= _codeLength) _submit();
      return;
    }

    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-submit when all digits entered
    if (_code.length == _codeLength) {
      _submit();
    }
  }

  void _onKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _submit() {
    final otp = _code;
    if (otp.length < _codeLength) {
      setState(() => _error = 'Введите код из $_codeLength цифр');
      return;
    }
    setState(() => _error = null);
    FocusScope.of(context).unfocus();
    getIt<AuthBloc>()
        .add(VerifyOtpEvent(phone: widget.phone, otp: otp));
  }

  void _resend() {
    if (_countdown > 0) return;
    getIt<AuthBloc>().add(SendOtpEvent(widget.phone));
    _startCountdown();
    // Clear fields
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() => _error = state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return Column(
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new,
                                size: 20),
                            onPressed: () => context.pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            // Lock icon
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withAlpha(30),
                                    AppColors.primary.withAlpha(15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                Icons.lock_outline,
                                color: AppColors.primary,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Подтверждение',
                              style: AppTextStyles.heading2,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary),
                                children: [
                                  const TextSpan(
                                      text: 'Введите код, отправленный\nна номер '),
                                  TextSpan(
                                    text: widget.phone,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            // OTP digit boxes
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: List.generate(
                                _codeLength,
                                (i) => Padding(
                                  padding: EdgeInsets.only(
                                      left: i == 0 ? 0 : 12),
                                  child: _DigitBox(
                                    controller: _controllers[i],
                                    focusNode: _focusNodes[i],
                                    hasError: _error != null,
                                    onChanged: (v) =>
                                        _onDigitChanged(i, v),
                                    onKeyEvent: (e) =>
                                        _onKeyDown(i, e),
                                  ),
                                ),
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withAlpha(15),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline,
                                        size: 16,
                                        color: AppColors.error),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        _error!,
                                        style: AppTextStyles.caption
                                            .copyWith(
                                                color:
                                                    AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                            // Resend
                            TextButton(
                              onPressed:
                                  _countdown == 0 ? _resend : null,
                              child: Text(
                                _countdown > 0
                                    ? 'Отправить повторно через ${_countdown}c'
                                    : 'Отправить повторно',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: _countdown == 0
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Mock hint
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Тестовый код: 1234',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: EdiumButton(
                        label: 'Подтвердить',
                        onPressed: isLoading ? null : _submit,
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _DigitBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;
        final hasFilled = controller.text.isNotEmpty;

        Color borderColor;
        if (hasError) {
          borderColor = AppColors.error;
        } else if (isFocused) {
          borderColor = AppColors.primary;
        } else if (hasFilled) {
          borderColor = AppColors.primary.withAlpha(80);
        } else {
          borderColor = AppColors.cardBorder;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 60,
          height: 64,
          decoration: BoxDecoration(
            color: isFocused
                ? AppColors.primary.withAlpha(12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isFocused ? 2 : 1.5,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: onKeyEvent,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                onChanged: onChanged,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                  isCollapsed: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
