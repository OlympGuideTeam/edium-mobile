part of 'live_library_cubit.dart';

class LiveLibraryError extends LiveLibraryState {
  final String message;
  const LiveLibraryError(this.message);

  @override
  List<Object?> get props => [message];
}

