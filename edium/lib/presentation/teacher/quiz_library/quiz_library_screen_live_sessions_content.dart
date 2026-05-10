part of 'quiz_library_screen.dart';

class _LiveSessionsContent extends StatelessWidget {
  final ValueChanged<LiveLibrarySession> onTap;

  const _LiveSessionsContent({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveLibraryCubit, LiveLibraryState>(
      builder: (context, state) {
        if (state is LiveLibraryInitial || state is LiveLibraryLoading) {
          return const Center(
            child: CircularProgressIndicator(
                color: AppColors.mono700, strokeWidth: 2),
          );
        }
        if (state is LiveLibraryError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.mono400, size: 48),
                const SizedBox(height: 12),
                Text(state.message, style: AppTextStyles.screenSubtitle),
              ],
            ),
          );
        }
        if (state is LiveLibraryLoaded) {
          if (state.sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_outlined,
                      size: 48, color: AppColors.mono200),
                  const SizedBox(height: 12),
                  Text('Нет лайв-сессий',
                      style: AppTextStyles.fieldText
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Создайте квиз и запустите лайв',
                      style: AppTextStyles.screenSubtitle),
                ],
              ),
            );
          }
          return EdiumRefreshIndicator(
            onRefresh: () => context.read<LiveLibraryCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPaddingH, 8, AppDimens.screenPaddingH, 24),
              itemCount: state.sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _LiveSessionCard(
                session: state.sessions[i],
                onTap: () => onTap(state.sessions[i]),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

