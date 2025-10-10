import 'inspection_detailes_model.dart';

class PaginatedInspections {
  final List<Inspection> inspections;
  final int page;
  final int totalPages;

  PaginatedInspections({
    required this.inspections,
    required this.page,
    required this.totalPages,
  });

  factory PaginatedInspections.fromJson(Map<String, dynamic> json) {
    return PaginatedInspections(
      inspections: (json['data'] as List)
          .map((e) => Inspection.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}
