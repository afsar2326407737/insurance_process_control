import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../model/inspection_detailes_model.dart';
import '../../repository/couchbase_services.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  String _currentQuery = '';
  String? _status;
  String? _priority;
  String? _inspectionType;

  SearchBloc() : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchFilterApplied>(_onSearchFilterApplied);
    on<SearchFilterCleared>(_onSearchFilterCleared);
  }

  Future<void> _performSearch(Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      final query = _currentQuery.trim().toLowerCase();

      final allResults = await CouchbaseServices().queryInspections(
        query: query,
        status: _status,
        priority: _priority,
        type: _inspectionType,
      );

      final inspections = allResults
          .map((item) =>
          Inspection.fromJson(item['_'] as Map<String, dynamic>))
          .toList();


      emit(SearchLoaded(
        results: inspections,
        query: _currentQuery,
        status: _status,
        priority: _priority,
        inspectionType: _inspectionType,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }


  Future<void> _onSearchQueryChanged(
      SearchQueryChanged event, Emitter<SearchState> emit) async {
    _currentQuery = event.query.toLowerCase();
    log('Query Changed: $_currentQuery', name: 'SearchBloc');
    await _performSearch(emit);
  }

  Future<void> _onSearchFilterApplied(
      SearchFilterApplied event, Emitter<SearchState> emit) async {
    _status = event.status;
    _priority = event.priority;
    _inspectionType = event.inspectionType;
    await _performSearch(emit);
  }

  Future<void> _onSearchFilterCleared(
      SearchFilterCleared event, Emitter<SearchState> emit) async {
    _status = null;
    _priority = null;
    _inspectionType = null;
    await _performSearch(emit);
  }
}
