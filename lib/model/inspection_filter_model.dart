import 'package:equatable/equatable.dart';

class InspectionFilter extends Equatable {
  final String? status;
  final String? priority;
  final String? inspectionType;

  const InspectionFilter({
    this.status,
    this.priority,
    this.inspectionType,
  });

  InspectionFilter copyWith({
    String? status,
    String? priority,
    String? inspectionType,
  }) {
    return InspectionFilter(
      status: status ?? this.status,
      priority: priority ?? this.priority,
      inspectionType: inspectionType ?? this.inspectionType,
    );
  }

  bool get isEmpty =>
      status == null && priority == null && inspectionType == null;

  @override
  List<Object?> get props => [status, priority, inspectionType];
}
