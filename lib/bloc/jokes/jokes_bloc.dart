import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:i_p_c/model/jokes_model.dart';
import 'package:i_p_c/repository/jokes_repository.dart';

part 'jokes_event.dart';
part 'jokes_state.dart';

class JokesBloc extends Bloc<JokesEvent, JokesState> {
  final JokesRepository repository;
  StreamSubscription? _timerSubscription;

  JokesBloc(this.repository) : super(JokesInitial()) {
    on<JokesEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<FetchJokes>((event , emit) async{
      emit(JokesLoading());
      try {
        final jokes = await repository.fetchJokes();
        emit(JokesLoaded(jokes));
      } catch (e) {
        emit(JokesError(e.toString()));
      }
    });
  }

  void startAutoRefresh() {
    _timerSubscription = Stream.periodic(const Duration(seconds: 10)).listen((_) {
      add(FetchJokes());
    });
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    return super.close();
  }
}
