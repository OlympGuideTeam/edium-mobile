part of 'course_detail_screen.dart';

class _CourseDetailView extends StatelessWidget {
  final String? classId;
  const _CourseDetailView({this.classId});

  CourseDetail? _extractCourse(CourseDetailState state) {
    if (state is CourseDetailLoaded) return state.course;
    if (state is CourseModuleCreated) return state.course;
    if (state is CourseDetailActionError) return state.course;
    if (state is CourseDraftDeleted) return state.course;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourseDetailBloc, CourseDetailState>(
      listener: (context, state) {
        if (state is CourseModuleCreated) {
          EdiumNotification.show(context, 'Модуль создан');
        } else if (state is CourseDraftDeleted) {
          EdiumNotification.show(context, 'Черновик удалён');
        } else if (state is CourseDetailActionError) {
          EdiumNotification.show(
            context,
            state.message,
            type: EdiumNotificationType.error,
          );
        }
      },
      builder: (context, state) {
        if (state is CourseDetailLoading || state is CourseDetailInitial) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _AppBar(onBack: () => context.pop()),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mono900,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is CourseDetailError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _AppBar(onBack: () => context.pop()),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Ошибка загрузки',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mono400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              final bloc = context.read<CourseDetailBloc>();
                              bloc.add(LoadCourseDetailEvent(bloc.courseId));
                            },
                            child: const Text(
                              'Повторить',
                              style: TextStyle(color: AppColors.mono900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final course = _extractCourse(state);
        if (course == null) return const SizedBox.shrink();

        return _CourseDetailBody(course: course, classId: classId);
      },
    );
  }
}

