part of 'live_teacher_state.dart';

class LiveTeacherLobby extends LiveTeacherState {
  final String quizTitle;
  final int questionCount;
  final String? joinCode;
  final List<LiveLobbyParticipant> participants;

  final Map<String, String> roster;

  LiveTeacherLobby({
    required this.quizTitle,
    required this.questionCount,
    this.joinCode,
    required this.participants,
    this.roster = const {},
  });

  LiveTeacherLobby copyWith({
    String? joinCode,
    List<LiveLobbyParticipant>? participants,
    Map<String, String>? roster,
  }) =>
      LiveTeacherLobby(
        quizTitle: quizTitle,
        questionCount: questionCount,
        joinCode: joinCode ?? this.joinCode,
        participants: participants ?? this.participants,
        roster: roster ?? this.roster,
      );
}

