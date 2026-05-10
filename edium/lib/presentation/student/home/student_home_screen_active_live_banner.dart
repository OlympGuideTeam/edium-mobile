part of 'student_home_screen.dart';

class _ActiveLiveBanner extends StatelessWidget {
  final LiveSessionMeta meta;

  const _ActiveLiveBanner({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0x1FFFFFFF),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: const Icon(
                  CupertinoIcons.bolt_fill,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.quizTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0x80FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              child: InkWell(
                onTap: () => _joinLive(context),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Войти',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mono900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    final parts = <String>['Идёт сейчас'];
    if (meta.questionCount > 0) {
      parts.add('${meta.questionCount} вопр.');
    }
    return parts.join(' · ');
  }

  Future<void> _joinLive(BuildContext context) async {
    final repo = getIt<ILiveRepository>();
    final nav = Navigator.of(context, rootNavigator: true);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final join = await repo.joinLiveSession(sessionId: meta.sessionId);
      nav.pop();
      router.push(
        '/live/${meta.sessionId}/student',
        extra: {
          'attemptId': join.attemptId,
          'wsToken': join.wsToken,
          'quizTitle': meta.quizTitle,
          'questionCount': meta.questionCount,
          'moduleId': join.moduleId ?? meta.moduleId ?? '',
        },
      );
    } catch (e) {
      nav.pop();
      if (!context.mounted) return;
      if (tryNavigateLiveStudentAfterJoinSessionCompleted(
            e,
            context: context,
            sessionId: meta.sessionId,
            quizTitle: meta.quizTitle,
            questionCount: meta.questionCount,
            moduleId: meta.moduleId,
          )) {
        return;
      }
      final msg = e is ApiException && e.code == 'SESSION_COMPLETED'
          ? e.message
          : 'Ошибка входа: $e';
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}

