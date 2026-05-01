import 'package:edium/core/di/injection.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/profile/edit_profile/bloc/edit_profile_bloc.dart';
import 'package:edium/presentation/profile/edit_profile/bloc/edit_profile_event.dart';
import 'package:edium/presentation/profile/edit_profile/bloc/edit_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends StatelessWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileBloc(
        updateProfile: getIt(),
        deleteAccount: getIt(),
        initialState: EditProfileInitial(user),
      ),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    final state = context.read<EditProfileBloc>().state as EditProfileInitial;
    _firstNameController = TextEditingController(text: state.user.name);
    _lastNameController = TextEditingController(text: state.user.surname ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<EditProfileBloc, EditProfileState>(
          listener: (context, state) {
            if (state is EditProfileSuccess) {
              EdiumNotification.show(context, 'Профиль обновлён');
              context.pop(true);
            }
            if (state is EditProfileDeleted) {
              getIt<AuthBloc>().add(const LogoutEvent());
            }
            if (state is EditProfileError) {
              EdiumNotification.show(context, state.message, type: EdiumNotificationType.error);
            }
          },
          builder: (context, state) {
            final isLoading = state is EditProfileLoading;
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: AppColors.mono900,
                      ),
                      alignment: Alignment.centerLeft,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) => SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 8),
                                  const Text('Редактирование', style: AppTextStyles.screenTitle),
                                  const SizedBox(height: 32),
                                  const Text('Имя', style: AppTextStyles.fieldLabel),
                                  const SizedBox(height: 8),
                                  _InputField(
                                    controller: _firstNameController,
                                    hint: 'Введите имя',
                                    enabled: !isLoading,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Фамилия', style: AppTextStyles.fieldLabel),
                                  const SizedBox(height: 8),
                                  _InputField(
                                    controller: _lastNameController,
                                    hint: 'Введите фамилию',
                                    enabled: !isLoading,
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _onSave,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.mono900,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: AppColors.mono200,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 0,
                                        textStyle: AppTextStyles.primaryButton,
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text('Сохранить'),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 48,
                                    child: OutlinedButton(
                                      onPressed: isLoading ? null : () => _showLogoutDialog(context),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: AppColors.mono50,
                                        foregroundColor: AppColors.mono600,
                                        side: const BorderSide(color: AppColors.mono150),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 0,
                                        textStyle: AppTextStyles.secondaryButton,
                                      ),
                                      child: const Text('Выйти из аккаунта'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: isLoading ? null : () => _showDeleteDialog(context),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      textStyle: AppTextStyles.secondaryButton,
                                    ),
                                    child: const Text('Удалить аккаунт'),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onSave() {
    final name = _firstNameController.text.trim();
    final surname = _lastNameController.text.trim();
    if (name.isEmpty || surname.isEmpty) return;
    context.read<EditProfileBloc>().add(UpdateProfileEvent(name: name, surname: surname));
  }

  void _showLogoutDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Выйти из аккаунта?',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 17),
        ),
        content: const Text(
          'Вы будете перенаправлены на экран входа.',
          style: AppTextStyles.screenSubtitle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.mono600),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              getIt<AuthBloc>().add(const LogoutEvent());
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mono900,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Удалить аккаунт?',
          style: AppTextStyles.screenTitle.copyWith(fontSize: 17),
        ),
        content: const Text(
          'Это действие необратимо. Все данные будут удалены.',
          style: AppTextStyles.screenSubtitle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.mono600),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              parentContext.read<EditProfileBloc>().add(const DeleteAccountEvent());
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;

  const _InputField({
    required this.controller,
    required this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? AppColors.mono250 : AppColors.mono150,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
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
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
