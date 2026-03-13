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

  bool get _isValid => _controller.text.replaceAll(RegExp(r'\D'), '').length >= 10;

  void _submit() {
    if (!_isValid) {
      setState(() => _error = 'Введите корректный номер телефона');
      return;
    }
    setState(() => _error = null);
    final phone = '+7${_controller.text.replaceAll(RegExp(r'\D'), '').substring(
          _controller.text.replaceAll(RegExp(r'\D'), '').length >= 11 ? 1 : 0,
        )}';
    getIt<AuthBloc>().add(SendOtpEvent(phone));
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
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text('Введите номер\nтелефона', style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    Text(
                      'Мы отправим вам код для входа',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _error != null
                              ? AppColors.error
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: const BoxDecoration(
                              border: Border(
                                  right: BorderSide(color: AppColors.cardBorder)),
                            ),
                            child: Text('+7',
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w600)),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: AppTextStyles.body,
                              onChanged: (_) => setState(() => _error = null),
                              decoration: InputDecoration(
                                hintText: '(999) 000-00-00',
                                hintStyle: AppTextStyles.body
                                    .copyWith(color: AppColors.textSecondary),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
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
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.error),
                      ),
                    ],
                    const Spacer(),
                    EdiumButton(
                      label: 'Получить код',
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 32),
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
