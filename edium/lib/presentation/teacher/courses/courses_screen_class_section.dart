part of 'courses_screen.dart';

class _ClassSection extends StatelessWidget {
  final ClassSummary cls;
  final bool isExpanded;
  final bool isLoading;
  final ClassDetail? detail;
  final VoidCallback onToggle;
  final Set<String> expandedCourses;
  final Set<String> loadingCourses;
  final Map<String, CourseDetail> courseDetails;
  final Future<void> Function(String courseId) onToggleCourse;
  final void Function(String moduleId) onAddQuiz;

  const _ClassSection({
    required this.cls,
    required this.isExpanded,
    required this.isLoading,
    required this.detail,
    required this.onToggle,
    required this.expandedCourses,
    required this.loadingCourses,
    required this.courseDetails,
    required this.onToggleCourse,
    required this.onAddQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: isExpanded ? AppColors.mono900 : AppColors.mono150,
          width: AppDimens.borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(AppDimens.radiusLg - AppDimens.borderWidth),
        child: Column(
          children: [

            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: isExpanded ? AppColors.mono900 : Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cls.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color:
                                  isExpanded ? Colors.white : AppColors.mono900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${cls.studentCount} ${_studentsLabel(cls.studentCount)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isExpanded
                                  ? Colors.white60
                                  : AppColors.mono400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isExpanded ? Colors.white : AppColors.mono700,
                        ),
                      )
                    else
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 22,
                          color: isExpanded ? Colors.white : AppColors.mono700,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpanded && detail != null
                  ? Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(height: 1, color: AppColors.mono100),
                          if (detail!.courses.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              child: Text(
                                'Курсов пока нет',
                                style: TextStyle(
                                    fontSize: 13, color: AppColors.mono300),
                              ),
                            )
                          else
                            ...detail!.courses.map((course) => _CourseSection(
                                  course: course,
                                  isExpanded:
                                      expandedCourses.contains(course.id),
                                  isLoading: loadingCourses.contains(course.id),
                                  detail: courseDetails[course.id],
                                  onToggle: () => onToggleCourse(course.id),
                                  onAddQuiz: onAddQuiz,
                                )),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  String _studentsLabel(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return 'учеников';
    switch (count % 10) {
      case 1:
        return 'ученик';
      case 2:
      case 3:
      case 4:
        return 'ученика';
      default:
        return 'учеников';
    }
  }
}

