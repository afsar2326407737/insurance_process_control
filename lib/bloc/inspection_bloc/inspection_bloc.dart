import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import '../../model/inspection_detailes_model.dart';
import '../../model/page_inspection_model.dart';
part 'inspection_event.dart';
part 'inspection_state.dart';

class InspectionBloc extends Bloc<InspectionEvent, InspectionState> {
  int currentPage = 0;
  int totalPages = 1;
  bool isFetching = false;
  final List<Inspection> allInspections = [];

  InspectionBloc() : super(const InspectionInitial()) {
    on<InspectionInitialEvent>(_onInitialLoad);
    on<LoadMoreInspections>(_onLoadMore);
  }

  Future<void> _onInitialLoad(
      InspectionInitialEvent event,
      Emitter<InspectionState> emit,
      ) async {
    try {
      emit(const InspectionLoading());
      isFetching = true;
      currentPage = 0;
      totalPages = 1;
      allInspections.clear();

      final first = await fetchInspections(page: 1);
      allInspections.addAll(first.inspections);
      currentPage = first.page;
      totalPages = first.totalPages;
      isFetching = false;

      emit(InspectionLoaded(
        inspections: List.unmodifiable(allInspections),
        isLoadingMore: false,
        hasMore: currentPage < totalPages,
      ));
    } catch (e) {
      isFetching = false;
      emit(InspectionError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
      LoadMoreInspections event,
      Emitter<InspectionState> emit,
      ) async {
    // Guard: already fetching or no more pages
    if (isFetching) return;
    final hasMore = currentPage < totalPages;
    if (!hasMore) return;
    try {
      isFetching = true;

      // Emit loading-more indicator with current items
      emit(InspectionLoaded(
        inspections: List.unmodifiable(allInspections),
        isLoadingMore: true,
        hasMore: true,
      ));

      final nextPage = currentPage + 1;
      final pageData = await fetchInspections(page: nextPage);

      allInspections.addAll(pageData.inspections);
      currentPage = pageData.page;
      totalPages = pageData.totalPages;
      isFetching = false;

      emit(InspectionLoaded(
        inspections: List.unmodifiable(allInspections),
        isLoadingMore: false,
        hasMore: currentPage < totalPages,
      ));
    } catch (e) {
      isFetching = false;
      emit(InspectionError(e.toString()));
    }
  }


  Future<PaginatedInspections> fetchInspections({required int page}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final jsonString =
    await rootBundle.loadString('assets/test/page_$page.json');
    final data = jsonDecode(jsonString);
    return PaginatedInspections.fromJson(data);
  }
}
