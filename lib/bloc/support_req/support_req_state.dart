part of 'support_req_bloc.dart';

sealed class SupportReqState extends Equatable {
  const SupportReqState();
}

final class SupportReqInitial extends SupportReqState {
  @override
  List<Object> get props => [];
}


final class SupportReqLoading extends SupportReqState {
  @override
  List<Object> get props => [];
}

final class SupportReqSuccess extends SupportReqState {
  final String message;

  const SupportReqSuccess(this.message);

  @override
  List<Object> get props => [message];
}

final class SupportReqFailure extends SupportReqState {
  final String error;

  const SupportReqFailure(this.error);

  @override
  List<Object> get props => [error];
}

/// get support request success state
class GetSupportReqSuccess extends SupportReqState {
  final List<SupportRequest> supportRequests;

  const GetSupportReqSuccess(this.supportRequests);

  @override
  List<Object> get props => [supportRequests];
}