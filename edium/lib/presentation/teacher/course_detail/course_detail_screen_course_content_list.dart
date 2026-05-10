part of 'course_detail_screen.dart';

class _CourseContentList extends StatefulWidget {
  final CourseDetail course;
  final void Function(CourseDraft draft) onDraftTap;
  final void Function(CourseDraft draft) onDraftDelete;
  final void Function(List<String> moduleIds) onModulesReorder;
  final RefreshCallback? onRefresh;

  const _CourseContentList({
    required this.course,
    required this.onDraftTap,
    required this.onDraftDelete,
    required this.onModulesReorder,
    this.onRefresh,
  });

  @override
  State<_CourseContentList> createState() => _CourseContentListState();
}

class _CourseContentListState extends State<_CourseContentList> {

  int _moduleListReloadToken = 0;

  Future<void> _onPullRefresh() async {
    if (widget.onRefresh == null) return;
    await widget.onRefresh!();
    if (mounted) setState(() => _moduleListReloadToken++);
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final modules = course.modules;
    final drafts = course.drafts;
    final canReorder = course.isTeacher && modules.length > 1;

    final scrollView = CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPaddingH,
            8,
            AppDimens.screenPaddingH,
            0,
          ),
          sliver: canReorder
              ? SliverReorderableList(
                  itemCount: modules.length,
                  proxyDecorator: (child, index, animation) => Material(
                    elevation: 4,
                    color: Colors.transparent,
                    shadowColor: Colors.black12,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    child: child,
                  ),
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final ids = modules.map((m) => m.id).toList();
                    final moved = ids.removeAt(oldIndex);
                    ids.insert(newIndex, moved);
                    widget.onModulesReorder(ids);
                  },
                  itemBuilder: (context, i) {
                    final module = modules[i];
                    return _ReorderableModuleItem(
                      key: ValueKey(module.id),
                      module: module,
                      index: i,
                      isTeacher: course.isTeacher,
                      courseId: course.id,
                      moduleListReloadToken: _moduleListReloadToken,
                      onReload: _onPullRefresh,
                    );
                  },
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final module = modules[i];
                      return Padding(
                        key: ValueKey(module.id),
                        padding: const EdgeInsets.only(top: 12),
                        child: _ModuleSection(
                          module: module,
                          isTeacher: course.isTeacher,
                          courseId: course.id,
                          moduleListReloadToken: _moduleListReloadToken,
                          onReload: _onPullRefresh,
                        ),
                      );
                    },
                    childCount: modules.length,
                  ),
                ),
        ),
        if (drafts.isNotEmpty && course.isTeacher) ...[
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.screenPaddingH,
              20,
              AppDimens.screenPaddingH,
              4,
            ),
            sliver: SliverToBoxAdapter(child: _DraftsSectionHeader()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPaddingH,
              0,
              AppDimens.screenPaddingH,
              24,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final draft = drafts[i];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _DismissibleDraftTile(
                      key: ValueKey(draft.id),
                      draft: draft,
                      onTap: () => widget.onDraftTap(draft),
                      onDelete: () => widget.onDraftDelete(draft),
                    ),
                  );
                },
                childCount: drafts.length,
              ),
            ),
          ),
        ] else
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 24),
            sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
      ],
    );
    if (widget.onRefresh != null) {
      return EdiumRefreshIndicator(
        onRefresh: _onPullRefresh,
        child: scrollView,
      );
    }
    return scrollView;
  }
}

