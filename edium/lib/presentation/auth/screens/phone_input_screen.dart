import 'package:edium/core/di/injection.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Форматирует 10 цифр в "916 251 53 45"
String _formatPhoneDigits(String digits) {
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i == 3 || i == 6 || i == 8) buf.write(' ');
    buf.write(digits[i]);
  }
  return buf.toString();
}

/// Извлекает чистые 10 цифр из любого формата ввода/вставки.
/// Удаляет всё кроме цифр, убирает ведущие 7/8 (код страны).
String _cleanPhoneInput(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  // Убираем ведущую 8 или 7 (код страны)
  if (digits.length == 11 && (digits.startsWith('7') || digits.startsWith('8'))) {
    digits = digits.substring(1);
  }
  // Ограничиваем 10 цифрами
  if (digits.length > 10) digits = digits.substring(0, 10);
  return digits;
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _cleanPhoneInput(newValue.text);
    final formatted = _formatPhoneDigits(digits);

    // Вычисляем позицию курсора
    // Считаем, сколько цифр до позиции курсора в новом значении
    var rawCursor = newValue.selection.baseOffset;
    var digitCount = 0;
    for (var i = 0; i < rawCursor && i < newValue.text.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(newValue.text[i])) digitCount++;
    }

    // Учитываем удаление ведущей 7/8
    final rawDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (rawDigits.length == 11 &&
        (rawDigits.startsWith('7') || rawDigits.startsWith('8'))) {
      digitCount = (digitCount - 1).clamp(0, 10);
    }
    digitCount = digitCount.clamp(0, digits.length);

    // Находим позицию в отформатированной строке
    var cursorPos = 0;
    var counted = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (counted == digitCount) break;
      cursorPos = i + 1;
      if (formatted[i] != ' ') counted++;
    }
    cursorPos = cursorPos.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPos),
    );
  }
}

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _digits => _controller.text.replaceAll(RegExp(r'[^0-9]'), '');

  bool get _isValid => _digits.length == 10;

  void _submit() {
    if (!_isValid) {
      setState(() => _error = 'Введите корректный номер телефона');
      return;
    }
    setState(() => _error = null);
    final phone = '+7$_digits';
    getIt<AuthBloc>().add(SendOtpEvent(phone));
  }

  Future<void> _openTelegramBot() async {
    final uri = Uri.parse('https://t.me/edium_bot');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openVkBot() async {
    final uri = Uri.parse('https://vk.com/edium_bot');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            context.push('/otp?phone=${Uri.encodeComponent(state.phone)}');
          } else if (state is AuthError) {
            setState(() => _error = state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Кнопка назад
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 8),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 20, color: Color(0xFF1A1A1A)),
                      onPressed: () => context.pop(),
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
                            'Войти в Edium',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Введите номер телефона — мы отправим\nкод подтверждения в Telegram',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF888888),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Номер телефона',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF888888),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Поле ввода телефона
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _error != null
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFBBBBBB),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 14),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('🇷🇺',
                                          style: TextStyle(fontSize: 16)),
                                      SizedBox(width: 6),
                                      Text(
                                        '+7',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Тонкий разделитель между +7 и полем ввода
                                Container(
                                  width: 1,
                                  height: 24,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  color: const Color(0xFFDDDDDD),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    keyboardType: TextInputType.phone,
                                    cursorColor: const Color(0xFF1A1A1A),
                                    inputFormatters: [
                                      _PhoneInputFormatter(),
                                    ],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF333333),
                                      letterSpacing: 0.5,
                                    ),
                                    onChanged: (_) =>
                                        setState(() => _error = null),
                                    decoration: const InputDecoration(
                                      hintText: '900 000 00 00',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFFBBBBBB),
                                        letterSpacing: 0.5,
                                      ),
                                      filled: false,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          // Telegram-бот инфо
                          GestureDetector(
                            onTap: _openTelegramBot,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFDDDDDD)),
                              ),
                              child: const Row(
                                children: [
                                  Text('✈️', style: TextStyle(fontSize: 20)),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Код придёт в Telegram',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Откройте @edium_bot и отправьте контакт',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF999999),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.open_in_new,
                                      size: 16, color: Color(0xFFBBBBBB)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // ВКонтакте-бот инфо
                          GestureDetector(
                            onTap: _openVkBot,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFDDDDDD)),
                              ),
                              child: const Row(
                                children: [
                                  Text('💬', style: TextStyle(fontSize: 20)),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Код придёт в ВКонтакте',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Напишите боту Edium в ВК',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF999999),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.open_in_new,
                                      size: 16, color: Color(0xFFBBBBBB)),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Кнопка отправки
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
                                  : const Text('Получить код'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Center(
                            child: Text(
                              'Нажимая кнопку, вы соглашаетесь\nс условиями использования',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFAAAAAA),
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}
