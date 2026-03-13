import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              // Logo / branding
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 24),
              Text(
                'Edium',
                style: AppTextStyles.heading1.copyWith(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Создавайте квизы, проверяйте знания\nи учитесь эффективно',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white.withAlpha(216),
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              // Feature highlights
              _FeatureRow(
                icon: Icons.quiz_outlined,
                label: 'Интерактивные квизы',
              ),
              const SizedBox(height: 12),
              _FeatureRow(
                icon: Icons.bar_chart_outlined,
                label: 'Детальная статистика',
              ),
              const SizedBox(height: 12),
              _FeatureRow(
                icon: Icons.groups_outlined,
                label: 'Для преподавателей и студентов',
              ),
              const Spacer(flex: 2),
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.push('/phone'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: AppTextStyles.button,
                    elevation: 0,
                  ),
                  child: const Text('Войти'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withAlpha(229),
          ),
        ),
      ],
    );
  }
}
