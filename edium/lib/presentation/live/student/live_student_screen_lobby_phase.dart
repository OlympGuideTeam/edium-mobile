part of 'live_student_screen.dart';

class _LobbyPhase extends StatelessWidget {
  final String quizTitle;
  final LiveStudentLobby state;

  const _LobbyPhase({
    required this.quizTitle,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    quizTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.start,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LobbySectionLabel(
                      label: 'Присоединились',
                      trailing: '${state.participants.length}',
                    ),
                    const SizedBox(height: 8),
                    if (state.participants.isEmpty)
                      _LobbyEmptyCard()
                    else
                      ...state.participants.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _LobbyParticipantTile(name: p.name),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: const _PulsingWaitBadge(),
        ),
      ),
    );
  }
}

