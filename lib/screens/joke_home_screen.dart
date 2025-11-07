import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_p_c/bloc/jokes/jokes_bloc.dart';
import 'package:i_p_c/repository/jokes_repository.dart';

class JokesScreen extends StatelessWidget {
  final String type;
  final int noOfJokes;
  const JokesScreen({super.key, required this.type, required this.noOfJokes});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          JokesBloc(JokesRepository(noOfJokes, type))..add(FetchJokes()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Random Jokes')),
        body: BlocBuilder<JokesBloc, JokesState>(
          builder: (context, state) {
            if (state is JokesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is JokesLoaded) {
              return RefreshIndicator(
                onRefresh: () {
                  context.read<JokesBloc>().add(FetchJokes());
                  return Future.value();
                },
                child: ListView.builder(
                  itemCount: state.jokes.length,
                  itemBuilder: (_, index) {
                    final joke = state.jokes[index];
                    return ExpansionTile(
                      title: Text(joke.setup ?? 'No setup'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(joke.punchline ?? 'No punchline'),
                        ),
                      ],
                    );
                  },
                ),
              );
            } else if (state is JokesError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Press refresh to load jokes'));
          },
        ),
      ),
    );
  }
}
