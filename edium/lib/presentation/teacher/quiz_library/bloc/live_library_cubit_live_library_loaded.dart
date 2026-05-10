part of 'live_library_cubit.dart';

class LiveLibraryLoaded extends LiveLibraryState {
  final List<LiveLibrarySession> sessions;
  const LiveLibraryLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

