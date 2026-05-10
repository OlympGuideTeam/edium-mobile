part of 'courses_screen.dart';

class _CourseSection extends StatelessWidget {
  final CourseSummary course;
  final bool isExpanded;
  final bool isLoading;
  final CourseDetail? detail;
  final VoidCallback onToggle;
  final void Function(String moduleId) onAddQuiz;

  const _CourseSection({
    required this.course,
    required this.isExpanded,
    required this.isLoading,
    required this.detail,
    required this.onToggle,
    required this.onAddQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.mono50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.mono100),
                  ),
                  child: const Icon(Icons.school_outlined,
                      size: 16, color: AppColors.mono400),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mono900,
                        ),
                      ),
                      Text(
                        '${_modulesLabel(course.moduleCount)}  ·  ${_quizzesLabel(course.elementCount)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.mono400),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.mono700),
                  )
                else
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        size: 20, color: AppColors.mono400),
                  ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOut,
          child: isExpanded && detail != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: detail!.modules
                      .map((module) => _ModuleSection(
                            module: module,
                            onAddQuiz: () => onAddQuiz(module.id),
                          ))
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
        const Divider(height: 1, color: AppColors.mono100),
      ],
    );
  }

  String _modulesLabel(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return '$count модулей';
    switch (count % 10) {
      case 1:
        return '$count модуль';
      case 2:
      case 3:
      case 4:
        return '$count модуля';
      default:
        return '$count модулей';
    }
  }

  String _quizzesLabel(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return '$count элементов';
    switch (count % 10) {
      case 1:
        return '$count элемент';
      case 2:
      case 3:
      case 4:
        return '$count элемента';
      default:
        return '$count элементов';
    }
  }
}

