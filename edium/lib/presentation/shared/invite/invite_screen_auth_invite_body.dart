part of 'invite_screen.dart';

class _AuthInviteBody extends StatelessWidget {
  final InvitationDetail detail;
  const _AuthInviteBody({required this.detail});

  String get _roleLabel => detail.role == 'teacher' ? 'учитель' : 'ученик';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            ),
            child: const Icon(
              Icons.group_outlined,
              size: 32,
              color: AppColors.mono700,
            ),
          ),
          const SizedBox(height: 32),
          Text('Вас пригласили\nв класс', style: AppTextStyles.heading1),
          const SizedBox(height: 12),
          Text(
            detail.classTitle,
            style: AppTextStyles.body.copyWith(color: AppColors.mono900),
          ),
          const SizedBox(height: 4),
          Text(
            '${detail.studentCount} учеников · $_roleLabel',
            style: AppTextStyles.body.copyWith(color: AppColors.mono400),
          ),
          const Spacer(),
          _PrimaryButton(
            label: 'Принять',
            onTap: () => context.read<InviteBloc>().add(const InviteAcceptRequested()),
          ),
          const SizedBox(height: 16),
          _SecondaryButton(
            label: 'Отклонить',
            onTap: () => context.read<InviteBloc>().add(const InviteDeclineRequested()),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

