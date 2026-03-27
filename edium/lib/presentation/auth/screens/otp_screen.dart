import 'dart:async';

import 'package:edium/core/config/api_config.dart';
import 'package:edium/core/di/injection.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
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

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  static const int _codeLength = 6;

  final _hiddenController = TextEditingController();
  final _hiddenFocus = FocusNode();
  String? _error;
  int _countdown = 60;
  Timer? _timer;

  // Shake animation
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hiddenFocus.requestFocus();
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
    _hiddenController.dispose();
    _hiddenFocus.dispose();
    _shakeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String get _maskedPhone {
    final p = widget.phone;
    if (p.length >= 12) {
      return '${p.substring(0, 5)} ···-··-${p.substring(p.length - 2)}';
    }
    return p;
  }

  void _onCodeChanged(String value) {
    // Оставляем только цифры, макс 6
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits != value || digits.length > _codeLength) {
      final clamped =
          digits.length > _codeLength ? digits.substring(0, _codeLength) : digits;
      _hiddenController.value = TextEditingValue(
        text: clamped,
        selection: TextSelection.collapsed(offset: clamped.length),
      );
    }

    setState(() => _error = null);

    if (_hiddenController.text.length == _codeLength) {
      _submit();
    }
  }

  /// При тапе на ячейку — обрезаем текст до этой позиции
  void _onCellTap(int index) {
    _hiddenFocus.requestFocus();
    final text = _hiddenController.text;
    if (index < text.length) {
      final trimmed = text.substring(0, index);
      _hiddenController.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }
    setState(() {});
  }

  void _submit() {
    final otp = _hiddenController.text;
    if (otp.length < _codeLength) {
      setState(() => _error = 'Введите код из $_codeLength цифр');
      _triggerShake();
      return;
    }
    setState(() => _error = null);
    FocusScope.of(context).unfocus();
    getIt<AuthBloc>().add(VerifyOtpEvent(phone: widget.phone, otp: otp));
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  void _resend() {
    if (_countdown > 0) return;
    getIt<AuthBloc>().add(SendOtpEvent(widget.phone));
    _startCountdown();
    _hiddenController.clear();
    _hiddenFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() => _error = state.message);
            _triggerShake();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return Column(
                  children: [
                    // Кнопка назад
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new,
                                size: 20, color: Color(0xFF1A1A1A)),
                            onPressed: () => context.pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              'Введите код',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Отправили код в Telegram\nна номер $_maskedPhone',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF888888),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // OTP-ячейки с shake-анимацией
                            AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(_shakeAnimation.value, 0),
                                  child: child,
                                );
                              },
                              child: GestureDetector(
                                onTap: () => _hiddenFocus.requestFocus(),
                                child: SizedBox(
                                  height: 54,
                                  child: Stack(
                                    children: [
                                      // Визуальные ячейки
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                            _codeLength, (i) {
                                          return GestureDetector(
                                            onTap: () => _onCellTap(i),
                                            child: AnimatedBuilder(
                                              animation: _hiddenController,
                                              builder: (context, _) {
                                                final text =
                                                    _hiddenController.text;
                                                final hasDigit =
                                                    i < text.length;
                                                final isNext =
                                                    i == text.length;
                                                final hasError =
                                                    _error != null;

                                                Color borderColor;
                                                if (hasError && hasDigit) {
                                                  borderColor =
                                                      const Color(0xFFEF4444);
                                                } else if (hasDigit) {
                                                  borderColor =
                                                      const Color(0xFF333333);
                                                } else if (isNext &&
                                                    _hiddenFocus.hasFocus) {
                                                  borderColor =
                                                      const Color(0xFF333333);
                                                } else {
                                                  borderColor =
                                                      const Color(0xFFBBBBBB);
                                                }

                                                return Container(
                                                  width: 46,
                                                  height: 54,
                                                  margin: EdgeInsets.only(
                                                      left: i == 0 ? 0 : 8),
                                                  decoration: BoxDecoration(
                                                    color: hasDigit
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFFFAFAFA),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                      color: borderColor,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: hasDigit
                                                        ? Text(
                                                            text[i],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: Color(
                                                                  0xFF333333),
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
                                              controller:
                                                  _hiddenController,
                                              focusNode: _hiddenFocus,
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLength: _codeLength,
                                              showCursor: false,
                                              enableInteractiveSelection:
                                                  false,
                                              stylusHandwritingEnabled: false,
                                              contextMenuBuilder:
                                                  (context, state) =>
                                                      const SizedBox
                                                          .shrink(),
                                              autofillHints: const [
                                                AutofillHints
                                                    .oneTimeCode,
                                              ],
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    _codeLength),
                                              ],
                                              onChanged: _onCodeChanged,
                                              decoration:
                                                  const InputDecoration(
                                                counterText: '',
                                                border:
                                                    InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            Center(
                              child: Text(
                                'Не пришёл код?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: GestureDetector(
                                onTap: _countdown == 0 ? _resend : null,
                                child: Text(
                                  _countdown > 0
                                      ? 'Отправить повторно через $_countdown сек'
                                      : 'Отправить повторно',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _countdown == 0
                                        ? const Color(0xFF555555)
                                        : const Color(0xFFAAAAAA),
                                    decoration: _countdown == 0
                                        ? TextDecoration.underline
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            if (ApiConfig.useMock) ...[
                              const SizedBox(height: 16),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Тестовый код: 123456',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF888888),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            // Кнопка подтверждения
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A1A1A),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      const Color(0xFFCCCCCC),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Подтвердить'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Кнопка "Изменить номер"
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () => context.pop(),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5F5F5),
                                  foregroundColor: const Color(0xFF555555),
                                  side: const BorderSide(
                                      color: Color(0xFFDDDDDD)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('← Изменить номер'),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
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
