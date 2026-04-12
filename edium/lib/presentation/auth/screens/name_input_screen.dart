import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameInputScreen extends StatefulWidget {
  final String phone;
  const NameInputScreen({super.key, required this.phone});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_updateCanSubmit);
    _surnameCtrl.addListener(_updateCanSubmit);
  }

  void _updateCanSubmit() {
    setState(() {
      _canSubmit = _nameCtrl.text.trim().isNotEmpty &&
          _surnameCtrl.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final surname = _surnameCtrl.text.trim();
    if (name.isEmpty || surname.isEmpty) return;
    getIt<AuthBloc>().add(RegisterEvent(
      phone: widget.phone,
      name: name,
      surname: surname,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            EdiumNotification.show(context, state.message, type: EdiumNotificationType.error);
          }
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                const SizedBox(height: 56),
                // Тег
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mono900,
                    borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                  ),
                  child: const Text('НОВЫЙ АККАУНТ', style: AppTextStyles.badgeText),
                ),
                const SizedBox(height: 12),
                const Text('Как вас зовут?', style: AppTextStyles.screenTitle),
                const SizedBox(height: 6),
                const Text(
                  'Укажите имя и фамилию — их увидят\nученики и учителя',
                  style: AppTextStyles.screenSubtitle,
                ),
                const SizedBox(height: 28),
                const Text('Имя', style: AppTextStyles.fieldLabel),
                const SizedBox(height: 8),
                _buildTextField(_nameCtrl, 'Иван'),
                const SizedBox(height: 16),
                const Text('Фамилия', style: AppTextStyles.fieldLabel),
                const SizedBox(height: 8),
                _buildTextField(_surnameCtrl, 'Иванов'),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonH,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mono900,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.mono200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      ),
                      elevation: 0,
                      textStyle: AppTextStyles.primaryButton,
                    ),
                    child: const Text('Продолжить'),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Вы сможете изменить имя позже\nв настройках профиля',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.helperText,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      height: AppDimens.inputH,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono250, width: AppDimens.borderWidth),
      ),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        cursorColor: AppColors.mono900,
        style: AppTextStyles.fieldText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.fieldHint,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
