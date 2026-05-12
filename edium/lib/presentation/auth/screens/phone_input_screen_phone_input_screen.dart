part of 'phone_input_screen.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _controller = TextEditingController();
  final _phoneFocus = FocusNode();
  String? _error;
  late final TapGestureRecognizer _privacyTap;
  late final TapGestureRecognizer _termsTap;

  @override
  void initState() {
    super.initState();
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
    _phoneFocus.dispose();
    _privacyTap.dispose();
    _termsTap.dispose();
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
          const TextSpan(text: 'Нажимая кнопку, вы соглашаетесь с '),
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
                              const Text(
                                'Номер телефона',
                                style: AppTextStyles.fieldLabel,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: AppDimens.inputH,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      AppDimens.radiusMd),
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
                                          setState(() => _error = null);
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
