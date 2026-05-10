part of 'review_session_screen.dart';

class _View extends StatelessWidget {
  final String sessionId;
  final String quizTitle;

  const _View({required this.sessionId, required this.quizTitle});

  @override
  Widget build(BuildContext context) {
    return BlocListener<_Cubit, _State>(
      listener: (context, state) {
        if (state is _Published) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Результаты опубликованы')),
          );
          context.pop();
        }
        if (state is _Loaded && state.publishError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка публикации: ${state.publishError}'),
            ),
          );
        }
      },
      child: _ViewBody(sessionId: sessionId, quizTitle: quizTitle),
    );
  }
}

