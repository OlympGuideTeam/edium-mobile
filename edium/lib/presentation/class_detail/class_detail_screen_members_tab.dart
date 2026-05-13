part of 'class_detail_screen.dart';

class _MembersTab extends StatefulWidget {
  final List<MemberShort> members;
  final bool isOwner;
  final String role;
  final RefreshCallback onRefresh;

  const _MembersTab({
    required this.members,
    required this.isOwner,
    required this.role,
    required this.onRefresh,
  });

  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  late List<MemberShort> _members;

  @override
  void initState() {
    super.initState();
    _members = List.of(widget.members);
  }

  @override
  void didUpdateWidget(_MembersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.members != widget.members) {
      _members = List.of(widget.members);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = widget.isOwner;
    final canInvite = widget.isOwner;

    return Column(
      children: [
        Expanded(
          child: _members.isEmpty
              ? EdiumRefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 280,
                        child: Center(
                          child: Text(
                            widget.role == 'student'
                                ? 'Учеников пока нет'
                                : 'Учителей пока нет',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.mono400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : EdiumRefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.screenPaddingH,
                      16,
                      AppDimens.screenPaddingH,
                      16,
                    ),
                    itemCount: _members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final member = _members[i];
                      final initial = member.name.isNotEmpty
                          ? member.name[0].toUpperCase()
                          : (member.surname.isNotEmpty
                              ? member.surname[0].toUpperCase()
                              : '?');

                      final tile = Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusLg),
                          border: Border.all(
                            color: AppColors.mono150,
                            width: AppDimens.borderWidth,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.mono100,
                                borderRadius:
                                    BorderRadius.circular(AppDimens.radiusMd),
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mono600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                member.fullName,
                                style: AppTextStyles.fieldText.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );

                      if (!canDelete) return tile;

                      return _buildDismissible(
                        key: ValueKey(member.id),
                        confirmDismiss: (_) => _confirmRemoveMember(
                          context,
                          member.fullName,
                        ),
                        onDismissed: () {
                          setState(() => _members.removeAt(i));
                          context
                              .read<ClassDetailBloc>()
                              .add(RemoveMemberEvent(member.id));
                        },
                        child: tile,
                      );
                    },
                  ),
                ),
        ),
        if (canInvite)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPaddingH,
              0,
              AppDimens.screenPaddingH,
              12,
            ),
            child: SizedBox(
              width: double.infinity,
              height: AppDimens.buttonH,
              child: ElevatedButton(
                onPressed: () => context
                    .read<ClassDetailBloc>()
                    .add(GetInviteLinkEvent(widget.role)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mono900,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                  textStyle: AppTextStyles.primaryButton,
                ),
                child: const Text('Пригласить'),
              ),
            ),
          ),
      ],
    );
  }

  Future<bool?> _confirmRemoveMember(
    BuildContext context,
    String memberName,
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
                Text(
                  widget.role == 'teacher'
                      ? 'Удалить учителя?'
                      : 'Удалить ученика?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Вы уверены, что хотите удалить $memberName из класса?',
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
}


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

