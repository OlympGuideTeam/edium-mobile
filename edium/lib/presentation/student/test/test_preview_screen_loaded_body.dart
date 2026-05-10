part of 'test_preview_screen.dart';

class _LoadedBody extends StatelessWidget {
  final TestPreviewLoaded state;
  final String sessionId;
  final String? courseId;
  const _LoadedBody({
    required this.state,
    required this.sessionId,
    this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final meta = state.meta;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(meta.title, style: AppTextStyles.heading2),
                if (meta.description != null &&
                    meta.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(meta.description!,
                      style: AppTextStyles.screenSubtitle),
                ],
                const SizedBox(height: 24),
                _StatusHero(state: state),
                const SizedBox(height: 20),
                _DetailsSection(meta: meta, status: state.status),
                if (meta.hasTimeLimit &&
                    state.status == TestPreviewStatus.start) ...[
                  const SizedBox(height: 16),
                  _WarningBlock(
                    text:
                        'Таймер запустится сразу после нажатия «Начать». Он не остановится, если вы покинете экран.',
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.screenPaddingH,
            0,
            AppDimens.screenPaddingH,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          child: _BottomCta(
            state: state,
            sessionId: sessionId,
            courseId: courseId,
          ),
        ),
      ],
    );
  }
}

