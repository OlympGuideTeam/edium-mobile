part of 'quiz_library_screen.dart';

class _LiveTab extends StatefulWidget {
  const _LiveTab();

  @override
  State<_LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends State<_LiveTab> {
  late final LiveLibraryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = LiveLibraryCubit(getIt<ILiveRepository>())..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _openSession(LiveLibrarySession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveTeacherScreen(
          sessionId: session.sessionId,
          quizTitle: session.quizTitle,
          questionCount: 0,
        ),
      ),
    ).then((_) => _cubit.load());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: _LiveSessionsContent(onTap: _openSession),
    );
  }
}

