
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/support_request_model.dart';
import '../../repository/couchbase_services.dart';
import '../../repository/database_helper.dart';

part 'support_req_event.dart';
part 'support_req_state.dart';

class SupportReqBloc extends Bloc<SupportReqEvent, SupportReqState> {
  SupportReqBloc() : super(SupportReqInitial()) {
    on<SupportReqEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<SubmitSupportRequestEvent>((event, emit) async {
      try {
        emit(SupportReqLoading());
        final isValidUser = await DatabaseHelper().doesEmpIdExist(event.employeeId);
        log('Is valid user: $isValidUser');
        log('Fetching support requests for Employee ID: ${event.employeeId}');
        if(!isValidUser) {
          emit(SupportReqFailure('Invalid Employee ID'));
          return;
        }
        await CouchbaseServices().storeSupportReport(event.employeeId, event.message);
        emit(SupportReqSuccess('Support request submitted successfully'));
      } catch (e) {
        emit(SupportReqFailure('Failed to submit support request'));
      }
    });
    on<GetSupportRequestsEvent>((event, emit) async {
      try {
        emit(SupportReqLoading());
        final isValidUser = await DatabaseHelper().doesEmpIdExist(event.employeeId);
        log('Is valid user: $isValidUser');
        log('Fetching support requests for Employee ID: ${event.employeeId}');
        if(!isValidUser) {
          emit(SupportReqFailure('Invalid Employee ID'));
          return;
        }
        final supportRequests = await CouchbaseServices().getAllSupportRequests();
        emit(GetSupportReqSuccess(supportRequests));
      } catch (e) {
        emit(SupportReqFailure('Failed to fetch support requests'));
      }
    });
  }
}
