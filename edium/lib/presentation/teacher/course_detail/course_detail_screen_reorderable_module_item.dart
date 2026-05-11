part of 'course_detail_screen.dart';

class _ReorderableModuleItem extends StatelessWidget {
  final ModuleDetail module;
  final int index;
  final bool isTeacher;
  final String courseId;
  final String? classId;
  final int moduleListReloadToken;
  final Future<void> Function()? onReload;

  const _ReorderableModuleItem({
    super.key,
    required this.module,
    required this.index,
    required this.isTeacher,
    required this.courseId,
    this.classId,
    this.moduleListReloadToken = 0,
    this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableDelayedDragStartListener(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _ModuleSection(
          module: module,
          isTeacher: isTeacher,
          courseId: courseId,
          classId: classId,
          moduleListReloadToken: moduleListReloadToken,
          onReload: onReload,
        ),
      ),
    );
  }
}

