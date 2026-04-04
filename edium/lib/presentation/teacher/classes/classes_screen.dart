import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/class_summary.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_bloc.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_event.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassesScreen extends StatelessWidget {
  final String role;

  const ClassesScreen({super.key, this.role = 'teacher'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClassesBloc(
        getMyClasses: getIt(),
        role: role,
      )..add(const LoadClassesEvent()),
      child: _ClassesView(role: role),
    );
  }
}

class _ClassesView extends StatelessWidget {
  final String role;

  const _ClassesView({required this.role});

  @override
  Widget build(BuildContext context) {
    final isTeacher = role == 'teacher';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Классы',
                      style: AppTextStyles.heading2,
                    ),
                  ),
                  if (isTeacher)
                    IconButton(
                      onPressed: () {
                        // TODO: навигация на создание класса
                      },
                      icon: const Icon(Icons.add, size: 28),
                      color: AppColors.textPrimary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Поиск
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (q) =>
                    context.read<ClassesBloc>().add(SearchClassesEvent(q)),
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Найти класс...',
                  hintStyle: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Список
            Expanded(
              child: BlocBuilder<ClassesBloc, ClassesState>(
                builder: (context, state) {
                  if (state is ClassesLoading || state is ClassesInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ClassesError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Ошибка загрузки',
                              style: AppTextStyles.body),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context
                                .read<ClassesBloc>()
                                .add(const LoadClassesEvent()),
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    );
                  }
                  final loaded = state as ClassesLoaded;
                  if (loaded.filtered.isEmpty) {
                    return Center(
                      child: Text(
                        loaded.searchQuery.isNotEmpty
                            ? 'Ничего не найдено'
                            : 'У вас пока нет классов',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: loaded.filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ClassTile(
                      classSummary: loaded.filtered[i],
                      showOwnerBadge: isTeacher,
                    ),
                  );
                },
              ),
            ),
            // Кнопка создания (только для учителя)
            if (isTeacher)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: навигация на создание класса
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      '+ Создать новый класс',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClassTile extends StatelessWidget {
  final ClassSummary classSummary;
  final bool showOwnerBadge;

  const _ClassTile({
    required this.classSummary,
    required this.showOwnerBadge,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = showOwnerBadge && classSummary.isOwner;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          // TODO: навигация на детали класса
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOwner ? AppColors.primary.withAlpha(80) : AppColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              // Иконка
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isOwner ? AppColors.primaryLight : const Color(0xFFFFF3EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    isOwner ? '🏫' : '🏠',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Текст
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classSummary.title,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_studentLabel(classSummary.studentCount)}  ·  ${classSummary.ownerName}',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  String _studentLabel(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return '$count учеников';
    switch (count % 10) {
      case 1:
        return '$count ученик';
      case 2:
      case 3:
      case 4:
        return '$count ученика';
      default:
        return '$count учеников';
    }
  }
}
