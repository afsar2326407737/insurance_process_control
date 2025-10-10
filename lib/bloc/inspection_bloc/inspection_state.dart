part of 'inspection_bloc.dart';

abstract class InspectionState extends Equatable {
  const InspectionState();

  @override
  List<Object?> get props => [];
}

final class InspectionInitial extends InspectionState {
  const InspectionInitial();

  @override
  List<Object?> get props => [];
}

class InspectionLoading extends InspectionState {
  const InspectionLoading();

  @override
  List<Object?> get props => [];
}

class InspectionLoaded extends InspectionState {
  final List<Inspection> inspections;
  final bool isLoadingMore;
  final bool hasMore;

  const InspectionLoaded({
    required this.inspections,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  InspectionLoaded copyWith({
    List<Inspection>? inspections,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return InspectionLoaded(
      inspections: inspections ?? this.inspections,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }


  @override
  List<Object?> get props => [inspections, isLoadingMore, hasMore];
}

class InspectionError extends InspectionState {
  final String message;

  InspectionError(this.message);


  @override
  List<Object?> get props => [message];
}
