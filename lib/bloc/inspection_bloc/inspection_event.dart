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