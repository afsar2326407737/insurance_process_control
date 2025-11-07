part of 'jokes_bloc.dart';

sealed class JokesState extends Equatable {
  const JokesState();
}

final class JokesInitial extends JokesState {
  @override
  List<Object> get props => [];
}


class JokesLoading extends JokesState {
  @override
  List<Object?> get props => throw UnimplementedError();
}
class JokesLoaded extends JokesState {
  final List<Jokes> jokes;
  JokesLoaded(this.jokes);
  @override
  List<Object?> get props => [jokes];
}
class JokesError extends JokesState {
  final String message;
  JokesError(this.message);
  @override
  List<Object?> get props => [message];
}