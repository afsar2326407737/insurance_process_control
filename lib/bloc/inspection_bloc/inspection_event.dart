part of 'inspection_bloc.dart';

sealed class InspectionEvent extends Equatable {
  const InspectionEvent();
}

final class InspectionInitialEvent extends InspectionEvent{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LoadMoreInspections extends InspectionEvent {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}


class AddInspection extends InspectionEvent {
  final Inspection inspection;

  const AddInspection(this.inspection);

  @override
  List<Object?> get props => [inspection];
}

/// Event to submit report
class SubmitReportEvent extends InspectionEvent {
  final String inspectionId;
  final String empId;
  final List<File?> media;
  final Uint8List signature;
  final String status;

  const SubmitReportEvent({
    required this.inspectionId,
    required this.empId,
    required this.media,
    required this.signature,
    required this.status,
  });

  @override
  List<Object?> get props => [inspectionId, empId, media, signature, status];
}

///delete the inspection
class DeleteInspectionEvent extends InspectionEvent {
  final String inspectionId;

  const DeleteInspectionEvent(this.inspectionId);

  @override
  List<Object?> get props => [inspectionId];
}