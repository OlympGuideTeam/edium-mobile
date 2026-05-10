part of 'live_session.dart';

class LiveRosterMember {
  final String userId;
  final String name;

  const LiveRosterMember({required this.userId, required this.name});

  factory LiveRosterMember.fromJson(Map<String, dynamic> json) =>
      LiveRosterMember(
        userId: json['user_id'] as String,
        name: json['name'] as String? ?? '',
      );


  factory LiveRosterMember.fromModuleRosterMemberJson(
    Map<String, dynamic> json,
  ) {
    final userId = json['id'] as String? ?? json['user_id'] as String? ?? '';
    final name = json['name'] as String? ?? '';
    final surname = json['surname'] as String? ?? '';
    final parts = [name, surname].where((s) => s.isNotEmpty).toList();
    final display = parts.join(' ');
    return LiveRosterMember(
      userId: userId,
      name: display.isNotEmpty ? display : (name.isNotEmpty ? name : userId),
    );
  }
}

