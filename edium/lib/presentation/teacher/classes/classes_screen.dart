import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/class_summary.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/shared/widgets/search_bar_widget.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_bloc.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_event.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ClassesScreen extends StatelessWidget {
  final String role;

  const ClassesScreen({super.key, this.role = 'teacher'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClassesBloc(
        getMyClasses: getIt(),
        createClass: getIt(),
        deleteClass: getIt(),
        role: role,
      )..add(const LoadClassesEvent()),
      child: _ClassesView(role: role),
    );
  }
}

class _ClassesView extends StatelessWidget {
  final String role;

  const _ClassesView({required this.role});

  void _showCreateClassDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Новый класс',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBBBBB), width: 1.5),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  cursorColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
                  decoration: const InputDecoration(
                    hintText: 'Например, 7А — Математика',
                    hintStyle: TextStyle(fontSize: 15, color: Color(0xFFBBBBBB)),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final title = controller.text.trim();
                    if (title.isEmpty) return;
                    context.read<ClassesBloc>().add(CreateClassEvent(title));
                    Navigator.of(bottomSheetContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Создать'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDeleteClass(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          title: Text(
            'Удалить класс?',
            style: AppTextStyles.heading3.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.mono900,
            ),
          ),
          content: Text(
            'Класс «$title» будет удалён. Это действие необратимо.',
            style: AppTextStyles.screenSubtitle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Отмена',
                style: AppTextStyles.secondaryButton.copyWith(
                  color: AppColors.mono400,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Удалить',
                style: AppTextStyles.secondaryButton.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = role == 'teacher';

    return BlocListener<ClassesBloc, ClassesState>(
      listener: (context, state) {
        if (state is ClassCreated) {
          EdiumNotification.show(context, 'Класс создан');
        } else if (state is ClassDeleted) {
          EdiumNotification.show(context, 'Класс удалён');
        } else if (state is ClassCreateError) {
          EdiumNotification.show(context, state.message, type: EdiumNotificationType.error);
        } else if (state is ClassDeleteError) {
          EdiumNotification.show(context, state.message, type: EdiumNotificationType.error);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mono900,
                        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                      ),
                      child: Text(
                        isTeacher ? 'УЧИТЕЛЬ' : 'УЧЕНИК',
                        style: AppTextStyles.badgeText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Классы',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        if (isTeacher)
                          IconButton(
                            onPressed: () => _showCreateClassDialog(context),
                            icon: const Icon(Icons.add, size: 26),
                            color: const Color(0xFF1A1A1A),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Поиск
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SearchBarWidget(
                  hint: 'Найти класс...',
                  onChanged: (q) => context
                      .read<ClassesBloc>()
                      .add(SearchClassesEvent(q)),
                ),
              ),
              const SizedBox(height: 16),
              // Список
              Expanded(
                child: BlocBuilder<ClassesBloc, ClassesState>(
                  builder: (context, state) {
                    if (state is ClassesLoading || state is ClassesInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1A1A1A),
                          strokeWidth: 2,
                        ),
                      );
                    }
                    if (state is ClassesError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Ошибка загрузки',
                              style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => context
                                  .read<ClassesBloc>()
                                  .add(const LoadClassesEvent()),
                              child: const Text(
                                'Повторить',
                                style: TextStyle(color: Color(0xFF1A1A1A)),
                              ),
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
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF888888),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: loaded.filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = loaded.filtered[i];
                        final tile = _ClassTile(
                          classSummary: item,
                          isTeacher: isTeacher,
                        );

                        if (!item.isOwner) return tile;

                        return _buildDismissible(
                          key: ValueKey(item.id),
                          confirmDismiss: (_) =>
                              _confirmDeleteClass(context, item.title),
                          onDismissed: () {
                            context
                                .read<ClassesBloc>()
                                .add(DeleteClassEvent(item.id));
                          },
                          child: tile,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassTile extends StatelessWidget {
  final ClassSummary classSummary;
  final bool isTeacher;

  const _ClassTile({
    required this.classSummary,
    required this.isTeacher,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = isTeacher && classSummary.isOwner;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () async {
          await context.push('/class/${classSummary.id}');
          if (context.mounted) {
            context.read<ClassesBloc>().add(const LoadClassesEvent());
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isOwner ? const Color(0xFF60A5FA) : const Color(0xFFDDDDDD),
              width: isOwner ? 2.0 : 1.5,
            ),
          ),
          child: Row(
            children: [
              // Иконка
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🏫', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              // Текст
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            classSummary.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_studentLabel(classSummary.studentCount)}  ·  ${classSummary.ownerName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCCCCC),
                size: 20,
              ),
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

/// Обёртка для Dismissible как на экране создания курса: без зазоров, только иконка.
Widget _buildDismissible({
  required Key key,
  required Widget child,
  required VoidCallback onDismissed,
  Future<bool?> Function(DismissDirection direction)? confirmDismiss,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
    child: Container(
      color: AppColors.error,
      child: Dismissible(
        key: key,
        direction: DismissDirection.endToStart,
        confirmDismiss: confirmDismiss,
        onDismissed: (_) => onDismissed(),
        background: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 18,
          ),
        ),
        child: child,
      ),
    ),
  );
}
