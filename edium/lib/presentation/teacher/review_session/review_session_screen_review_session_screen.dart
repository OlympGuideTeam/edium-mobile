part of 'review_session_screen.dart';

class ReviewSessionScreen extends StatelessWidget {
  final String sessionId;
  final String quizTitle;

  const ReviewSessionScreen({
    super.key,
    required this.sessionId,
    required this.quizTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _Cubit(
        getIt<ListSessionAttemptsUsecase>(),
        getIt<PublishSessionUsecase>(),
        sessionId,
      ),
      child: _View(sessionId: sessionId, quizTitle: quizTitle),
    );
  }
}

