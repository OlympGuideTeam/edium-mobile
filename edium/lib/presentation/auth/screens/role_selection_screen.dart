import 'package:edium/core/di/injection.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selected;
  bool _loading = false;

  Future<void> _confirm() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    await getIt<ProfileStorage>().saveRole(_selected!.name);
    if (!mounted) return;
    getIt<AuthBloc>().add(const RoleSelectedEvent());
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (_, __) {},
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
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
                    child: const Text('ПОСЛЕДНИЙ ШАГ', style: AppTextStyles.badgeText),
                  ),
                  const SizedBox(height: 12),
                  const Text('Кто вы?', style: AppTextStyles.screenTitle),
                  const SizedBox(height: 6),
                  const Text(
                    'Выберите роль — от этого зависит\nинтерфейс приложения',
                    style: AppTextStyles.screenSubtitle,
                  ),
                  const SizedBox(height: 28),
                  _RoleCard(
                    emoji: '👩‍🏫',
                    title: 'Учитель',
                    subtitle: 'Создаю квизы, веду классы',
                    isSelected: _selected == UserRole.teacher,
                    onTap: () => setState(() => _selected = UserRole.teacher),
                  ),
                  const SizedBox(height: 12),
                  _RoleCard(
                    emoji: '🎒',
                    title: 'Ученик',
                    subtitle: 'Прохожу квизы, учусь',
                    isSelected: _selected == UserRole.student,
                    onTap: () => setState(() => _selected = UserRole.student),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimens.buttonH,
                    child: ElevatedButton(
                      onPressed: (_selected == null || _loading) ? null : _confirm,
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
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Начать →'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Роль можно сменить в настройках',
                      style: AppTextStyles.helperText,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.mono25,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.mono700 : AppColors.mono150,
            width: AppDimens.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.mono100,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mono900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mono350,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Text(
                '✓',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
