import 'package:edium/core/config/api_config.dart';
import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:flutter/gestures.dart';
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
String _cleanPhoneInput(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 11 &&
      (digits.startsWith('7') || digits.startsWith('8'))) {
    digits = digits.substring(1);
  }
  if (digits.length > 10) digits = digits.substring(0, 10);
  return digits;
}

/// Возвращает 10 цифр номера РФ из произвольного текста или null, если цифр меньше 10.
String? _parseClipboardPhone(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final digits = _cleanPhoneInput(raw);
  return digits.length == 10 ? digits : null;
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _cleanPhoneInput(newValue.text);
    final formatted = _formatPhoneDigits(digits);

    var rawCursor = newValue.selection.baseOffset;
    var digitCount = 0;
    for (var i = 0; i < rawCursor && i < newValue.text.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(newValue.text[i])) digitCount++;
    }

    final rawDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (rawDigits.length == 11 &&
        (rawDigits.startsWith('7') || rawDigits.startsWith('8'))) {
      digitCount = (digitCount - 1).clamp(0, 10);
    }
    digitCount = digitCount.clamp(0, digits.length);

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
  final _phoneFocus = FocusNode();
  String? _error;
  /// 10 цифр из буфера, если там есть полный номер и он ещё не совпадает с полем.
  String? _pasteSuggestionDigits;
  late final TapGestureRecognizer _privacyTap;
  late final TapGestureRecognizer _termsTap;

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(_onPhoneFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshClipboardSuggestion();
    });
    _privacyTap = TapGestureRecognizer()
      ..onTap = () {
        if (!mounted) return;
        context.push(
          '/legal-document?url=${Uri.encodeComponent(_privacyUrl)}'
          '&title=${Uri.encodeComponent('Политика конфиденциальности')}',
        );
      };
    _termsTap = TapGestureRecognizer()
      ..onTap = () {
        if (!mounted) return;
        context.push(
          '/legal-document?url=${Uri.encodeComponent(_termsUrl)}'
          '&title=${Uri.encodeComponent('Условия использования')}',
        );
      };
  }

  @override
  void dispose() {
    _phoneFocus.removeListener(_onPhoneFocusChange);
    _phoneFocus.dispose();
    _privacyTap.dispose();
    _termsTap.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onPhoneFocusChange() {
    if (_phoneFocus.hasFocus) {
      _refreshClipboardSuggestion();
    }
  }

  Future<void> _refreshClipboardSuggestion() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final fromClipboard = _parseClipboardPhone(data?.text);
    setState(() {
      _pasteSuggestionDigits =
          (fromClipboard != null && fromClipboard != _digits)
              ? fromClipboard
              : null;
    });
  }

  void _applyPasteFromClipboard() {
    final digits = _pasteSuggestionDigits;
    if (digits == null || digits.length != 10) return;
    final formatted = _formatPhoneDigits(digits);
    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {
      _pasteSuggestionDigits = null;
      _error = null;
    });
  }

  /// По тапу — на iOS буфер доступен; фоновое чтение без жеста часто пустое.
  Future<void> _pasteFromClipboardOnTap() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text;
    if (text == null || text.trim().isEmpty) {
      EdiumNotification.show(context, 'Буфер обмена пуст');
      return;
    }
    final digits = _parseClipboardPhone(text);
    if (digits != null) {
      final formatted = _formatPhoneDigits(digits);
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      setState(() {
        _pasteSuggestionDigits = null;
        _error = null;
      });
      return;
    }
    EdiumNotification.show(
      context,
      'Не удалось распознать номер — скопируйте 10 цифр или +7…',
      type: EdiumNotificationType.error,
    );
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
    getIt<AuthBloc>().add(SendOtpEvent(phone, channel: 'sms'));
  }

  void _submitTelegram() {
    if (!_isValid) {
      setState(() => _error = 'Введите корректный номер телефона');
      return;
    }
    setState(() => _error = null);
    final phone = '+7$_digits';
    getIt<AuthBloc>().add(SendOtpEvent(phone, channel: 'tg'));
  }

  Future<void> _openTelegramBot() async {
    final uri = Uri.parse('https://t.me/${ApiConfig.telegramBotUsername}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static const _privacyUrl = 'https://edium.online/privacy/';
  static const _termsUrl = 'https://edium.online/terms/';

  Widget _legalConsentRichText() {
    final baseStyle = AppTextStyles.helperText.copyWith(
      color: AppColors.mono250,
    );
    final linkStyle = baseStyle.copyWith(
      color: AppColors.mono350,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.mono350,
    );
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(
            text: 'Нажимая кнопку, вы соглашаетесь с ',
          ),
          TextSpan(
            text: 'Политикой конфиденциальности',
            style: linkStyle,
            recognizer: _privacyTap,
          ),
          const TextSpan(text: ' и '),
          TextSpan(
            text: 'Условиями использования',
            style: linkStyle,
            recognizer: _termsTap,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (ModalRoute.of(context)?.isCurrent != true) return;
          if (state is AuthOtpSent) {
            TextInput.finishAutofillContext();
            context.push(
              '/otp?phone=${Uri.encodeComponent(state.phone)}&channel=${state.channel}&retryAfter=${state.retryAfter}',
            );
            if (state.channel == 'tg') _openTelegramBot();
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
              resizeToAvoidBottomInset: true,
              body: SafeArea(
                maintainBottomViewPadding: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Кнопка назад
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            size: 20, color: AppColors.mono900),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.screenPaddingH),
                        child: AutofillGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            const SizedBox(height: 8),
                            const Text('Войти в Edium',
                                style: AppTextStyles.screenTitle),
                            const SizedBox(height: 6),
                            const Text(
                              'Введите номер телефона и выберите\nспособ получения кода',
                              style: AppTextStyles.screenSubtitle,
                            ),
                            const SizedBox(height: 28),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Номер телефона',
                                    style: AppTextStyles.fieldLabel,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _pasteFromClipboardOnTap,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Вставить',
                                    style: AppTextStyles.fieldLabel.copyWith(
                                      color: AppColors.mono700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_pasteSuggestionDigits != null) ...[
                              const SizedBox(height: 8),
                              Material(
                                color: AppColors.mono150.withValues(alpha: 0.45),
                                borderRadius:
                                    BorderRadius.circular(AppDimens.radiusMd),
                                child: InkWell(
                                  onTap: _applyPasteFromClipboard,
                                  borderRadius:
                                      BorderRadius.circular(AppDimens.radiusMd),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.content_paste_rounded,
                                          size: 20,
                                          color: AppColors.mono700,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Вставить номер из буфера обмена',
                                            style: AppTextStyles.helperText
                                                .copyWith(
                                              color: AppColors.mono700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatPhoneDigits(
                                              _pasteSuggestionDigits!),
                                          style: AppTextStyles.fieldText
                                              .copyWith(
                                            letterSpacing: 0.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            // Поле ввода телефона
                            Container(
                              height: AppDimens.inputH,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppDimens.radiusMd),
                                border: Border.all(
                                  color: _error != null
                                      ? AppColors.error
                                      : AppColors.mono250,
                                  width: AppDimens.borderWidth,
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
                                            color: AppColors.mono700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    color: AppColors.mono150,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      focusNode: _phoneFocus,
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [
                                        AutofillHints.telephoneNumber,
                                      ],
                                      cursorColor: AppColors.mono900,
                                      inputFormatters: [
                                        _PhoneInputFormatter(),
                                      ],
                                      style: AppTextStyles.fieldText.copyWith(
                                        letterSpacing: 0.5,
                                      ),
                                      onChanged: (_) {
                                        setState(() {
                                          _error = null;
                                          if (_pasteSuggestionDigits != null &&
                                              _digits ==
                                                  _pasteSuggestionDigits) {
                                            _pasteSuggestionDigits = null;
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: '900 000 00 00',
                                        hintStyle:
                                            AppTextStyles.fieldHint.copyWith(
                                          letterSpacing: 0.5,
                                        ),
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 4),
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
                                    fontSize: 12, color: AppColors.error),
                              ),
                            ],
                            const Spacer(),
                            // Кнопка "Получить код в TG"
                            SizedBox(
                              width: double.infinity,
                              height: AppDimens.buttonH,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submitTelegram,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF53A5E3),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors.mono200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppDimens.radiusLg),
                                  ),
                                  elevation: 0,
                                  textStyle: AppTextStyles.primaryButton,
                                ),
                                child: const Text('Получить код в TG'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Кнопка "Получить код" (SMS)
                            SizedBox(
                              width: double.infinity,
                              height: AppDimens.buttonH,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.mono900,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors.mono200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppDimens.radiusLg),
                                  ),
                                  elevation: 0,
                                  textStyle: AppTextStyles.primaryButton,
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
                            Center(child: _legalConsentRichText()),
                            const SizedBox(height: 24),
                          ],
                          ),
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

