part of 'live_library_cubit.dart';

sealed class LiveLibraryState extends Equatable {
  const LiveLibraryState();

  @override
  List<Object?> get props => [];
}

class LiveLibraryInitial extends LiveLibraryState {
  const LiveLibraryInitial();
}

class LiveLibraryLoading extends LiveLibraryState {
  const LiveLibraryLoading();
}

class LiveLibraryLoaded extends LiveLibraryState {
  final List<LiveLibrarySession> sessions;
  const LiveLibraryLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class LiveLibraryError extends LiveLibraryState {
  final String message;
  const LiveLibraryError(this.message);

  @override
  List<Object?> get props => [message];
}
