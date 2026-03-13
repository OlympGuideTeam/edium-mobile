import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/presentation/shared/widgets/edium_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final _nameCtrl = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() {
      setState(() => _canSubmit = _nameCtrl.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    context.read<AuthBloc>().add(NameSubmittedEvent(name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 1),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person_outline,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 24),
              Text(
                'Как вас зовут?',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 8),
              Text(
                'Введите своё имя — оно будет отображаться в приложении',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              EdiumTextField(
                label: 'Имя',
                hint: 'Например: Алексей',
                controller: _nameCtrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _canSubmit ? _submit() : null,
              ),
              const Spacer(flex: 2),
              EdiumButton(
                label: 'Продолжить',
                onPressed: _canSubmit ? _submit : null,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
