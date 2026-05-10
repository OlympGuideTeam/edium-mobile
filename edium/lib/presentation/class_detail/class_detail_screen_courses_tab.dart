part of 'class_detail_screen.dart';

class _CoursesTab extends StatelessWidget {
  final List<CourseSummary> courses;
  final bool isOwner;
  final RefreshCallback onRefresh;

  const _CoursesTab({
    required this.courses,
    required this.isOwner,
    required this.onRefresh,
  });

  Future<bool?> _confirmDeleteCourse(
    BuildContext context,
    String title,
  ) {
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
                  'Удалить курс?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Курс «$title» будет удалён. Это действие необратимо.',
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
    return Column(
      children: [
        Expanded(
          child: courses.isEmpty
              ? EdiumRefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 280,
                        child: Center(
                          child: Text(
                            'Курсов пока нет',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.mono400),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : EdiumRefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.screenPaddingH,
                      16,
                      AppDimens.screenPaddingH,
                      16,
                    ),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final course = courses[i];
                      final card = _CourseCard(course: course);
                      final canDelete = isOwner && course.isTeacher;

                      if (!canDelete) return card;

                      return _buildDismissible(
                        key: ValueKey(course.id),
                        confirmDismiss: (_) =>
                            _confirmDeleteCourse(context, course.title),
                        onDismissed: () {
                          context
                              .read<ClassDetailBloc>()
                              .add(DeleteCourseEvent(course.id));
                        },
                        child: card,
                      );
                    },
                  ),
                ),
        ),
        if (isOwner)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPaddingH,
              0,
              AppDimens.screenPaddingH,
              24,
            ),
            child: SizedBox(
              width: double.infinity,
              height: AppDimens.buttonH,
              child: ElevatedButton(
                onPressed: () async {
                  final bloc = context.read<ClassDetailBloc>();
                  final courseId = await context.push<String>(
                    '/course/create?classId=${bloc.classId}',
                  );
                  if (courseId != null && context.mounted) {
                    bloc.add(LoadClassDetailEvent(bloc.classId));
                    context.push(
                      '/course/$courseId',
                      extra: {'classId': bloc.classId},
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mono900,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                  textStyle: AppTextStyles.primaryButton,
                ),
                child: const Text('Создать курс'),
              ),
            ),
          ),
      ],
    );
  }
}

