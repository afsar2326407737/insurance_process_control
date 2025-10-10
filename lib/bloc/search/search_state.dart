part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Inspection> results;
  final String query;
  final String? status;
  final String? priority;
  final String? inspectionType;

  const SearchLoaded({
    required this.results,
    this.query = '',
    this.status,
    this.priority,
    this.inspectionType,
  });

  SearchLoaded copyWith({
    List<Inspection>? results,
    String? query,
    String? status,
    String? priority,
    String? inspectionType,
  }) {
    return SearchLoaded(
      results: results ?? this.results,
      query: query ?? this.query,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      inspectionType: inspectionType ?? this.inspectionType,
    );
  }

  @override
  List<Object?> get props => [results, query, status, priority, inspectionType];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
