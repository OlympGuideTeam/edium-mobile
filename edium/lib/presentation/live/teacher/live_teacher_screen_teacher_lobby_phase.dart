part of 'live_teacher_screen.dart';

class _TeacherLobbyPhase extends StatelessWidget {
  final LiveTeacherLobby state;
  final VoidCallback onStartQuiz;
  final ValueChanged<String> onKick;

  const _TeacherLobbyPhase({
    required this.state,
    required this.onStartQuiz,
    required this.onKick,
  });

  String get _code => state.joinCode ?? '';

  @override
  Widget build(BuildContext context) {
    final joinedUserIds = state.participants
        .where((p) => p.userId != null)
        .map((p) => p.userId!)
        .toSet();

    final notJoined = state.roster.entries
        .where((e) => !joinedUserIds.contains(e.key))
        .map((e) => (userId: e.key, name: e.value))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      backgroundColor: AppColors.mono50,
      appBar: AppBar(
        backgroundColor: AppColors.mono50,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.mono900),
          onPressed: () async {
            final confirm = await EdiumConfirmDialog.show(
              context,
              title: 'Закрыть лобби?',
              body: 'Квиз ещё не начат. Участники будут отключены.',
              confirmLabel: 'Закрыть',
              cancelLabel: 'Отмена',
              isDestructive: true,
            );
            if (confirm == true && context.mounted) context.pop();
          },
        ),
        title: Text(state.quizTitle, style: AppTextStyles.heading3),
      ),
      body: Column(
        children: [
          if (_code.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mono150),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'КОД ДЛЯ ВХОДА',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mono400,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _code,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.mono900,
                            letterSpacing: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Код скопирован')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, color: AppColors.mono400),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(
                    label: 'Присоединились',
                    trailing: '${state.participants.length}',
                  ),
                  const SizedBox(height: 8),
                  if (state.participants.isEmpty)
                    _LobbyEmptyJoined()
                  else
                    ...state.participants.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _LobbyJoinedTile(
                          participant: p,
                          onKick: () => onKick(p.attemptId),
                        ),
                      ),
                    ),
                  if (notJoined.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionLabel(
                      label: 'Ожидаем',
                      trailing: '${notJoined.length}',
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.mono150),
                      ),
                      child: Column(
                        children: notJoined.asMap().entries.map((entry) {
                          return _LobbyNotJoinedRow(
                            name: entry.value.name,
                            isLast: entry.key == notJoined.length - 1,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: state.participants.isNotEmpty ? onStartQuiz : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mono900,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.mono200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                state.participants.isNotEmpty
                    ? 'Начать квиз'
                    : 'Нет участников',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

