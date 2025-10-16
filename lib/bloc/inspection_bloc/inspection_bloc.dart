import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../model/inspection_detailes_model.dart';
import '../../model/page_inspection_model.dart';
import '../../repository/couchbase_services.dart';
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
    on<AddInspection>(_onAddInspection);
    on<SubmitReportEvent>(_onSubmitReport);
    on<DeleteInspectionEvent>(_onDeleteInspection);
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
      final first = await CouchbaseServices().fetchInspections(page: 1);
      allInspections.addAll(first.inspections);
      currentPage = first.page;
      totalPages = first.totalPages;
      isFetching = false;
      log('Total Page $totalPages' , name: 'InspectionBloc');

      emit(InspectionLoaded(
        inspections: List.unmodifiable(allInspections),
        isLoadingMore: false,
        hasMore: currentPage < totalPages,
      ));
    } catch (e) {
      isFetching = false;
      log('Error loading inspections: $e', name: 'InspectionBloc');
      emit(InspectionError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
      LoadMoreInspections event,
      Emitter<InspectionState> emit,
      ) async {
    /// Guard: already fetching or no more pages
    if (isFetching) return;
    final hasMore = currentPage < totalPages;
    if (!hasMore) return;
    try {
      isFetching = true;

      /// Emit loading-more indicator with current items
      emit(InspectionLoaded(
        inspections: List.unmodifiable(allInspections),
        isLoadingMore: true,
        hasMore: true,
      ));

      final nextPage = currentPage + 1;
      final pageData = await CouchbaseServices().fetchInspections(page: nextPage);

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
      log('Error loading more inspections: $e', name: 'InspectionBloc');
      emit(InspectionError(e.toString()));
    }
  }

  FutureOr<void> _onAddInspection(AddInspection event, Emitter<InspectionState> emit) async{
    try {
      emit(const InspectionLoading());
      /// Convert Inspection to Map
      final inspectionMap = event.inspection.toMap();
      await CouchbaseServices().addInspectionToLastPage(inspectionMap);

      /// Reload inspections (optional: reload current page or all)
      final first = await CouchbaseServices().fetchInspections(page: 1);
      allInspections
        ..clear()
        ..addAll(first.inspections);
      currentPage = first.page;
      totalPages = first.totalPages;
      emit(InspectionLoaded(
        inspections: List.unmodifiable(allInspections),
        isLoadingMore: false,
        hasMore: currentPage < totalPages,
      ));
    } catch (e) {
      emit(InspectionError(e.toString()));
    }
  }

  FutureOr<void> _onSubmitReport(SubmitReportEvent event, Emitter<InspectionState> emit) async{
    try {
      emit(const InspectionLoading());
      // prepare the data map to send to Couchbase service

      final formattedLastUpdated = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final Map<String, Object?> reportData = {
        'type': 'report',
        'inspection_id': event.inspectionId,
        'employee_id': event.empId,
        'status': event.status,
        'created_at': formattedLastUpdated,
        'proof_media': event.media.map((file) => file!.path).toList(),
        'signature': event.signature,
      };

      // call the service
      final result = await CouchbaseServices().uploadReportData(
        reportData,
        event.inspectionId,
      );

      if (result) {
        print('Report uploaded successfully for inspection: ${event.inspectionId}');
        emit(InspReportSubSuccessState('Report uploaded successfully.'));
      } else {
        print(' Failed to upload report for inspection: ${event.inspectionId}');
        emit(InspectionError('Failed to upload report.'));
      }
    } catch (e) {
      print(' Error uploading report: $e');
      emit(InspectionError('Error uploading report.'));
    }
  }

  Future<void> _onDeleteInspection(DeleteInspectionEvent event, Emitter<InspectionState> emit) async{
    try {
      emit(const InspectionLoading());
      final result = await CouchbaseServices().deleteInspectionById(event.inspectionId);
      if(result != null ){
        allInspections.removeWhere((inspection) => inspection.inspectionId == event.inspectionId);
        emit(InspectionLoaded(
          inspections: List.unmodifiable(allInspections),
          isLoadingMore: false,
          hasMore: currentPage < totalPages,
        ));
      } else {
        emit(InspectionError('Failed to delete inspection.'));
      }
    } catch (e) {
      emit(InspectionError('Error deleting inspection: $e'));
    }
  }
}
