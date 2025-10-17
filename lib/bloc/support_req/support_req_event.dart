part of 'support_req_bloc.dart';

sealed class SupportReqEvent extends Equatable {
  const SupportReqEvent();
}

final class SubmitSupportRequestEvent extends SupportReqEvent {
  final String employeeId;
  final String message;

  const SubmitSupportRequestEvent({
    required this.employeeId,
    required this.message,
  });

  @override
  List<Object?> get props => [employeeId, message];
}

final class GetSupportRequestsEvent extends SupportReqEvent {
  final String employeeId;

  const GetSupportRequestsEvent({required this.employeeId});

  @override
  List<Object?> get props => [employeeId];
}