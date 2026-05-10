part of 'review_session_screen.dart';

class _ViewBody extends StatelessWidget {
  final String sessionId;
  final String quizTitle;

  const _ViewBody({required this.sessionId, required this.quizTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(title: quizTitle),
            Expanded(
              child: BlocBuilder<_Cubit, _State>(
                builder: (context, state) => switch (state) {
                  _Loading() => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mono700,
                        strokeWidth: 2,
                      ),
                    ),
                  _Error(:final message) => _ErrorBody(
                      message: message,
                      onRetry: () => context.read<_Cubit>().refresh(),
                    ),
                  _Published() => const Center(child: SizedBox.shrink()),
                  _Loaded(:final attempts, :final isPublishing, :final publishError) =>
                    _LoadedBody(
                      sessionId: sessionId,
                      onRefresh: () => context.read<_Cubit>().refresh(),
                      state: _Loaded(
                        attempts,
                        isPublishing: isPublishing,
                        publishError: publishError,
                      ),
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

