part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

// filter
class SearchFilterApplied extends SearchEvent {
  final String? status;
  final String? priority;
  final String? inspectionType;
  const SearchFilterApplied({this.status, this.priority, this.inspectionType});

  @override
  List<Object?> get props => [status, priority, inspectionType];
}

class SearchFilterCleared extends SearchEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}
