import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Классы')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EC),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.groups_outlined,
                    size: 48, color: AppColors.secondary),
              ),
              const SizedBox(height: 24),
              Text('Классы', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(
                'Раздел находится в разработке.\nСкоро здесь появится возможность управлять группами студентов.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Chip(
                label: const Text('Скоро'),
                backgroundColor: AppColors.primaryLight,
                side: BorderSide.none,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
