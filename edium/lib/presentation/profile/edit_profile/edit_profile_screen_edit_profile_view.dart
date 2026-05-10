part of 'edit_profile_screen.dart';

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
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Выйти из аккаунта?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Вы будете перенаправлены на экран входа.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mono600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHSm,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    getIt<AuthBloc>().add(const LogoutEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mono900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Выйти',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHSm,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.mono150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                  ),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mono700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Удалить аккаунт?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Это действие необратимо. Все данные будут удалены.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mono600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHSm,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    parentContext.read<EditProfileBloc>().add(const DeleteAccountEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mono900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Удалить',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHSm,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.mono150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                  ),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mono700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

