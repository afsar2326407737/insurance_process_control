part of 'jokes_bloc.dart';

sealed class JokesEvent extends Equatable {
  const JokesEvent();
}


class FetchJokes extends JokesEvent {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}