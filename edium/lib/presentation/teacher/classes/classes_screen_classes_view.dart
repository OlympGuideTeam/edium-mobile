part of 'classes_screen.dart';

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
                  border:
                      Border.all(color: const Color(0xFFBBBBBB), width: 1.5),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  cursorColor: const Color(0xFF1A1A1A),
                  style:
                      const TextStyle(fontSize: 15, color: Color(0xFF333333)),
                  decoration: const InputDecoration(
                    hintText: 'Например, 7А — Математика',
                    hintStyle:
                        TextStyle(fontSize: 15, color: Color(0xFFBBBBBB)),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Удалить класс?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Класс «$title» будет удалён. Это действие необратимо.',
                  style: const TextStyle(
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
                    onPressed: () => Navigator.of(dialogContext).pop(true),
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
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonHSm,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
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
          EdiumNotification.show(context, state.message,
              type: EdiumNotificationType.error);
        } else if (state is ClassDeleteError) {
          EdiumNotification.show(context, state.message,
              type: EdiumNotificationType.error);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.mono900,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusXs),
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SearchBarWidget(
                    hint: 'Найти класс...',
                    onChanged: (q) =>
                        context.read<ClassesBloc>().add(SearchClassesEvent(q)),
                  ),
                ),
                const SizedBox(height: 16),

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
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xFF888888)),
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
                      return EdiumRefreshIndicator(
                        onRefresh: () async {
                          final bloc = context.read<ClassesBloc>();
                          bloc.add(const LoadClassesEvent());
                          await bloc.stream.firstWhere(
                              (s) => s is ClassesLoaded || s is ClassesError);
                        },
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: loaded.filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
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
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

