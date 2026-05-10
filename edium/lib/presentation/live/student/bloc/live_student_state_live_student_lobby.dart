part of 'live_student_state.dart';

class LiveStudentLobby extends LiveStudentState {
  final String quizTitle;
  final int questionCount;
  final List<LiveLobbyParticipant> participants;

  final int? classmatesTotal;

  LiveStudentLobby({
    required this.quizTitle,
    required this.questionCount,
    required this.participants,
    this.classmatesTotal,
  });

  LiveStudentLobby copyWith({
    List<LiveLobbyParticipant>? participants,
    int? classmatesTotal,
  }) =>
      LiveStudentLobby(
        quizTitle: quizTitle,
        questionCount: questionCount,
        participants: participants ?? this.participants,
        classmatesTotal: classmatesTotal ?? this.classmatesTotal,
      );
}

